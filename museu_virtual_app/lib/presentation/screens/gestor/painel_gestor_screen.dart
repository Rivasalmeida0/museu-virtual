import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/conteudo_service.dart';
import '../../../services/socket_service.dart';
import '../../providers/auth_providers.dart';
import 'form_conteudo_screen.dart';
import 'relatorio_compressao_screen.dart';
import 'controlo_streaming_screen.dart';

class PainelGestorScreen extends ConsumerStatefulWidget {
  const PainelGestorScreen({super.key});

  @override
  ConsumerState<PainelGestorScreen> createState() => _PainelGestorScreenState();
}

class _PainelGestorScreenState extends ConsumerState<PainelGestorScreen> {
  final _service = ConteudoService(AuthService());
  List<dynamic>? _conteudos;
  bool _loading = true;
  String? _erro;

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final funcao = authState.utilizador?['funcao'] as String? ?? '';
    final isGestor = funcao == 'gestor' || funcao == 'admin';

    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Painel de Gestão'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
          ),
          IconButton(
            icon: const Icon(Icons.compress),
            tooltip: 'Relatório de Compressão',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RelatorioCompressaoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.live_tv),
            tooltip: 'Controlo de Streaming Ao Vivo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ControloStreamingScreen()),
              );
            },
          ),
        ],
      ),
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


