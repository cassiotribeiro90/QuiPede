import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
  final double? latitude;
  final double? longitude;
  final String? referencia;
  final String? destinatario;
  final String? telefone_contato;

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
    this.latitude,
    this.longitude,
    this.referencia,
    this.destinatario,
    this.telefone_contato,
  });

  // 🔥 GETTER RESUMIDO
  String get resumido {
    if (logradouro.isEmpty) return 'Endereço definido';
    final buffer = StringBuffer(logradouro);
    if (numero.isNotEmpty && numero != 'S/N') {
      buffer.write(', $numero');
    }
    return buffer.toString();
  }

  // 🔥 ENDEREÇO COMPLETO
  String get enderecoCompleto {
    final parts = [
      logradouro,
      if (numero.isNotEmpty) ',$numero',
      if (complemento != null && complemento!.isNotEmpty) ' - $complemento',
      if (referencia != null && referencia!.isNotEmpty) ' (Ref: $referencia)',
      '- $bairro, $cidade - $uf',
      '- CEP: $cep',
    ];
    return parts.join(' ');
  }

  // 🔥 ENDEREÇO RESUMIDO
  String get enderecoResumido {
    final parts = [
      logradouro,
      if (numero.isNotEmpty) ',$numero',
    ];
    return parts.join(' ');
  }

  // 🔥 FROM JSON ROBUSTO
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔄 [EnderecoModel.fromJson] Iniciando parsing');
    debugPrint('   - Keys recebidas: ${json.keys.join(', ')}');
    debugPrint('   - JSON completo: $json');

    try {
      // 🔥 FUNÇÃO AUXILIAR PARA PARSEAR ID
      int? parseId(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
        return null;
      }

      // 🔥 FUNÇÃO AUXILIAR PARA PARSEAR DOUBLE
      double? parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed == null) {
            debugPrint('⚠️ [EnderecoModel] Falha ao parsear String para double: "$value"');
          }
          return parsed;
        }
        return null;
      }

      // 🔥 FUNÇÃO AUXILIAR PARA PARSEAR BOOL
      bool? parseBool(dynamic value) {
        if (value == null) return null;
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) {
          return value.toLowerCase() == 'true' || value == '1';
        }
        return null;
      }

      final result = EnderecoModel(
        id: parseId(json['id']),
        cep: json['cep']?.toString() ?? '',
        logradouro: json['logradouro']?.toString() ?? '',
        numero: json['numero']?.toString() ?? 'S/N',
        complemento: json['complemento']?.toString(),
        bairro: json['bairro']?.toString() ?? '',
        cidade: json['cidade']?.toString() ?? '',
        uf: json['uf']?.toString() ?? '',
        principal: parseBool(json['principal']) ?? false,
        label: json['label']?.toString(),
        latitude: parseDouble(json['latitude']),
        longitude: parseDouble(json['longitude']),
        referencia: json['referencia']?.toString(),
        destinatario: json['destinatario']?.toString(),
        telefone_contato: json['telefone_contato']?.toString(),
      );

      debugPrint('✅ [EnderecoModel.fromJson] Parsing concluído: ${result.resumido} (ID: ${result.id})');
      return result;

    } catch (e, stackTrace) {
      debugPrint('❌ [EnderecoModel.fromJson] ERRO NO PARSING');
      debugPrint('❌ Tipo: ${e.runtimeType}');
      debugPrint('❌ Mensagem: $e');
      debugPrint('❌ JSON recebido: $json');
      debugPrint('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  // 🔥 TO JSON
  Map<String, dynamic> toJson() => {
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
    'latitude': latitude,
    'longitude': longitude,
    'referencia': referencia,
    'destinatario': destinatario,
    'telefone_contato': telefone_contato,
  };

  // 🔥 COPY WITH
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
    double? latitude,
    double? longitude,
    String? referencia,
    String? destinatario,
    String? telefone_contato,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      referencia: referencia ?? this.referencia,
      destinatario: destinatario ?? this.destinatario,
      telefone_contato: telefone_contato ?? this.telefone_contato,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    uf,
    principal,
    label,
    latitude,
    longitude,
    referencia,
    destinatario,
    telefone_contato,
  ];
}