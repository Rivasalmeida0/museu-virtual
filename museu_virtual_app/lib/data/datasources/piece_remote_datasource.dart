import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/museum_piece_model.dart';

class PieceRemoteDataSource {
  final ApiClient _client;

  PieceRemoteDataSource(this._client);

  Future<List<MuseumPieceModel>> getAll() async {
    final data = await _client.get(ApiConstants.computadores) as List;
    return data
        .map((j) => MuseumPieceModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<MuseumPieceModel>> getByCategory(String categoria) async {
    final endpoint = categoria == 'historico'
        ? ApiConstants.computadoresHistoricos
        : ApiConstants.supercomputadores;
    final data = await _client.get(endpoint) as List;
    return data
        .map((j) => MuseumPieceModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<MuseumPieceModel> getById(int id) async {
    final data = await _client.get('${ApiConstants.computadores}/$id');
    return MuseumPieceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<MuseumPieceModel>> search(String termo) async {
    final data = await _client.get(
      ApiConstants.pesquisaComputadores,
      queryParams: {'q': termo},
    ) as List;
    return data
        .map((j) => MuseumPieceModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
