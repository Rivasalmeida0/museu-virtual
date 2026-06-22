import '../../domain/entities/museum_piece.dart';
import '../../domain/repositories/piece_repository.dart';
import '../datasources/piece_remote_datasource.dart';

class PieceRepositoryImpl implements PieceRepository {
  final PieceRemoteDataSource _dataSource;

  PieceRepositoryImpl(this._dataSource);

  @override
  Future<List<MuseumPiece>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MuseumPiece>> getByCategory(String categoria) async {
    final models = await _dataSource.getByCategory(categoria);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MuseumPiece> getById(int id) async {
    final model = await _dataSource.getById(id);
    return model.toEntity();
  }

  @override
  Future<List<MuseumPiece>> search(String termo) async {
    final models = await _dataSource.search(termo);
    return models.map((m) => m.toEntity()).toList();
  }
}
