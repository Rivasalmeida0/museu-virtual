import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class PlayerVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String titulo;

  const PlayerVideoScreen({
    required this.videoUrl,
    required this.titulo,
    super.key,
  });

  @override
  State<PlayerVideoScreen> createState() => _PlayerVideoScreenState();
}

class _PlayerVideoScreenState extends State<PlayerVideoScreen> {
  final _auth = AuthService();
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      final token = await _auth.getToken();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: headers,
      );
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          bufferedColor: Colors.grey,
        ),
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, errorMessage) => Center(
          child: Text('Erro: $errorMessage',
              style: const TextStyle(color: Colors.white)),
        ),
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _erro = e.toString(); });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!,
                  style: const TextStyle(color: Colors.white)))
              : Center(child: Chewie(controller: _chewieController!)),
    );
  }
}