import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/conteudo_service.dart';

/// Ecrã de Processamento Multimédia
/// Mostra progresso em tempo real e resultados comparativos de todos os codecs.
class ProcessamentoMultimidiaScreen extends StatefulWidget {
  final int conteudoId;
  final String nomeConteudo;
  final Uint8List? imagemBytes;
  final String? imagemFilename;
  final Uint8List? audioBytes;
  final String? audioFilename;
  final Uint8List? videoBytes;
  final String? videoFilename;

  const ProcessamentoMultimidiaScreen({
    required this.conteudoId,
    required this.nomeConteudo,
    this.imagemBytes,
    this.imagemFilename,
    this.audioBytes,
    this.audioFilename,
    this.videoBytes,
    this.videoFilename,
    super.key,
  });

  @override
  State<ProcessamentoMultimidiaScreen> createState() =>
      _ProcessamentoMultimidiaScreenState();
}

class _ProcessamentoMultimidiaScreenState
    extends State<ProcessamentoMultimidiaScreen> with TickerProviderStateMixin {
  final _service = ConteudoService();

  // Estados
  bool _processando = true;
  bool _erro = false;
  String _mensagemErro = '';
  Map<String, dynamic>? _resultado;

  // Seleção do admin
  String? _imagemSelecionada;
  String? _audioSelecionado;
  String? _videoSelecionado;

  bool _publicando = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _iniciarProcessamento();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _iniciarProcessamento() async {
    try {
      final resposta = await _service.uploadProcessar(
        widget.conteudoId,
        imagemBytes: widget.imagemBytes,
        imagemFilename: widget.imagemFilename,
        audioBytes: widget.audioBytes,
        audioFilename: widget.audioFilename,
        videoBytes: widget.videoBytes,
        videoFilename: widget.videoFilename,
      );

      if (!mounted) return;

      final resultado = resposta['resultado'] as Map<String, dynamic>? ?? {};

      // Auto-selecionar a melhor versão de cada tipo
      if (resultado['imagem'] != null) {
        final img = resultado['imagem'] as Map<String, dynamic>;
        final variantes = img['variantes'] as List<dynamic>;
        final melhor = img['melhor'] as String;
        final v = variantes.firstWhere(
          (v) => (v as Map)['codec'] == melhor,
          orElse: () => variantes.first,
        ) as Map<String, dynamic>;
        _imagemSelecionada = v['ficheiro'] as String;
      }
      if (resultado['audio'] != null) {
        final aud = resultado['audio'] as Map<String, dynamic>;
        final variantes = aud['variantes'] as List<dynamic>;
        final melhor = aud['melhor'] as String;
        final v = variantes.firstWhere(
          (v) => (v as Map)['codec'] == melhor,
          orElse: () => variantes.first,
        ) as Map<String, dynamic>;
        _audioSelecionado = v['ficheiro'] as String;
      }
      if (resultado['video'] != null) {
        final vid = resultado['video'] as Map<String, dynamic>;
        final variantes = vid['variantes'] as List<dynamic>;
        final melhor = vid['melhor'] as String;
        final v = variantes.firstWhere(
          (v) => (v as Map)['codec'] == melhor,
          orElse: () => variantes.first,
        ) as Map<String, dynamic>;
        _videoSelecionado = v['ficheiro'] as String;
      }

      setState(() {
        _resultado = resultado;
        _processando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processando = false;
        _erro = true;
        _mensagemErro = e.toString();
      });
    }
  }

  Future<void> _publicar() async {
    setState(() => _publicando = true);
    try {
      await _service.publicarVersoes(
        widget.conteudoId,
        imagemFicheiro: _imagemSelecionada,
        audioFicheiro: _audioSelecionado,
        videoFicheiro: _videoSelecionado,
        relatorio: _resultado,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conteúdo publicado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context)..pop()..pop(); // Volta para o painel
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao publicar: $e'),
          backgroundColor: AppColors.angolaRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Processamento Multimédia'),
        centerTitle: true,
      ),
      body: _processando
          ? _buildProcessando()
          : _erro
              ? _buildErro()
              : _buildResultados(),
    );
  }

  // ─── ECRÃ DE PROCESSAMENTO ───────────────────────────────
  Widget _buildProcessando() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone animado
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: child,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.auto_fix_high_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Preparação para Publicação',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.nomeConteudo,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Itens em processamento
            if (widget.imagemBytes != null)
              _itemProcessamento('Imagem', Icons.image_rounded, ['JPEG', 'PNG', 'WebP']),
            if (widget.audioBytes != null) ...[
              const SizedBox(height: 16),
              _itemProcessamento('Áudio', Icons.audiotrack_rounded, ['MP3', 'AAC', 'OGG']),
            ],
            if (widget.videoBytes != null) ...[
              const SizedBox(height: 16),
              _itemProcessamento('Vídeo', Icons.videocam_rounded, ['H.264', 'H.265', 'VP9']),
            ],

            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            const Text(
              'A otimizar conteúdo multimédia...',
              style: TextStyle(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemProcessamento(String label, IconData icon, List<String> formatos) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          ...formatos.map((f) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Opacity(
                opacity: 0.4 + (_pulseController.value * 0.6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(f, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── ECRÃ DE ERRO ────────────────────────────────────────
  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.angolaRed),
            const SizedBox(height: 16),
            const Text(
              'Erro no Processamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _mensagemErro,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _processando = true;
                  _erro = false;
                });
                _iniciarProcessamento();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ECRÃ DE RESULTADOS ──────────────────────────────────
  Widget _buildResultados() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Otimização Concluída',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.nomeConteudo,
                        style: const TextStyle(fontSize: 13, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Secção Imagem
          if (_resultado?['imagem'] != null)
            _buildSecaoResultado(
              'Imagem',
              Icons.image_rounded,
              _resultado!['imagem'] as Map<String, dynamic>,
              _imagemSelecionada,
              (ficheiro) => setState(() => _imagemSelecionada = ficheiro),
            ),

          // Secção Áudio
          if (_resultado?['audio'] != null) ...[
            const SizedBox(height: 20),
            _buildSecaoResultado(
              'Áudio',
              Icons.audiotrack_rounded,
              _resultado!['audio'] as Map<String, dynamic>,
              _audioSelecionado,
              (ficheiro) => setState(() => _audioSelecionado = ficheiro),
            ),
          ],

          // Secção Vídeo
          if (_resultado?['video'] != null) ...[
            const SizedBox(height: 20),
            _buildSecaoResultado(
              'Vídeo',
              Icons.videocam_rounded,
              _resultado!['video'] as Map<String, dynamic>,
              _videoSelecionado,
              (ficheiro) => setState(() => _videoSelecionado = ficheiro),
            ),
          ],

          const SizedBox(height: 24),

          // Conclusão automática
          _buildConclusao(),

          const SizedBox(height: 28),

          // Botão publicar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _publicando ? null : _publicar,
              icon: _publicando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.publish_rounded, size: 20),
              label: Text(
                _publicando ? 'A publicar...' : 'Publicar Versões Selecionadas',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSecaoResultado(
    String titulo,
    IconData icon,
    Map<String, dynamic> dados,
    String? selecionado,
    ValueChanged<String> onSelecionar,
  ) {
    final variantes = (dados['variantes'] as List<dynamic>)
        .map((v) => v as Map<String, dynamic>)
        .toList();
    final melhor = dados['melhor'] as String;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da secção
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Original: ${dados['formato_original']}',
                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),

          // Tabela comparativa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Header da tabela
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: const [
                        SizedBox(width: 28),
                        Expanded(flex: 2, child: Text('Codec', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Tamanho', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text('Redução', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600))),
                        Expanded(flex: 1, child: Text('Tempo', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  ...variantes.map((v) => _linhaTabela(v, melhor, selecionado, onSelecionar)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _linhaTabela(
    Map<String, dynamic> v,
    String melhor,
    String? selecionado,
    ValueChanged<String> onSelecionar,
  ) {
    final codec = v['codec'] as String;
    final ficheiro = v['ficheiro'] as String;
    final isMelhor = codec == melhor;
    final isSelecionado = ficheiro == selecionado;
    final taxa = v['taxa_otimizacao'] as String? ?? '0%';
    final taxaNum = double.tryParse(taxa.replaceAll('%', '')) ?? 0;

    return InkWell(
      onTap: () => onSelecionar(ficheiro),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelecionado ? AppColors.primary.withValues(alpha: 0.08) : null,
          border: Border(
            left: BorderSide(
              color: isSelecionado ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Radio
            SizedBox(
              width: 28,
              child: Icon(
                isSelecionado ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: isSelecionado ? AppColors.primary : Colors.white24,
              ),
            ),
            // Codec + badge
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    codec,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelecionado ? Colors.white : Colors.white70,
                    ),
                  ),
                  if (isMelhor) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '★',
                        style: TextStyle(fontSize: 9, color: Colors.green),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Tamanho
            Expanded(
              flex: 2,
              child: Text(
                v['tamanho_final'] as String? ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ),
            // Redução
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (taxaNum / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: taxaNum > 50
                              ? Colors.green
                              : taxaNum > 20
                                  ? Colors.amber
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    taxa,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: taxaNum > 50
                          ? Colors.green
                          : taxaNum > 20
                              ? Colors.amber
                              : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            // Tempo
            Expanded(
              flex: 1,
              child: Text(
                '${((v['tempo_ms'] as num?) ?? 0) / 1000}s',
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConclusao() {
    final conclusoes = <String>[];

    if (_resultado?['imagem'] != null) {
      final img = _resultado!['imagem'] as Map<String, dynamic>;
      final melhor = img['melhor'] as String;
      final variantes = (img['variantes'] as List).map((v) => v as Map<String, dynamic>).toList();
      final m = variantes.firstWhere((v) => v['codec'] == melhor);
      conclusoes.add('O $melhor apresentou a maior taxa de otimização (${m['taxa_otimizacao']}) para imagens.');
    }
    if (_resultado?['audio'] != null) {
      final aud = _resultado!['audio'] as Map<String, dynamic>;
      final melhor = aud['melhor'] as String;
      final variantes = (aud['variantes'] as List).map((v) => v as Map<String, dynamic>).toList();
      final m = variantes.firstWhere((v) => v['codec'] == melhor);
      conclusoes.add('O $melhor apresentou o melhor equilíbrio entre qualidade e tamanho para áudio (${m['taxa_otimizacao']}).');
    }
    if (_resultado?['video'] != null) {
      final vid = _resultado!['video'] as Map<String, dynamic>;
      final melhor = vid['melhor'] as String;
      final variantes = (vid['variantes'] as List).map((v) => v as Map<String, dynamic>).toList();
      final m = variantes.firstWhere((v) => v['codec'] == melhor);
      conclusoes.add('O $melhor apresentou melhor eficiência de otimização para vídeo (${m['taxa_otimizacao']}).');
    }

    if (conclusoes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, size: 18, color: Colors.green.shade300),
              const SizedBox(width: 8),
              Text(
                'Análise Automática',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...conclusoes.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 13)),
                Expanded(
                  child: Text(
                    c,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
