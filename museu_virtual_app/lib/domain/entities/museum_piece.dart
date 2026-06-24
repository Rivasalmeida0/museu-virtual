class MuseumPiece {
  final int id;
  final String nome;
  final int ano;
  final String fabricante;
  final String categoria;
  final String descricao;
  final String curiosidade;
  final String imagemUrl;
  final String audioUrl;
  final String videoUrl;
  final String wikipediaUrl;
  final List<PieceSpec> especificacoes;

  const MuseumPiece({
    required this.id,
    required this.nome,
    required this.ano,
    required this.fabricante,
    required this.categoria,
    required this.descricao,
    required this.curiosidade,
    required this.imagemUrl,
    this.audioUrl = '',
    this.videoUrl = '',
    required this.wikipediaUrl,
    required this.especificacoes,
  });
}

class PieceSpec {
  final String label;
  final String value;

  const PieceSpec({required this.label, required this.value});
}
