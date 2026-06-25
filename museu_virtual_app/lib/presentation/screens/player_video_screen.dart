import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

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
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _mostrarControlos = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
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

  void _retroceder() {
    final pos = _videoController.value.position;
    _videoController.seek(Duration(seconds: pos.inSeconds - 10));
  }

  void _avancar() {
    final pos = _videoController.value.position;
    _videoController.seek(Duration(seconds: pos.inSeconds + 10));
  }

  void _parar() {
    _videoController.pause();
    _videoController.seek(Duration.zero);
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
              : Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mostrarControlos = !_mostrarControlos),
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                              onPressed: _retroceder,
                            ),
                            const SizedBox(width: 16),
                            StreamBuilder<VideoPlayerValue>(
                              stream: _videoController.valueStream,
                              builder: (context, snapshot) {
                                final playing = snapshot.data?.isPlaying ?? false;
                                return IconButton(
                                  icon: Icon(
                                    playing ? Icons.pause_circle : Icons.play_circle,
                                    color: Colors.white, size: 52,
                                  ),
                                  onPressed: () => playing ? _videoController.pause() : _videoController.play(),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                              onPressed: _avancar,
                            ),
                            const SizedBox(width: 24),
                            TextButton.icon(
                              onPressed: _parar,
                              icon: const Icon(Icons.stop, color: Colors.grey),
                              label: const Text('Stop', style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: _mostrarControlos
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
    );
  }
}