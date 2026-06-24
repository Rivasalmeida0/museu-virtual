import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureSenha = true;
  bool _isRegister = false;
  final _nomeCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isRegister) {
      await ref.read(authProvider.notifier).register(
            _nomeCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _senhaCtrl.text,
          );
    } else {
      await ref.read(authProvider.notifier).login(
            _emailCtrl.text.trim(),
            _senhaCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        final funcao = (next.utilizador?['funcao'] as String? ?? '').toLowerCase();
        if (funcao == 'gestor' || funcao == 'admin') {
          Navigator.of(context).pushReplacementNamed('/gestor');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 32),

                  if (_isRegister) ...[
                    _buildNomeField(),
                    const SizedBox(height: 16),
                  ],

                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildSenhaField(),
                  const SizedBox(height: 8),

                  if (authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        authState.error!,
                        style: const TextStyle(color: AppColors.angolaRed, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  _buildSubmitButton(authState.status),

                  const SizedBox(height: 16),
                  _buildToggleRegister(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.computer,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Museu Virtual',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isRegister ? 'Criar nova conta' : 'Entrar na sua conta',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeCtrl,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Nome completo', Icons.person_outline),
      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Email', Icons.email_outlined),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
        if (!v.contains('@')) return 'Email inválido';
        return null;
      },
    );
  }

  Widget _buildSenhaField() {
    return TextFormField(
      controller: _senhaCtrl,
      obscureText: _obscureSenha,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Palavra-passe', Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureSenha ? Icons.visibility_off : Icons.visibility,
            color: Colors.white38,
          ),
          onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Campo obrigatório';
        if (v.length < 4) return 'Mínimo 4 caracteres';
        return null;
      },
    );
  }

  Widget _buildSubmitButton(AuthStatus status) {
    final loading = status == AuthStatus.unknown;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isRegister ? 'Criar Conta' : 'Entrar',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildToggleRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegister ? 'Já tem conta? ' : 'Não tem conta? ',
          style: const TextStyle(color: Colors.white54),
        ),
        GestureDetector(
          onTap: () => setState(() => _isRegister = !_isRegister),
          child: Text(
            _isRegister ? 'Entrar' : 'Criar conta',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.angolaRed, width: 1),
      ),
    );
  }
}
