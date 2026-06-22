import '../entities/museum_piece.dart';

abstract class PieceRepository {
  Future<List<MuseumPiece>> getAll();
  Future<List<MuseumPiece>> getByCategory(String categoria);
  Future<MuseumPiece> getById(int id);
  Future<List<MuseumPiece>> search(String termo);
}
