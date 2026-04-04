import 'package:equatable/equatable.dart';
import 'package:quipede/app/models/produto_model.dart';
import 'pagination_model.dart';
import 'filter_options_model.dart';

class LojaDetalheModel extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final String slug;
  final String categoria;
  final String logo;
  final String capa;
  final String enderecoCompleto;
  final String enderecoResumido;
  final double notaMedia;
  final int totalAvaliacoes;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double taxaEntrega;
  final double pedidoMinimo;
  final bool destaque;
  final bool verificado;
  final String status;
  final String fluxoStatus;
  final String corTema;
  final List<ProdutoModel> items;
  final PaginationModel pagination;
  final LojaFilterOptions filterOptions;

  const LojaDetalheModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.slug,
    required this.categoria,
    required this.logo,
    required this.capa,
    required this.enderecoCompleto,
    required this.enderecoResumido,
    required this.notaMedia,
    required this.totalAvaliacoes,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.taxaEntrega,
    required this.pedidoMinimo,
    required this.destaque,
    required this.verificado,
    required this.status,
    required this.fluxoStatus,
    required this.corTema,
    required this.items,
    required this.pagination,
    required this.filterOptions,
  });

  factory LojaDetalheModel.fromJson(Map<String, dynamic> json) {
    return LojaDetalheModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      slug: json['slug'] as String,
      categoria: json['categoria'] as String,
      logo: json['logo'] as String,
      capa: json['capa'] as String,
      enderecoCompleto: (json['endereco_completo'] ?? json['enderecoCompleto']) as String,
      enderecoResumido: (json['endereco_resumido'] ?? json['enderecoResumido']) as String,
      notaMedia: (json['nota_media'] ?? 0).toDouble(),
      totalAvaliacoes: (json['total_avaliacoes'] ?? 0) as int,
      tempoEntregaMin: (json['tempo_entrega_min'] ?? 0) as int,
      tempoEntregaMax: (json['tempo_entrega_max'] ?? 0) as int,
      taxaEntrega: (json['taxa_entrega'] ?? 0).toDouble(),
      pedidoMinimo: (json['pedido_minimo'] ?? 0).toDouble(),
      destaque: json['destaque'] == 1 || json['destaque'] == true,
      verificado: json['verificado'] == 1 || json['verificado'] == true,
      status: json['status'] as String,
      fluxoStatus: (json['fluxo_status'] ?? json['fluxoStatus']) as String,
      corTema: (json['cor_tema'] ?? json['corTema']) as String,
      items: (json['items'] as List? ?? [])
          .map((e) => ProdutoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
      filterOptions: LojaFilterOptions.fromJson(json['filter_options'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [
        id, nome, descricao, slug, categoria, logo, capa,
        enderecoCompleto, enderecoResumido, notaMedia, totalAvaliacoes,
        tempoEntregaMin, tempoEntregaMax, taxaEntrega, pedidoMinimo,
        destaque, verificado, status, fluxoStatus, corTema, items,
        pagination, filterOptions
      ];
}
