import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/streaming_datasource.dart';
import '../../data/models/streaming_models.dart';
import 'piece_providers.dart';

final streamingDatasourceProvider = Provider<StreamingRemoteDatasource>((ref) {
  return StreamingRemoteDatasource(ref.watch(apiClientProvider));
});

final streamingSalasProvider = FutureProvider<List<StreamingSala>>((ref) async {
  return ref.watch(streamingDatasourceProvider).listarSalas();
});
