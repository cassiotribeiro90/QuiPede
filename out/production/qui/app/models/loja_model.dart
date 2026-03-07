import 'package:intl/intl.dart';
import 'enums.dart';

class Loja {
  final int id;
  final String nome;
  final String descricao;
  final CategoriaTipo categoria;
  final String logo;
  final String capa;
  final double nota;
  final double latitude;
  final double longitude;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double taxaEntrega;
  final double pedidoMinimo;
  final List<TipoPagamento> formasPagamento;
  final Map<String, String> horarioFuncionamento;
  final bool favoritado;
  final bool promocao;
  double? distanciaKm;

  Loja({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.logo,
    required this.capa,
    required this.nota,
    required this.latitude,
    required this.longitude,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.taxaEntrega,
    required this.pedidoMinimo,
    required this.formasPagamento,
    required this.horarioFuncionamento,
    this.favoritado = false,
    this.promocao = false,
    this.distanciaKm,
  });

  StatusLoja get status {
    final now = DateTime.now();
    final weekDay = DateFormat('EEEE', 'en_US').format(now).toLowerCase();

    final horarioHoje = horarioFuncionamento[weekDay];
    if (horarioHoje == null || horarioHoje.toLowerCase() == 'fechado') {
      return StatusLoja.fechado;
    }

    try {
      final parts = horarioHoje.split('-');
      final aberturaParts = parts[0].split(':');
      final fechamentoParts = parts[1].split(':');

      final aberturaTime = DateTime(
          now.year, now.month, now.day, int.parse(aberturaParts[0]),
          int.parse(aberturaParts[1]));
      var fechamentoTime = DateTime(
          now.year, now.month, now.day, int.parse(fechamentoParts[0]),
          int.parse(fechamentoParts[1]));

      if (fechamentoTime.isBefore(aberturaTime)) {
        if (now.isBefore(aberturaTime)) {
          final aberturaOntem = aberturaTime.subtract(const Duration(days: 1));
          return now.isAfter(aberturaOntem) && now.isBefore(fechamentoTime)
              ? StatusLoja.aberto : StatusLoja.fechado;
        } else {
          fechamentoTime = fechamentoTime.add(const Duration(days: 1));
        }
      }

      return now.isAfter(aberturaTime) && now.isBefore(fechamentoTime)
          ? StatusLoja.aberto
          : StatusLoja.fechado;
    } catch (e) {
      return StatusLoja.fechado;
    }
  }

  String get tempoEntregaFormatado => '$tempoEntregaMin-$tempoEntregaMax min';

  String get taxaEntregaFormatada {
    if (taxaEntrega == 0) {
      return 'Frete grátis';
    }
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(
        taxaEntrega);
  }

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      categoria: CategoriaTipo.values.firstWhere((e) =>
      e.name == json['categoria'], orElse: () => CategoriaTipo.outros),
      logo: json['logo'] as String,
      capa: json['capa'] as String,
      nota: (json['nota'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      tempoEntregaMin: json['tempoEntregaMin'] as int,
      tempoEntregaMax: json['tempoEntregaMax'] as int,
      taxaEntrega: (json['taxaEntrega'] as num).toDouble(),
      pedidoMinimo: (json['pedidoMinimo'] as num).toDouble(),
      formasPagamento: (json['formasPagamento'] as List)
          .map((p) => TipoPagamento.values.firstWhere((e) => e.name == p))
          .toList(),
      horarioFuncionamento: Map<String, String>.from(
          json['horarioFuncionamento']),
      favoritado: json['favoritado'] ?? false,
      promocao: json['promocao'] ?? false,
      distanciaKm: json['distanciaKm'] != null ? (json['distanciaKm'] as num)
          .toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria.name,
      'logo': logo,
      'capa': capa,
      'nota': nota,
      'latitude': latitude,
      'longitude': longitude,
      'tempoEntregaMin': tempoEntregaMin,
      'tempoEntregaMax': tempoEntregaMax,
      'taxaEntrega': taxaEntrega,
      'pedidoMinimo': pedidoMinimo,
      'formasPagamento': formasPagamento.map((p) => p.name).toList(),
      'horarioFuncionamento': horarioFuncionamento,
      'favoritado': favoritado,
      'promocao': promocao,
      'distanciaKm': distanciaKm,
    };
  }
}
