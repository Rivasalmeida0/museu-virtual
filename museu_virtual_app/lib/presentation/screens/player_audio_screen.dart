import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class PlayerAudioScreen extends StatefulWidget {
  final String audioUrl;
  final String titulo;

  const PlayerAudioScreen({
    required this.audioUrl,
    required this.titulo,
    super.key,
  });

  @override
  State<PlayerAudioScreen> createState() => _PlayerAudioScreenState();
}

class _PlayerAudioScreenState extends State<PlayerAudioScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      await _player.setUrl(widget.audioUrl);
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatar(Duration? d) {
    if (d == null) return '--:--';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.audiotrack,
                      size: 120, color: Colors.white),
                  const SizedBox(height: 32),
                  Text(widget.titulo,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  StreamBuilder<Duration?>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      final pos = snapshot.data ?? Duration.zero;
                      final dur = _player.duration ?? Duration.zero;
                      return Column(children: [
                        Slider(
                          value: pos.inSeconds.toDouble(),
                          max: dur.inSeconds.toDouble(),
                          activeColor: Colors.red,
                          onChanged: (v) =>
                              _player.seek(Duration(seconds: v.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatar(pos),
                                style: const TextStyle(color: Colors.white)),
                            Text(_formatar(dur),
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ]);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.volume_down, color: Colors.white),
                    Expanded(
                      child: StreamBuilder<double>(
                        stream: _player.volumeStream,
                        builder: (context, snapshot) => Slider(
                          value: snapshot.data ?? 1.0,
                          min: 0, max: 1,
                          activeColor: Colors.grey,
                          onChanged: (v) => _player.setVolume(v),
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up, color: Colors.white),
                  ]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 40),
                        onPressed: () {
                          _player.seek(_player.position -
                              const Duration(seconds: 10));
                        },
                      ),
                      StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ?? false;
                          return IconButton(
                            icon: Icon(
                              playing ? Icons.pause_circle : Icons.play_circle,
                              color: Colors.white, size: 72,
                            ),
                            onPressed: () =>
                                playing ? _player.pause() : _player.play(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 40),
                        onPressed: () {
                          _player.seek(_player.position +
                              const Duration(seconds: 10));
                        },
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () { _player.stop(); _player.seek(Duration.zero); },
                    icon: const Icon(Icons.stop, color: Colors.grey),
                    label: const Text('Stop',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
    );
  }
}