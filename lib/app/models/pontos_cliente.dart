import 'package:equatable/equatable.dart';

class PontosCliente extends Equatable {
  final int saldo;

  const PontosCliente({required this.saldo});

  factory PontosCliente.fromJson(Map<String, dynamic> json) {
    return PontosCliente(
      saldo: (json['saldo'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saldo': saldo,
    };
  }

  @override
  List<Object?> get props => [saldo];
}