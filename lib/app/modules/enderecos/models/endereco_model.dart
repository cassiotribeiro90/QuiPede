import 'package:equatable/equatable.dart';

class EnderecoModel extends Equatable {
  final int? id;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final bool? principal;
  final String? label;

  const EnderecoModel({
    this.id,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.principal = false,
    this.label,
  });

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      id: json['id'] as int?,
      cep: json['cep']?.toString() ?? '',
      logradouro: json['logradouro']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      complemento: json['complemento']?.toString(),
      bairro: json['bairro']?.toString() ?? '',
      cidade: json['cidade']?.toString() ?? '',
      uf: json['uf']?.toString() ?? '',
      principal: json['principal'] as bool? ?? false,
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'principal': principal,
      'label': label,
    };
  }

  String get enderecoCompleto {
    final parts = [
      logradouro,
      if (numero.isNotEmpty) ',$numero',
      if (complemento != null && complemento!.isNotEmpty) ' - $complemento',
      '- $bairro, $cidade - $uf',
      '- CEP: $cep',
    ];
    return parts.join(' ');
  }

  String get enderecoResumido {
    final parts = [
      logradouro,
      if (numero.isNotEmpty) ',$numero',
    ];
    return parts.join(' ');
  }

  EnderecoModel copyWith({
    int? id,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
    bool? principal,
    String? label,
  }) {
    return EnderecoModel(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      principal: principal ?? this.principal,
      label: label ?? this.label,
    );
  }

  @override
  List<Object?> get props => [
    id, cep, logradouro, numero, complemento, bairro, cidade, uf, principal, label
  ];
}
