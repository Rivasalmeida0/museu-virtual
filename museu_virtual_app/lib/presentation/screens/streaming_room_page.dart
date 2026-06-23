import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/streaming_datasource.dart';
import '../providers/streaming_providers.dart';

class StreamingRoomPage extends ConsumerStatefulWidget {
  final String salaId;
  final String salaNome;
  final String papel;

  const StreamingRoomPage({
    super.key,
    required this.salaId,
    required this.salaNome,
    required this.papel,
  });

  @override
  ConsumerState<StreamingRoomPage> createState() => _StreamingRoomPageState();
}

enum _PageState { connecting, connected, error, disconnected }

class _StreamingRoomPageState extends ConsumerState<StreamingRoomPage>
    with TickerProviderStateMixin {
  _PageState _pageState = _PageState.connecting;
  String? _errorMessage;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peerConnections = {};

  bool _cameraEnabled = false;
  bool _micEnabled = false;
  bool _cleanedUp = false;

  int _participantCount = 1;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get _isHost => widget.papel == 'anfitriao';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);

    _initRenderers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cleanup();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _connect() async {
    setState(() => _pageState = _PageState.connecting);

    try {
      if (_isHost) {
        final camStatus = await Permission.camera.request();
        final micStatus = await Permission.microphone.request();
        if (!camStatus.isGranted || !micStatus.isGranted) {
          setState(() {
            _pageState = _PageState.error;
            _errorMessage =
                'Permissões de câmera e microfone são necessárias para transmitir.';
          });
          return;
        }
      }

      final ds = ref.read(streamingDatasourceProvider);

      ds.onError((msg) {
        if (mounted) {
          setState(() {
            _pageState = _PageState.error;
            _errorMessage = msg;
          });
        }
      });

      await ds.connectAsync();

      final identity = '${_isHost ? "anfitriao" : "viewer"}_${DateTime.now().millisecondsSinceEpoch}';

      if (_isHost) {
        await _setupHost(ds, identity);
      } else {
        await _setupViewer(ds, identity);
      }

      ds.joinRoom(widget.salaId, widget.papel, identity);

      setState(() => _pageState = _PageState.connected);
    } catch (e) {
      setState(() {
        _pageState = _PageState.error;
        _errorMessage = 'Erro ao conectar: ${e.toString()}';
      });
    }
  }

  Future<void> _setupHost(StreamingRemoteDatasource ds, String identity) async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    setState(() {
      _localStream = stream;
      _cameraEnabled = true;
      _micEnabled = true;
    });

    _localRenderer.srcObject = stream;

    ds.onRoomState((state) {
      for (final viewer in state.viewers) {
        if (!_peerConnections.containsKey(viewer.socketId)) {
          _createPCForViewer(ds, viewer.identity, viewer.socketId, stream);
        }
      }
      if (mounted) {
        setState(() {
          _participantCount = state.count;
        });
      }
    });

    ds.onUserJoined((data) {
      final viewerIdentity = data['identity'] as String;
      final viewerSocketId = data['socketId'] as String;

      _createPCForViewer(ds, viewerIdentity, viewerSocketId, stream);

      if (mounted) {
        setState(() => _participantCount++);
      }
    });

    ds.onUserLeft((data) {
      final socketId = data['socketId'] as String?;
      if (socketId != null && _peerConnections.containsKey(socketId)) {
        _peerConnections[socketId]?.dispose();
        _peerConnections.remove(socketId);
      }
      if (mounted) {
        setState(() {
          _participantCount = (_participantCount - 1).clamp(1, 999);
        });
      }
    });

    ds.onIceCandidate((data) {
      final socketId = data['socketId'] as String?;
      final pc = socketId != null ? _peerConnections[socketId] : null;
      if (pc != null) {
        final candidateMap = data['candidate'] as Map<String, dynamic>?;
        if (candidateMap != null) {
          pc.addCandidate(RTCIceCandidate(
            candidateMap['candidate'] as String? ?? '',
            candidateMap['sdpMid'] as String?,
            candidateMap['sdpMLineIndex'] as int?,
          ));
        }
      }
    });

    ds.onAnswer((data) => _onAnswer(data));
  }

  Future<void> _setupViewer(StreamingRemoteDatasource ds, String identity) async {
    ds.onRoomState((state) {
      if (mounted) {
        setState(() => _participantCount = state.count);
      }
    });

    ds.onUserJoined((data) {
      if (mounted) {
        setState(() => _participantCount++);
      }
    });

    ds.onUserLeft((data) {
      if (mounted) {
        setState(() {
          _participantCount = (_participantCount - 1).clamp(0, 999);
        });
      }
    });

    ds.onHostDisconnected(() {
      if (mounted) {
        setState(() {
          _pageState = _PageState.disconnected;
          _errorMessage = 'O anfitrião terminou a transmissão.';
        });
      }
    });

    ds.onOffer((data) => _onOffer(data, ds));

    ds.onIceCandidate((data) => _onIceCandidateReceived(data));
  }

  Future<void> _createPCForViewer(
    StreamingRemoteDatasource ds,
    String viewerIdentity,
    String viewerSocketId,
    MediaStream stream,
  ) async {
    final pc = await _createPeerConnection();
    _peerConnections[viewerSocketId] = pc;

    stream.getTracks().forEach((track) {
      pc.addTrack(track, stream);
    });

    pc.onIceCandidate = (candidate) {
      ds.sendIceCandidate(viewerSocketId, {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    pc.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected && mounted) {
        _peerConnections.remove(viewerSocketId);
        setState(() => _participantCount = (_participantCount - 1).clamp(1, 999));
      }
    };

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    ds.sendOffer(viewerSocketId, offer.toMap());
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };
    return await createPeerConnection(config);
  }

  void _onOffer(Map<String, dynamic> data, StreamingRemoteDatasource ds) async {
    try {
      final socketId = data['socketId'] as String;
      final pc = await _createPeerConnection();
      _peerConnections[socketId] = pc;

      pc.onIceCandidate = (candidate) {
        ds.sendIceCandidate(socketId, {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      };

      pc.onTrack = (event) {
        if (event.track.kind == 'video') {
          _remoteRenderer.srcObject = event.streams[0];
        }
      };

      final sdp = data['sdp'] as Map<String, dynamic>;
      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'] as String, sdp['type'] as String),
      );

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      ds.sendAnswer(socketId, answer.toMap());
    } catch (e) {
      if (mounted) {
        setState(() {
          _pageState = _PageState.error;
          _errorMessage = 'Erro ao processar oferta: $e';
        });
      }
    }
  }

  void _onAnswer(Map<String, dynamic> data) async {
    final socketId = data['socketId'] as String?;
    final pc = socketId != null ? _peerConnections[socketId] : null;
    if (pc == null) return;
    try {
      final sdp = data['sdp'] as Map<String, dynamic>;
      await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'] as String, sdp['type'] as String),
      );
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro ao processar resposta: $e');
      }
    }
  }

  void _onIceCandidateReceived(Map<String, dynamic> data) async {
    final socketId = data['socketId'] as String?;
    final pc = socketId != null ? _peerConnections[socketId] : null;
    if (pc == null) return;
    try {
      final candidate = data['candidate'] as Map<String, dynamic>?;
      if (candidate != null && candidate['candidate'] != null) {
        await pc.addCandidate(
          RTCIceCandidate(
            candidate['candidate'] as String,
            candidate['sdpMid'] as String?,
            candidate['sdpMLineIndex'] as int?,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _cleanup() async {
    if (_cleanedUp) return;
    _cleanedUp = true;

    final ds = ref.read(streamingDatasourceProvider);
    ds.clearListeners();

    for (final pc in _peerConnections.values) {
      pc.dispose();
    }
    _peerConnections.clear();

    if (_localStream != null) {
      _localStream!.getTracks().forEach((t) => t.stop());
      _localStream!.dispose();
      _localStream = null;
    }

    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    ds.disconnect();
  }

  Future<void> _toggleCamera() async {
    if (_localStream == null) return;
    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      videoTracks.first.enabled = !_cameraEnabled;
      setState(() => _cameraEnabled = !_cameraEnabled);
    }
  }

  Future<void> _toggleMicrophone() async {
    if (_localStream == null) return;
    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isNotEmpty) {
      audioTracks.first.enabled = !_micEnabled;
      setState(() => _micEnabled = !_micEnabled);
    }
  }

  Future<void> _leaveRoom() async {
    final ds = ref.read(streamingDatasourceProvider);
    ds.leaveRoom(widget.salaId);
    await _cleanup();
    if (mounted) Navigator.of(context).pop();
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildVideoArea()),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.angolaBlack.withValues(alpha: 0.9),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _leaveRoom,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.salaNome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _isHost ? 'A Transmitir' : 'A Assistir',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (_pageState == _PageState.connected) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.angolaRed
                        .withValues(alpha: _pulseAnimation.value * 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.angolaRed
                          .withValues(alpha: _pulseAnimation.value * 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.angolaRed
                              .withValues(alpha: _pulseAnimation.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'AO VIVO',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.angolaRed,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '$_participantCount',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    switch (_pageState) {
      case _PageState.connecting:
        return _buildConnectingState();
      case _PageState.connected:
        return _isHost ? _buildPublisherView() : _buildSubscriberView();
      case _PageState.error:
        return _buildErrorState();
      case _PageState.disconnected:
        return _buildDisconnectedState();
    }
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.angolaGold),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'A conectar à sala...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.salaNome,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.angolaRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: 32, color: AppColors.angolaRed),
            ),
            const SizedBox(height: 20),
            Text(
              'Erro de Conexão',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Não foi possível conectar à sala.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _leaveRoom,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Voltar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _connect,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off,
              size: 48, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Desconectado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'A ligação à sala foi terminada.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reconectar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublisherView() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _cameraEnabled && _localStream != null
                    ? RTCVideoView(
                        _localRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirror: true,
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_off,
                                size: 48,
                                color:
                                    Colors.white.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              'Câmera desativada',
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberView() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _remoteRenderer.srcObject != null
                    ? RTCVideoView(
                        _remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.live_tv,
                                  size: 40,
                                  color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'À espera do anfitrião...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A transmissão começará quando o anfitrião iniciar.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.angolaGold.withValues(alpha: 0.6)),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isHost) ...[
            _ControlButton(
              icon: _cameraEnabled
                  ? Icons.videocam
                  : Icons.videocam_off,
              label: 'Câmera',
              isActive: _cameraEnabled,
              activeColor: AppColors.primary,
              onTap: _toggleCamera,
            ),
            _ControlButton(
              icon: _micEnabled ? Icons.mic : Icons.mic_off,
              label: 'Mic',
              isActive: _micEnabled,
              activeColor: AppColors.primary,
              onTap: _toggleMicrophone,
            ),
          ],
          _ControlButton(
            icon: Icons.call_end,
            label: 'Sair',
            isActive: false,
            activeColor: AppColors.angolaRed,
            isDanger: true,
            onTap: _leaveRoom,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final bool isDanger;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDanger
        ? AppColors.angolaRed
        : isActive
            ? activeColor.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1);
    final iconColor = isDanger
        ? Colors.white
        : isActive
            ? activeColor
            : Colors.white.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: isDanger
                  ? null
                  : Border.all(
                      color: isActive
                          ? activeColor.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.15),
                    ),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDanger
                  ? AppColors.angolaRed
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
