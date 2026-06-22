import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/museum_piece.dart';

class PieceSpecModel {
  final String label;
  final String value;

  const PieceSpecModel({required this.label, required this.value});

  factory PieceSpecModel.fromJson(Map<String, dynamic> json) {
    return PieceSpecModel(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  PieceSpec toEntity() => PieceSpec(label: label, value: value);
}

class MuseumPieceModel {
  final int id;
  final String nome;
  final int ano;
  final String fabricante;
  final String categoria;
  final String descricao;
  final String curiosidade;
  final String imagemUrl;
  final String wikipediaUrl;
  final List<PieceSpecModel> especificacoes;

  const MuseumPieceModel({
    required this.id,
    required this.nome,
    required this.ano,
    required this.fabricante,
    required this.categoria,
    required this.descricao,
    required this.curiosidade,
    required this.imagemUrl,
    required this.wikipediaUrl,
    required this.especificacoes,
  });

  factory MuseumPieceModel.fromJson(Map<String, dynamic> json) {
    final specs = <PieceSpecModel>[];
    if (json['especificacoes'] != null) {
      if (json['especificacoes'] is List) {
        for (final s in json['especificacoes'] as List) {
          if (s is Map<String, dynamic>) {
            specs.add(PieceSpecModel.fromJson(s));
          }
        }
      } else if (json['especificacoes'] is String) {
        try {
          final parsed = jsonDecode(json['especificacoes'] as String);
          if (parsed is List) {
            for (final s in parsed) {
              if (s is Map<String, dynamic>) {
                specs.add(PieceSpecModel.fromJson(s));
              }
            }
          }
        } catch (_) {}
      }
    }

    final rawImg = json['imagemUrl'] as String? ??
        json['imagem_url'] as String? ??
        '';
    final parsedImg = rawImg.startsWith('/')
        ? '${ApiConstants.baseUrl}$rawImg'
        : rawImg;

    return MuseumPieceModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      nome: json['nome'] as String? ?? '',
      ano: json['ano'] is int
          ? json['ano'] as int
          : int.tryParse(json['ano'].toString()) ?? 0,
      fabricante: json['fabricante'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      curiosidade: json['curiosidade'] as String? ?? '',
      imagemUrl: parsedImg,
      wikipediaUrl: json['wikipediaUrl'] as String? ??
          json['wikipedia_url'] as String? ??
          '',
      especificacoes: specs,
    );
  }

  MuseumPiece toEntity() => MuseumPiece(
        id: id,
        nome: nome,
        ano: ano,
        fabricante: fabricante,
        categoria: categoria,
        descricao: descricao,
        curiosidade: curiosidade,
        imagemUrl: imagemUrl,
        wikipediaUrl: wikipediaUrl,
        especificacoes: especificacoes
            .map((s) => PieceSpec(label: s.label, value: s.value))
            .toList(),
      );
}
