import 'package:equatable/equatable.dart';

import '../../enderecos/models/endereco_model.dart';



abstract class LocalizacaoState extends Equatable {
  const LocalizacaoState();
  @override
  List<Object?> get props => [];
}

class LocalizacaoInitial extends LocalizacaoState {}

class LocalizacaoCarregada extends LocalizacaoState {
  final EnderecoModel endereco;
  final String origem; // 'gps', 'endereco_padrao', 'manual'

  const LocalizacaoCarregada({
    required this.endereco,
    required this.origem,
  });

  String get enderecoFormatado => endereco.resumido;
  double? get latitude => endereco.latitude;
  double? get longitude => endereco.longitude;
  String? get referencia => endereco.referencia;

  @override
  List<Object?> get props => [endereco, origem];
}

class LocalizacaoNaoEncontrada extends LocalizacaoState {}
