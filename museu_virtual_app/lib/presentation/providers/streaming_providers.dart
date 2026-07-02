import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../data/datasources/streaming_datasource.dart';
import '../../data/models/streaming_models.dart';
import '../../services/socket_service.dart';
import 'piece_providers.dart';

final streamingDatasourceProvider = Provider<StreamingRemoteDatasource>((ref) {
  return StreamingRemoteDatasource(ref.watch(apiClientProvider));
});

final FutureProvider<LiveAtiva?> liveAtivaProvider =
    FutureProvider<LiveAtiva?>((ref) async {
  return ref.watch(streamingDatasourceProvider).obterLiveAtiva();
});

/// Invalida o estado da live quando o servidor emite eventos Socket.IO.
/// Activar com ref.watch() no ecrã que mostra a live (ex.: StreamingPage).
final Provider<void> liveAtivaSocketListenerProvider = Provider<void>((ref) {
  SocketService().iniciar(ApiConstants.baseUrl);

  SocketService().ouvir('stream_iniciado', (_) {
    ref.invalidate(liveAtivaProvider);
  });

  SocketService().ouvir('stream_terminado', (_) {
    ref.invalidate(liveAtivaProvider);
  });
});
