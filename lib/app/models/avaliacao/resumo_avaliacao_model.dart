import 'package:equatable/equatable.dart';

class ResumoAvaliacaoModel extends Equatable {
  final int total;
  final double media;
  final int pendentes;
  final int aprovados;
  final int rejeitados;
  final int semResposta;
  final Map<int, int> distribuicao;

  const ResumoAvaliacaoModel({
    required this.total,
    required this.media,
    required this.pendentes,
    required this.aprovados,
    required this.rejeitados,
    required this.semResposta,
    required this.distribuicao,
  });

  factory ResumoAvaliacaoModel.fromJson(Map<String, dynamic> json) {
    return ResumoAvaliacaoModel(
      total: json['total'] as int,
      media: (json['media'] as num).toDouble(),
      pendentes: json['pendentes'] as int,
      aprovados: json['aprovados'] as int,
      rejeitados: json['rejeitados'] as int,
      semResposta: json['sem_resposta'] as int,
      distribuicao: (json['distribuicao'] as Map).map(
        (key, value) => MapEntry(int.parse(key.toString()), value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'media': media,
      'pendentes': pendentes,
      'aprovados': aprovados,
      'rejeitados': rejeitados,
      'sem_resposta': semResposta,
      'distribuicao': distribuicao.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  @override
  List<Object?> get props => [
    total,
    media,
    pendentes,
    aprovados,
    rejeitados,
    semResposta,
    distribuicao,
  ];
}
