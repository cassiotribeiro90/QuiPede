import 'package:equatable/equatable.dart';
import 'secao_produto_model.dart';

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
  final List<SecaoProdutoModel> secoes;
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
    required this.secoes,
    required this.filterOptions,
  });

  factory LojaDetalheModel.fromJson(Map<String, dynamic> json) {
    return LojaDetalheModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      slug: json['slug'],
      categoria: json['categoria'],
      logo: json['logo'],
      capa: json['capa'],
      enderecoCompleto: json['endereco_completo'],
      enderecoResumido: json['endereco_resumido'],
      notaMedia: (json['nota_media'] as num).toDouble(),
      totalAvaliacoes: json['total_avaliacoes'],
      tempoEntregaMin: json['tempo_entrega_min'],
      tempoEntregaMax: json['tempo_entrega_max'],
      taxaEntrega: (json['taxa_entrega'] as num).toDouble(),
      pedidoMinimo: (json['pedido_minimo'] as num).toDouble(),
      destaque: json['destaque'],
      verificado: json['verificado'],
      status: json['status'],
      fluxoStatus: json['fluxo_status'],
      corTema: json['cor_tema'],
      secoes: (json['secoes'] as List)
          .map((e) => SecaoProdutoModel.fromJson(e))
          .toList(),
      filterOptions: LojaFilterOptions.fromJson(json['filter_options']),
    );
  }

  @override
  List<Object?> get props => [
        id, nome, descricao, slug, categoria, logo, capa,
        enderecoCompleto, enderecoResumido, notaMedia, totalAvaliacoes,
        tempoEntregaMin, tempoEntregaMax, taxaEntrega, pedidoMinimo,
        destaque, verificado, status, fluxoStatus, corTema, secoes, filterOptions
      ];
}

class LojaFilterOptions extends Equatable {
  final List<LojaFilterCategoria> categorias;
  final List<LojaFilterOrdenacao> ordenacao;

  const LojaFilterOptions({
    required this.categorias,
    required this.ordenacao,
  });

  factory LojaFilterOptions.fromJson(Map<String, dynamic> json) {
    return LojaFilterOptions(
      categorias: (json['categorias'] as List)
          .map((e) => LojaFilterCategoria.fromJson(e))
          .toList(),
      ordenacao: (json['ordenacao'] as List)
          .map((e) => LojaFilterOrdenacao.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [categorias, ordenacao];
}

class LojaFilterCategoria extends Equatable {
  final int id;
  final String nome;
  final String icone;
  final int totalProdutos;

  const LojaFilterCategoria({
    required this.id,
    required this.nome,
    required this.icone,
    required this.totalProdutos,
  });

  factory LojaFilterCategoria.fromJson(Map<String, dynamic> json) {
    return LojaFilterCategoria(
      id: json['id'],
      nome: json['nome'],
      icone: json['icone'],
      totalProdutos: json['total_produtos'],
    );
  }

  @override
  List<Object?> get props => [id, nome, icone, totalProdutos];
}

class LojaFilterOrdenacao extends Equatable {
  final String value;
  final String label;
  final String icon;

  const LojaFilterOrdenacao({
    required this.value,
    required this.label,
    required this.icon,
  });

  factory LojaFilterOrdenacao.fromJson(Map<String, dynamic> json) {
    return LojaFilterOrdenacao(
      value: json['value'],
      label: json['label'],
      icon: json['icon'],
    );
  }

  @override
  List<Object?> get props => [value, label, icon];
}
