import 'package:equatable/equatable.dart';

class LojasListFilterOptionModel extends Equatable {
  final String value;
  final String label;
  final int count;

  const LojasListFilterOptionModel({
    required this.value,
    required this.label,
    required this.count,
  });

  factory LojasListFilterOptionModel.fromJson(Map<String, dynamic> json) {
    return LojasListFilterOptionModel(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [value, label, count];
}

class LojasListFilterOptionsModel extends Equatable {
  final List<LojasListFilterOptionModel> categorias;

  const LojasListFilterOptionsModel({required this.categorias});

  factory LojasListFilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return LojasListFilterOptionsModel(
      categorias: (json['categorias'] as List? ?? [])
          .map((item) => LojasListFilterOptionModel.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [categorias];
}
