import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../services/socket_service.dart';

class StreamingAoVivoScreen extends StatefulWidget {
  const StreamingAoVivoScreen({super.key});

  @override
  State<StreamingAoVivoScreen> createState() => _StreamingAoVivoScreenState();
}

class _StreamingAoVivoScreenState extends State<StreamingAoVivoScreen> {
  bool _loading = true;
  bool _streamAtivo = false;
  String? _videoId;
  String? _titulo;
  String? _erro;
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _verificarStream();
    _iniciarSocket();
  }

  @override
  void dispose() {
    SocketService().removerOuvinte('stream_iniciado');
    SocketService().removerOuvinte('stream_terminado');
    _controller?.close();
    super.dispose();
  }

  void _iniciarSocket() {
    SocketService().iniciar(ApiConstants.baseUrl);

    SocketService().ouvir('stream_iniciado', (data) {
      if (!mounted) return;
      setState(() {
        _streamAtivo = true;
        _videoId = data['video_id'] as String?;
        _titulo = data['titulo'] as String?;
        _inicializarPlayer();
      });
    });

    SocketService().ouvir('stream_terminado', (data) {
      if (!mounted) return;
      setState(() {
        _streamAtivo = false;
        _videoId = null;
        _titulo = null;
        _controller?.close();
        _controller = null;
      });
    });
  }

  Future<void> _verificarStream() async {
    setState(() { _loading = true; _erro = null; });
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
            _videoId = dados?['video_id'] as String?;
            _titulo = dados?['titulo'] as String?;
            _loading = false;
          });
          if (_videoId != null) _inicializarPlayer();
        }
      } else {
        if (mounted) setState(() { _streamAtivo = false; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  void _inicializarPlayer() {
    if (_videoId == null || _videoId!.isEmpty) return;
    _controller?.close();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId!,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(_titulo ?? 'Streaming ao Vivo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_streamAtivo)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.angolaRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.angolaRed.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: AppColors.angolaRed),
                  SizedBox(width: 6),
                  Text(
                    'AO VIVO',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.angolaRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
              onPressed: _verificarStream,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (!_streamAtivo || _videoId == null || _videoId!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.live_tv_outlined,
                color: Colors.white24,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma visita guiada em curso',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Volve mais tarde para assistir a visitas guiadas ao vivo.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (_titulo != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              _titulo!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: _controller != null
              ? YoutubePlayer(controller: _controller!)
              : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
