import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/conteudo_service.dart';

class UploadMultimidiaWidget extends StatefulWidget {
  final int conteudoId;
  final Map<String, dynamic>? conteudo;

  const UploadMultimidiaWidget({
    required this.conteudoId,
    this.conteudo,
    super.key,
  });

  @override
  State<UploadMultimidiaWidget> createState() => _UploadMultimidiaWidgetState();
}

class _UploadMultimidiaWidgetState extends State<UploadMultimidiaWidget> {
  final _service = ConteudoService();

  bool _aCarregar = false;
  String? _tipoCarregando;
  Map<String, dynamic>? _relatorioCompressao;
  bool _imagemCarregada = false;
  bool _audioCarregado = false;
  bool _videoCarregado = false;

  @override
  void initState() {
    super.initState();
    _imagemCarregada = widget.conteudo?['imagemUrl'] != null &&
        (widget.conteudo?['imagemUrl'] as String).isNotEmpty;
    _audioCarregado = widget.conteudo?['audioUrl'] != null &&
        (widget.conteudo?['audioUrl'] as String).isNotEmpty;
    _videoCarregado = widget.conteudo?['videoUrl'] != null &&
        (widget.conteudo?['videoUrl'] as String).isNotEmpty;
  }

  Future<void> _fazerUpload(String tipo) async {
    FilePickerResult? resultado;

    switch (tipo) {
      case 'imagem':
        resultado = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        break;
      case 'audio':
        resultado = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
        break;
      case 'video':
        resultado = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
        break;
    }

    if (resultado == null) return;

    setState(() {
      _aCarregar = true;
      _tipoCarregando = tipo;
    });

    try {
      final ficheiro = resultado.files.first;
      if (ficheiro.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao ler ficheiro.')),
        );
        return;
      }
      final bytes = ficheiro.bytes!;
      final nome = ficheiro.name;

      Map<String, dynamic> resposta;
      switch (tipo) {
        case 'audio':
          resposta = await _service.uploadAudio(
            widget.conteudoId,
            bytes,
            filename: nome,
          );
          break;
        case 'video':
          resposta = await _service.uploadVideo(
            widget.conteudoId,
            bytes,
            filename: nome,
          );
          break;
        default:
          resposta = await _service.uploadImagem(
            widget.conteudoId,
            bytes,
            filename: nome,
          );
      }

      setState(() {
        _aCarregar = false;
        _tipoCarregando = null;
        if (tipo == 'imagem') _imagemCarregada = true;
        if (tipo == 'audio') _audioCarregado = true;
        if (tipo == 'video') _videoCarregado = true;
        if (resposta['relatorio_compressao'] != null) {
          _relatorioCompressao = resposta['relatorio_compressao'] as Map<String, dynamic>;
        }
      });

      if (_relatorioCompressao != null) {
        _mostrarRelatorio(_relatorioCompressao!);
      }
    } catch (e) {
      setState(() {
        _aCarregar = false;
        _tipoCarregando = null;
      });
      _mostrarMensagem('Erro: $e');
    }
  }

  void _mostrarRelatorio(Map<String, dynamic> relatorio) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            const Icon(Icons.compress, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Compressão Aplicada',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _linhaRelatorio('Tipo', relatorio['tipo'] ?? ''),
              _linhaRelatorio('Formato original', relatorio['formato_original'] ?? ''),
              _linhaRelatorio('Formato final', relatorio['formato_final'] ?? ''),
              const Divider(color: Colors.white12),
              _linhaRelatorio('Tamanho original', relatorio['tamanho_original_legivel'] ?? ''),
              _linhaRelatorio('Tamanho comprimido', relatorio['tamanho_comprimido_legivel'] ?? ''),
              _linhaRelatorio('Taxa de compressão', relatorio['taxa_compressao'] ?? '',
                  destaque: true),
              _linhaRelatorio('Qualidade', relatorio['qualidade_percebida'] ?? ''),
              _linhaRelatorio('Tempo de processamento',
                  '${relatorio['tempo_processamento_ms']}ms'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _linhaRelatorio(String label, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            valor,
            style: TextStyle(
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              color: destaque ? Colors.green : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Multimédia da Peça',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            if (widget.conteudo?['relatorioCompressao'] != null)
              TextButton.icon(
                onPressed: () {
                  final rel = jsonDecode(
                      widget.conteudo!['relatorioCompressao'] as String);
                  _mostrarRelatorio(rel as Map<String, dynamic>);
                },
                icon: const Icon(Icons.history, color: Colors.green),
                label: const Text('Ver compressão',
                    style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _cardUpload(
          titulo: 'Imagem da Peça',
          subtitulo: 'JPEG ou PNG → comprimido para WebP',
          icone: Icons.image,
          carregado: _imagemCarregada,
          tipo: 'imagem',
        ),
        const SizedBox(height: 12),
        _cardUpload(
          titulo: 'Áudio-Guia (Narração)',
          subtitulo: 'MP3/OGG/AAC → comprimido para MP3 128kbps',
          icone: Icons.audiotrack,
          carregado: _audioCarregado,
          tipo: 'audio',
        ),
        const SizedBox(height: 12),
        _cardUpload(
          titulo: 'Vídeo Documentário',
          subtitulo: 'MP4/WebM/MOV → comprimido para H.264',
          icone: Icons.videocam,
          carregado: _videoCarregado,
          tipo: 'video',
        ),
        if (_aCarregar) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'A comprimir $_tipoCarregando...',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ],
    );
  }

  Widget _cardUpload({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required bool carregado,
    required String tipo,
  }) {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icone,
          color: carregado ? Colors.green : Colors.white38,
          size: 36,
        ),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitulo,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: carregado
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: _aCarregar ? null : () => _fazerUpload(tipo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Upload'),
              ),
      ),
    );
  }
}