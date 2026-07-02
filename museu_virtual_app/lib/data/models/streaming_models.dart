class StreamingSala {
  final String id;
  final String nome;
  final String descricao;
  final bool activa;

  const StreamingSala({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.activa,
  });

  factory StreamingSala.fromJson(Map<String, dynamic> json) {
    return StreamingSala(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      activa: json['activa'] as bool? ?? false,
    );
  }
}

class LiveAtiva {
  final int id;
  final String titulo;
  final String? gestorNome;
  final int? gestorId;
  final String sala;

  const LiveAtiva({
    required this.id,
    required this.titulo,
    this.gestorNome,
    this.gestorId,
    this.sala = 'live-principal',
  });

  factory LiveAtiva.fromJson(Map<String, dynamic> json) {
    return LiveAtiva(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? 'Visita Guiada ao Vivo',
      gestorNome: json['gestor_nome'] as String?,
      gestorId: json['gestor_id'] as int?,
      sala: json['sala'] as String? ?? 'live-principal',
    );
  }
}

class ParticipanteInfo {
  final String identity;
  final String socketId;

  const ParticipanteInfo({
    required this.identity,
    required this.socketId,
  });

  factory ParticipanteInfo.fromJson(Map<String, dynamic> json) {
    return ParticipanteInfo(
      identity: json['identity'] as String,
      socketId: json['socketId'] as String,
    );
  }
}

class RoomState {
  final String? host;
  final String? hostSocketId;
  final List<ParticipanteInfo> viewers;
  final int count;

  const RoomState({
    this.host,
    this.hostSocketId,
    required this.viewers,
    required this.count,
  });

  factory RoomState.fromJson(Map<String, dynamic> json) {
    return RoomState(
      host: json['host'] as String?,
      hostSocketId: json['hostSocketId'] as String?,
      viewers: (json['viewers'] as List?)
              ?.map((e) =>
                  ParticipanteInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 1,
    );
  }
}
