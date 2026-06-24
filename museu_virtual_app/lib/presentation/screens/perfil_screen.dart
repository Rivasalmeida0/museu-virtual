import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import 'gestor/painel_gestor_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _auth = AuthService();
  final _nomeCtrl = TextEditingController();
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _formKeyNome = GlobalKey<FormState>();
  final _formKeySenha = GlobalKey<FormState>();
  bool _loading = true;
  bool _savingNome = false;
  bool _savingSenha = false;
  String? _erro;
  Map<String, dynamic>? _utilizador;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final dados = await _auth.getUtilizadorAutenticado();
      if (mounted) {
        setState(() {
          _utilizador = dados;
          _nomeCtrl.text = dados?['nome'] as String? ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  Future<void> _guardarNome() async {
    if (!_formKeyNome.currentState!.validate()) return;

    setState(() { _savingNome = true; });
    try {
      final token = await _auth.getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/utilizadores/perfil'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nome': _nomeCtrl.text.trim()}),
      ).timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        if (mounted) {
          setState(() {
            _utilizador = body['dados'] as Map<String, dynamic>? ?? _utilizador;
            _savingNome = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nome atualizado com sucesso.')),
          );
        }
      } else {
        if (mounted) {
          setState(() { _savingNome = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['mensagem'] as String? ?? 'Erro ao atualizar nome.'),
              backgroundColor: AppColors.angolaRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _savingNome = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.angolaRed),
        );
      }
    }
  }

  Future<void> _alterarPassword() async {
    if (!_formKeySenha.currentState!.validate()) return;

    setState(() { _savingSenha = true; });
    try {
      final token = await _auth.getToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/utilizadores/password'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'senha_atual': _senhaAtualCtrl.text,
          'nova_senha': _novaSenhaCtrl.text,
        }),
      ).timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        if (mounted) {
          setState(() {
            _savingSenha = false;
            _senhaAtualCtrl.clear();
            _novaSenhaCtrl.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Palavra-passe alterada com sucesso.')),
          );
        }
      } else {
        if (mounted) {
          setState(() { _savingSenha = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['mensagem'] as String? ?? 'Erro ao alterar palavra-passe.'),
              backgroundColor: AppColors.angolaRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _savingSenha = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.angolaRed),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Meu Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(_erro!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarPerfil,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 32),
          _buildInfoCard(),
          if (_isGestor()) ...[
            const SizedBox(height: 24),
            _buildGestorButton(),
          ],
          const SizedBox(height: 24),
          _buildNomeForm(),
          const SizedBox(height: 24),
          _buildPasswordForm(),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final nome = _utilizador?['nome'] as String? ?? 'U';
    final funcao = (_utilizador?['funcao'] as String? ?? 'utilizador').toLowerCase();
    final isGestor = funcao == 'gestor' || funcao == 'admin';
    final primeiraLetra = nome.isNotEmpty ? nome[0].toUpperCase() : 'U';

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            primeiraLetra,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          nome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isGestor
                ? AppColors.angolaGold.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isGestor
                  ? AppColors.angolaGold.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            isGestor ? 'Gestor' : 'Utilizador',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isGestor ? AppColors.angolaGold : Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final email = _utilizador?['email'] as String? ?? '';

    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNomeForm() {
    return Form(
      key: _formKeyNome,
      child: Card(
        color: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alterar Nome',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Nome'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _savingNome ? null : _guardarNome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _savingNome
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar Nome', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKeySenha,
      child: Card(
        color: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alterar Palavra-passe',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaAtualCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Palavra-passe atual'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _novaSenhaCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Nova palavra-passe'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (v.length < 4) return 'Mínimo 4 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _savingSenha ? null : _alterarPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _savingSenha
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Alterar Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.angolaRed,
          side: const BorderSide(color: AppColors.angolaRed, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Sair da Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  bool _isGestor() {
    final funcao = (_utilizador?['funcao'] as String? ?? '').toLowerCase();
    return funcao == 'gestor' || funcao == 'admin';
  }

  Widget _buildGestorButton() {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PainelGestorScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.angolaGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.angolaGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Painel de Gestão',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Gerir conteúdos, streaming e multimédia',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
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
