import 'package:equatable/equatable.dart';
import 'loja_resumo_model.dart';
import 'pagination_model.dart';
import 'lojas_list_filter_option_model.dart';

class LojaResumoResponseModel extends Equatable {
  final List<LojaResumo> items;
  final PaginationModel pagination;
  final LojasListFilterOptionsModel filterOptions;

  const LojaResumoResponseModel({
    required this.items,
    required this.pagination,
    required this.filterOptions,
  });

  factory LojaResumoResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LojaResumoResponseModel(
      items: (data['items'] as List? ?? [])
          .map((item) => LojaResumo.fromJson(item))
          .toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
      filterOptions: LojasListFilterOptionsModel.fromJson(data['filter_options'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [items, pagination, filterOptions];
}
