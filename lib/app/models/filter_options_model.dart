import 'package:equatable/equatable.dart';
import 'categoria_filter_model.dart';

class LojaFilterOrdenacao extends Equatable {
  final String value;
  final String label;
  final String? icon;

  const LojaFilterOrdenacao({
    required this.value,
    required this.label,
    this.icon,
  });

  factory LojaFilterOrdenacao.fromJson(Map<String, dynamic> json) {
    return LojaFilterOrdenacao(
      value: json['value'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [value, label, icon];
}

class LojaFilterOptions extends Equatable {
  final List<CategoriaFilterModel> categorias;
  final List<LojaFilterOrdenacao> ordenacao;

  const LojaFilterOptions({
    required this.categorias,
    required this.ordenacao,
  });

  factory LojaFilterOptions.fromJson(Map<String, dynamic> json) {
    return LojaFilterOptions(
      categorias: (json['categorias'] as List? ?? [])
          .map((e) => CategoriaFilterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      ordenacao: (json['ordenacao'] as List? ?? [])
          .map((e) => LojaFilterOrdenacao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categorias': categorias.map((e) => e.toJson()).toList(),
      'ordenacao': ordenacao.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [categorias, ordenacao];
}
