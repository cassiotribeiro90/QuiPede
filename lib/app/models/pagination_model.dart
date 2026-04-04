import 'package:equatable/equatable.dart';

class PaginationModel extends Equatable {
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  const PaginationModel({
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      perPage: (json['per_page'] ?? json['perPage']) as int? ?? 20,
      totalPages: (json['total_pages'] ?? json['totalPages']) as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'per_page': perPage,
      'total_pages': totalPages,
    };
  }

  @override
  List<Object?> get props => [total, page, perPage, totalPages];
}
