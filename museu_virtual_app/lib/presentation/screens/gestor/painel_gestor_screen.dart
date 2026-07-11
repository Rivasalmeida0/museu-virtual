import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/conteudo_service.dart';
import '../../../services/socket_service.dart';
import '../../providers/auth_providers.dart';
import 'form_conteudo_screen.dart';
import 'relatorio_compressao_screen.dart';
import 'controlo_streaming_screen.dart';
import '../home_page.dart';
import '../login_screen.dart';

class PainelGestorScreen extends ConsumerStatefulWidget {
  const PainelGestorScreen({super.key});

  @override
  ConsumerState<PainelGestorScreen> createState() => _PainelGestorScreenState();
}

class _PainelGestorScreenState extends ConsumerState<PainelGestorScreen> {
  final _service = ConteudoService();
  List<dynamic>? _conteudos;
  bool _loading = true;
  String? _erro;
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
    _iniciarSocket();
  }

  void _iniciarSocket() {
    SocketService().iniciar(ApiConstants.baseUrl);

    SocketService().ouvir('novo_conteudo', (data) {
      if (!mounted) return;
      setState(() {
        _conteudos?.insert(0, data as dynamic);
      });
    });

    SocketService().ouvir('conteudo_atualizado', (data) {
      if (!mounted) return;
      setState(() {
        final idx = _conteudos?.indexWhere((c) => (c as Map)['id'] == data['id']);
        if (idx != null && idx >= 0 && idx < (_conteudos?.length ?? 0)) {
          _conteudos![idx] = data as dynamic;
        }
      });
    });

    SocketService().ouvir('conteudo_apagado', (data) {
      if (!mounted) return;
      setState(() {
        _conteudos?.removeWhere((c) => (c as Map)['id'] == data['id']);
      });
    });
  }

  @override
  void dispose() {
    SocketService().removerOuvinte('novo_conteudo');
    SocketService().removerOuvinte('conteudo_atualizado');
    SocketService().removerOuvinte('conteudo_apagado');
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      final dados = await _service.listarTodos();
      setState(() { _conteudos = dados; _loading = false; });
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  Future<void> _apagar(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text('Tem a certeza que deseja apagar este conteúdo?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar', style: TextStyle(color: AppColors.angolaRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.apagar(id);
      _carregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.angolaRed),
        );
      }
    }
  }

  void _abrirForm({Map<String, dynamic>? conteudo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormConteudoScreen(conteudoExistente: conteudo),
      ),
    ).then((alterado) {
      if (alterado == true) _carregar();
    });
  }

  void _navegarPara(int index) {
    Navigator.pop(context); // fechar drawer
    if (index == _selectedDrawerIndex) return;

    switch (index) {
      case 0:
        // Gestão de Conteúdos (atual)
        setState(() => _selectedDrawerIndex = 0);
        break;
      case 1:
        // Visitar Museu
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 2:
        // Relatório de Compressão
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RelatorioCompressaoScreen()),
        );
        break;
      case 3:
        // Controlo de Streaming
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ControloStreamingScreen()),
        );
        break;
      case 4:
        // Logout
        _fazerLogout();
        break;
    }
  }

  Future<void> _fazerLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Sair', style: TextStyle(color: Colors.white)),
        content: const Text('Tem a certeza que deseja terminar a sessão?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.angolaRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final funcao = (authState.utilizador?['funcao'] as String? ?? '').toLowerCase();
    final isGestor = funcao == 'gestor' || funcao == 'admin';
    final nomeUtilizador = authState.utilizador?['nome'] as String? ?? 'Gestor';
    final emailUtilizador = authState.utilizador?['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Painel de Gestão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _carregar,
          ),
        ],
      ),
      drawer: _buildDrawer(nomeUtilizador, emailUtilizador),
      floatingActionButton: isGestor
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _abrirForm(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildDrawer(String nome, String email) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          // Cabeçalho do Drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0041C8), Color(0xFF1A1A2E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Gestor',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Itens do menu
          _DrawerItem(
            icon: Icons.dashboard,
            label: 'Gestão de Conteúdos',
            isSelected: _selectedDrawerIndex == 0,
            onTap: () => _navegarPara(0),
          ),
          _DrawerItem(
            icon: Icons.museum,
            label: 'Visitar Museu',
            isSelected: false,
            onTap: () => _navegarPara(1),
          ),
          _DrawerItem(
            icon: Icons.compress,
            label: 'Relatório de Compressão',
            isSelected: false,
            onTap: () => _navegarPara(2),
          ),
          _DrawerItem(
            icon: Icons.live_tv,
            label: 'Controlo de Streaming',
            isSelected: false,
            onTap: () => _navegarPara(3),
          ),

          const Spacer(),

          // Logout
          const Divider(color: Colors.white12),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Terminar Sessão',
            isSelected: false,
            color: AppColors.angolaRed,
            onTap: () => _navegarPara(4),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
            ElevatedButton(onPressed: _carregar, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }
    if (_conteudos == null || _conteudos!.isEmpty) {
      return const Center(
        child: Text('Nenhum conteúdo publicado.', style: TextStyle(color: Colors.white54, fontSize: 16)),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conteudos!.length,
        itemBuilder: (_, i) => _buildCard(_conteudos![i] as Map<String, dynamic>),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final nome = item['nome'] as String? ?? 'Sem nome';
    final categoria = item['categoria'] as String? ?? '';
    final imagemUrl = item['imagemUrl'] as String?;
    final ano = item['ano']?.toString() ?? '';

    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagemUrl != null && imagemUrl.isNotEmpty
                  ? Image.network(
                      '${ApiConstants.baseUrl}$imagemUrl',
                      width: 64, height: 64, fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null ? child : const SizedBox(width: 64, height: 64, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))),
                      errorBuilder: (_, erro, __) {
                        debugPrint('Erro ao carregar imagem: $erro (URL: ${ApiConstants.baseUrl}$imagemUrl)');
                        return _placeholderImagem();
                      },
                    )
                  : _placeholderImagem(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (ano.isNotEmpty)
                        Text(ano, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      if (ano.isNotEmpty && categoria.isNotEmpty) const SizedBox(width: 8),
                      if (categoria.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(categoria, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
              onPressed: () => _abrirForm(conteudo: item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.angolaRed, size: 20),
              onPressed: () => _apagar(id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImagem() {
    return Container(
      width: 64, height: 64,
      color: Colors.white.withValues(alpha: 0.08),
      child: const Icon(Icons.image, color: Colors.white24),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? (isSelected ? AppColors.primary : Colors.white70);
    return ListTile(
      leading: Icon(icon, color: itemColor, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: itemColor,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }
}
