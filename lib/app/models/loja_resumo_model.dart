

import 'filter_options_model.dart';

class LojaResumo {
  final int id;
  final String nome;
  final String? logo;
  final String? capa;
  final String categoria;
  final String cidade;
  final String uf;
  final double notaMedia;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double taxaEntrega;
  final double pedidoMinimo;
  final bool destaque;
  final bool verificado;
  final double? distancia;
  final String? distanciaTexto;
  final String? emoji;
  final LojaFilterOptions? filterOptions;

  LojaResumo({
    required this.id,
    required this.nome,
    this.logo,
    this.capa,
    required this.categoria,
    required this.cidade,
    required this.uf,
    required this.notaMedia,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.taxaEntrega,
    required this.pedidoMinimo,
    this.destaque = false,
    this.verificado = false,
    this.distancia,
    this.distanciaTexto,
    this.emoji,
    this.filterOptions,
  });

  bool get isOpenNow => true; 
  String get displayName => nome;
  double get nota => notaMedia;

  factory LojaResumo.fromJson(Map<String, dynamic> json) {
    return LojaResumo(
      id: json['id'] as int,
      nome: json['nome'] as String,
      logo: json['logo'] as String?,
      capa: json['capa'] as String?,
      categoria: json['categoria'] as String,
      cidade: json['cidade'] as String,
      uf: json['uf'] as String,
      notaMedia: (json['nota_media'] ?? json['nota'] ?? 0.0).toDouble(),
      tempoEntregaMin: json['tempo_entrega_min'] ?? json['tempoEntregaMin'] ?? 30,
      tempoEntregaMax: json['tempo_entrega_max'] ?? json['tempoEntregaMax'] ?? 50,
      taxaEntrega: (json['taxa_entrega'] ?? json['taxaEntrega'] ?? 0.0).toDouble(),
      pedidoMinimo: (json['pedido_minimo'] ?? json['pedidoMinimo'] ?? 0.0).toDouble(),
      destaque: json['destaque'] == 1 || json['destaque'] == true,
      verificado: json['verificado'] == 1 || json['verificado'] == true,
      distancia: json['distancia']?.toDouble(),
      distanciaTexto: json['distancia_texto'],
      emoji: json['emoji'] as String?,
      filterOptions: json['filter_options'] != null 
          ? LojaFilterOptions.fromJson(json['filter_options']) 
          : null,
    );
  }

  String get tempoEntregaFormatado => '$tempoEntregaMin-$tempoEntregaMax min';
  String get taxaEntregaFormatada => taxaEntrega == 0 ? 'Frete grátis' : 'R\$ ${taxaEntrega.toStringAsFixed(2)}';
}
