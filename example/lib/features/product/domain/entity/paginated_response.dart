import 'package:fk_booster/fk_booster.dart';

/// Generic paginated response wrapper matching the API schema.
class PaginatedResponse<T> extends Entity {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  final List<T> items;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  @override
  List<Object?> get props => [items, total, page, perPage, totalPages];
}
