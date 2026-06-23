import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/piece_remote_datasource.dart';
import '../../data/repositories/piece_repository_impl.dart';
import '../../domain/entities/museum_piece.dart';
import '../../domain/repositories/piece_repository.dart';
import 'auth_providers.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  final client = ApiClient(
    tokenProvider: () => authService.getToken(),
  );
  ref.onDispose(() => client.dispose());
  return client;
});

final pieceRemoteDataSourceProvider = Provider<PieceRemoteDataSource>((ref) {
  return PieceRemoteDataSource(ref.watch(apiClientProvider));
});

final pieceRepositoryProvider = Provider<PieceRepository>((ref) {
  return PieceRepositoryImpl(ref.watch(pieceRemoteDataSourceProvider));
});

final allPiecesProvider = FutureProvider<List<MuseumPiece>>((ref) async {
  return ref.watch(pieceRepositoryProvider).getAll();
});

final historicPiecesProvider = FutureProvider<List<MuseumPiece>>((ref) async {
  return ref.watch(pieceRepositoryProvider).getByCategory('historico');
});

final supercomputerPiecesProvider = FutureProvider<List<MuseumPiece>>((ref) async {
  return ref.watch(pieceRepositoryProvider).getByCategory('supercomputador');
});

final pieceDetailProvider =
    FutureProvider.family<MuseumPiece, int>((ref, id) async {
  return ref.watch(pieceRepositoryProvider).getById(id);
});

final searchPiecesProvider =
    FutureProvider.family<List<MuseumPiece>, String>((ref, termo) async {
  if (termo.isEmpty) return [];
  return ref.watch(pieceRepositoryProvider).search(termo);
});
