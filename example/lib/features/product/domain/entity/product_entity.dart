import 'package:fk_booster/fk_booster.dart';

/// Represents a product from the API.
class ProductEntity extends Entity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.active,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? price;
  final int? quantity;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    int? quantity,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProductEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    quantity,
    active,
    createdAt,
    updatedAt,
  ];
}
