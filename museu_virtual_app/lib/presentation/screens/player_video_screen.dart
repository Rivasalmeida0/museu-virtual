import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vod_providers.dart';

class PlayerVideoScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final String titulo;
  final int? idConteudo;

  const PlayerVideoScreen({
    required this.videoUrl,
    required this.titulo,
    this.idConteudo,
    super.key,
  });

  @override
  ConsumerState<PlayerVideoScreen> createState() => _PlayerVideoScreenState();
}

class _PlayerVideoScreenState extends ConsumerState<PlayerVideoScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _mostrarControlos = true;
  String? _erro;
  Timer? _progressSaveTimer;
  Timer? _hideControlsTimer;
  bool _isDragging = false;
  double _volume = 1.0;
  bool _isMuted = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();

      // Verificar progresso anterior
      Duration startPosition = Duration.zero;
      if (widget.idConteudo != null) {
        try {
          final progresso = await ref.read(progressoProvider.notifier).obter(widget.idConteudo!);
          if (progresso != null && progresso['posicao_segundos'] != null) {
            final secs = progresso['posicao_segundos'] as int;
            final dur = progresso['duracao_total_segundos'] as int? ?? 1;

            // Apenas retomar se não tiver chegado ao fim (menos de 95%)
            if (secs < (dur * 0.95)) {
              startPosition = Duration(seconds: secs);
            }
          }
        } catch (e) {
          debugPrint('Erro ao obter progresso guardado: $e');
        }
      }

      if (startPosition > Duration.zero) {
        await _controller.seekTo(startPosition);
      }

      await _controller.play();

      // Iniciar timer para guardar progresso a cada 10 segundos
      if (widget.idConteudo != null) {
        _progressSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          _guardarProgressoAtual();
        });
      }

      // Adicionar no histórico
      if (widget.idConteudo != null) {
        ref.read(historicoProvider.notifier).registar(widget.idConteudo!);
      }

      _iniciarTimerEsconderControlos();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _erro = e.toString(); });
    }
  }

  Future<void> _guardarProgressoAtual() async {
    if (widget.idConteudo == null || !_controller.value.isInitialized) return;

    final pos = _controller.value.position.inSeconds;
    final dur = _controller.value.duration.inSeconds;

    if (pos > 0 && dur > 0) {
      await ref.read(progressoProvider.notifier).guardar(
        idConteudo: widget.idConteudo!,
        posicaoSegundos: pos,
        duracaoTotalSegundos: dur,
      );
    }
  }

  // ── Controlos do Vídeo ──────────────────────────────────────────

  void _play() {
    _controller.play();
    _iniciarTimerEsconderControlos();
  }

  void _pause() {
    _controller.pause();
    _mostrarControlosUI();
  }

  void _stop() {
    _controller.pause();
    _controller.seekTo(Duration.zero);
    _guardarProgressoAtual();
    _mostrarControlosUI();
  }

  void _retroceder() {
    final pos = _controller.value.position;
    final newPos = pos - const Duration(seconds: 10);
    _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
    _iniciarTimerEsconderControlos();
  }

  void _avancar() {
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    final newPos = pos + const Duration(seconds: 10);
    _controller.seekTo(newPos > dur ? dur : newPos);
    _iniciarTimerEsconderControlos();
  }

  void _setVolume(double vol) {
    setState(() {
      _volume = vol;
      _isMuted = vol == 0;
    });
    _controller.setVolume(vol);
    _iniciarTimerEsconderControlos();
  }

  void _toggleMute() {
    if (_isMuted) {
      _setVolume(_volume > 0 ? _volume : 1.0);
      setState(() => _isMuted = false);
    } else {
      _controller.setVolume(0);
      setState(() => _isMuted = true);
    }
    _iniciarTimerEsconderControlos();
  }

  // ── Visibilidade dos controlos ──────────────────────────────────

  void _mostrarControlosUI() {
    setState(() => _mostrarControlos = true);
    _iniciarTimerEsconderControlos();
  }

  void _iniciarTimerEsconderControlos() {
    _hideControlsTimer?.cancel();
    if (_controller.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _controller.value.isPlaying && !_isDragging) {
          setState(() => _mostrarControlos = false);
        }
      });
    }
  }

  void _toggleControlos() {
    if (_mostrarControlos) {
      setState(() => _mostrarControlos = false);
      _hideControlsTimer?.cancel();
    } else {
      _mostrarControlosUI();
    }
  }

  // ── Velocidade de reprodução ────────────────────────────────────

  void _mostrarSeletorVelocidade(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final velocidades = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Velocidade de Reprodução',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...velocidades.map((vel) {
                  final isCurrent = _controller.value.playbackSpeed == vel;
                  return ListTile(
                    title: Text(
                      '${vel}x',
                      style: TextStyle(
                        color: isCurrent ? const Color(0xFFE94560) : Colors.white,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle, color: Color(0xFFE94560))
                        : null,
                    onTap: () {
                      _controller.setPlaybackSpeed(vel);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Formatação de tempo ─────────────────────────────────────────

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _hideControlsTimer?.cancel();
    _guardarProgressoAtual();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? _buildLoading()
          : _erro != null
              ? _buildError()
              : _buildPlayer(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
          ),
          SizedBox(height: 16),
          Text(
            'A carregar vídeo...',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE94560), size: 56),
            const SizedBox(height: 16),
            const Text(
              'Erro ao reproduzir vídeo',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _erro!,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return GestureDetector(
      onTap: _toggleControlos,
      onDoubleTapDown: (details) {
        final width = MediaQuery.of(context).size.width;
        if (details.localPosition.dx < width / 2) {
          _retroceder();
        } else {
          _avancar();
        }
      },
      child: Stack(
        children: [
          // Vídeo centrado
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          // Overlay de controlos
          AnimatedOpacity(
            opacity: _mostrarControlos ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_mostrarControlos,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    // ── Barra superior ──
                    _buildTopBar(),

                    const Spacer(),

                    // ── Controlos centrais (Play/Pause/Stop/Avançar/Retroceder) ──
                    _buildCenterControls(),

                    const Spacer(),

                    // ── Barra inferior (Progresso + Volume) ──
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.speed, color: Colors.white70, size: 22),
              tooltip: 'Velocidade',
              onPressed: () => _mostrarSeletorVelocidade(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final isPlaying = value.isPlaying;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Stop ──
            _ControlButton(
              icon: Icons.stop_rounded,
              size: 32,
              color: Colors.white70,
              tooltip: 'Parar',
              onPressed: _stop,
            ),
            const SizedBox(width: 20),

            // ── Retroceder 10s ──
            _ControlButton(
              icon: Icons.replay_10_rounded,
              size: 40,
              tooltip: 'Retroceder 10s',
              onPressed: _retroceder,
            ),
            const SizedBox(width: 20),

            // ── Play / Pause ──
            GestureDetector(
              onTap: () => isPlaying ? _pause() : _play(),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE94560),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94560).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(width: 20),

            // ── Avançar 10s ──
            _ControlButton(
              icon: Icons.forward_10_rounded,
              size: 40,
              tooltip: 'Avançar 10s',
              onPressed: _avancar,
            ),
            const SizedBox(width: 20),

            // ── Velocidade (indicador) ──
            _ControlButton(
              icon: Icons.speed_rounded,
              size: 32,
              color: Colors.white70,
              tooltip: 'Velocidade: ${value.playbackSpeed}x',
              onPressed: () => _mostrarSeletorVelocidade(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final position = value.position;
            final duration = value.duration;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Indicador de progresso ──
                Row(
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          activeTrackColor: const Color(0xFFE94560),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: const Color(0xFFE94560),
                          overlayColor: const Color(0x33E94560),
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChangeStart: (_) {
                            _isDragging = true;
                            _hideControlsTimer?.cancel();
                          },
                          onChanged: (val) {
                            final newPos = Duration(
                              milliseconds: (val * duration.inMilliseconds).toInt(),
                            );
                            _controller.seekTo(newPos);
                          },
                          onChangeEnd: (_) {
                            _isDragging = false;
                            _iniciarTimerEsconderControlos();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ── Controlo de volume ──
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Icon(
                        _isMuted || _volume == 0
                            ? Icons.volume_off_rounded
                            : _volume < 0.5
                                ? Icons.volume_down_rounded
                                : Icons.volume_up_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 120,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          activeTrackColor: Colors.white70,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                        ),
                        child: Slider(
                          value: _isMuted ? 0 : _volume,
                          min: 0,
                          max: 1,
                          onChanged: (val) {
                            _setVolume(val);
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Indicador de buffer
                    if (value.isBuffering)
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Widget auxiliar para botões de controlo centrais
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.size,
    this.color = Colors.white,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: size),
          ),
        ),
      ),
    );
  }
}