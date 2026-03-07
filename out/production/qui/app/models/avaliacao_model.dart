import 'package:equatable/equatable.dart';

class Avaliacao extends Equatable {
  final int id;
  final int lojaId;
  final String nomeUsuario;
  final int nota;
  final String comentario;
  final DateTime data;

  const Avaliacao({
    required this.id,
    required this.lojaId,
    required this.nomeUsuario,
    required this.nota,
    required this.comentario,
    required this.data,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      lojaId: json['lojaId'],
      nomeUsuario: json['nomeUsuario'],
      nota: json['nota'],
      comentario: json['comentario'],
      data: DateTime.parse(json['data']),
    );
  }

  @override
  List<Object?> get props => [id, lojaId, nomeUsuario, nota, comentario, data];
}
