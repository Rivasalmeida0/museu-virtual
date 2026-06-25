import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

class ControloStreamingScreen extends StatefulWidget {
  const ControloStreamingScreen({super.key});

  @override
  State<ControloStreamingScreen> createState() => _ControloStreamingScreenState();
}

class _ControloStreamingScreenState extends State<ControloStreamingScreen> {
  final _videoIdCtrl = TextEditingController();
  final _tituloCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _streamAtivo = false;
  String? _streamTitulo;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _verificarEstado();
  }

  @override
  void dispose() {
    _videoIdCtrl.dispose();
    _tituloCtrl.dispose();
    super.dispose();
  }

  Future<void> _verificarEstado() async {
    setState(() { _erro = null; });
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/streaming-ao-vivo/ativo'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        final dados = body['dados'] as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            _streamAtivo = true;
            _streamTitulo = dados?['titulo'] as String?;
            _videoIdCtrl.text = dados?['video_id'] as String? ?? '';
            _tituloCtrl.text = dados?['titulo'] as String? ?? '';
          });
        }
      } else {
        if (mounted) setState(() { _streamAtivo = false; _streamTitulo = null; });
      }
    } catch (e) {
      if (mounted) setState(() { _erro = e.toString(); });
    }
  }

  Future<void> _iniciarStream() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; _erro = null; });
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/streaming-ao-vivo/iniciar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'video_id': _videoIdCtrl.text.trim(),
          'titulo': _tituloCtrl.text.trim(),
        }),
      ).timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        if (mounted) {
          setState(() {
            _streamAtivo = true;
            _streamTitulo = _tituloCtrl.text.trim();
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transmissão iniciada com sucesso!')),
          );
        }
      } else {
        if (mounted) {
          setState(() { _loading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['mensagem'] as String? ?? 'Erro ao iniciar transmissão.'),
              backgroundColor: AppColors.angolaRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.angolaRed),
        );
      }
    }
  }

  Future<void> _terminarStream() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem a certeza que deseja terminar a transmissão ao vivo?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Terminar', style: TextStyle(color: AppColors.angolaRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() { _loading = true; _erro = null; });
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/streaming-ao-vivo/terminar'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConstants.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['sucesso'] == true) {
        if (mounted) {
          setState(() {
            _streamAtivo = false;
            _streamTitulo = null;
            _videoIdCtrl.clear();
            _tituloCtrl.clear();
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transmissão terminada.')),
          );
        }
      } else {
        if (mounted) {
          setState(() { _loading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['mensagem'] as String? ?? 'Erro ao terminar transmissão.'),
              backgroundColor: AppColors.angolaRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.angolaRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Controlo de Streaming'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _verificarEstado,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildInstrucoesCard(),
            const SizedBox(height: 24),
            _buildForm(),
            if (_erro != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.angolaRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.angolaRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _erro!,
                        style: const TextStyle(color: AppColors.angolaRed, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _streamAtivo
                    ? AppColors.angolaRed.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _streamAtivo ? Icons.live_tv : Icons.live_tv_outlined,
                color: _streamAtivo ? AppColors.angolaRed : Colors.white38,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _streamAtivo ? 'Streaming Ativo' : 'Nenhuma transmissão ativa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_streamTitulo != null)
                    Text(
                      _streamTitulo!,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                ],
              ),
            ),
            if (_streamAtivo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.angolaRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.angolaRed),
                    SizedBox(width: 4),
                    Text(
                      'AO VIVO',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.angolaRed,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrucoesCard() {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
        ),
        title: const Text(
          'Como obter o ID do YouTube Live?',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _passo(1, 'Abre o YouTube Studio (studio.youtube.com).'),
                _passo(2, 'Clica em "Transmitir ao vivo" no canto superior direito.'),
                _passo(3, 'Em "Webcam" ou "Codificador", seleciona "Codificador".'),
                _passo(4, 'Aparecerá um URL e um Nome do Stream (chave de transmissão).'),
                _passo(5, 'Copia o "ID do vídeo" — é a parte após ?v= no URL de visualização.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white38, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exemplo: se o URL for "youtube.com/watch?v=abc123", o ID é "abc123".',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passo(int numero, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iniciar Nova Transmissão',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _videoIdCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _decoration('ID do YouTube Live'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tituloCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _decoration('Título da Transmissão'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _iniciarStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Iniciar Transmissão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          if (_streamAtivo) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _terminarStream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.angolaRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Terminar Transmissão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
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
    );
  }
}
