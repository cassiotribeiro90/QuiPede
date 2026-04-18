class EnderecoSugestao {
  final int? id;
  final String descricao;
  final String? cep;
  final String logradouro;
  final String numero;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final double? latitude;
  final double? longitude;
  final String? distanciaTexto;

  EnderecoSugestao({
    this.id,
    required this.descricao,
    this.cep,
    required this.logradouro,
    required this.numero,
    this.bairro,
    this.cidade,
    this.uf,
    this.latitude,
    this.longitude,
    this.distanciaTexto,
  });

  factory EnderecoSugestao.fromJson(Map<String, dynamic> json) {
    return EnderecoSugestao(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      descricao: json['descricao'] ?? '',
      cep: json['cep']?.toString(),
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? 'S/N',
      bairro: json['bairro'],
      cidade: json['cidade'],
      uf: json['uf'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanciaTexto: json['distancia_texto'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'latitude': latitude,
      'longitude': longitude,
      'distancia_texto': distanciaTexto,
    };
  }
}
