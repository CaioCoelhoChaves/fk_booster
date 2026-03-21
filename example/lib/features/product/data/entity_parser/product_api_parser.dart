import 'package:example/features/product/domain/entity/product_entity.dart';
import 'package:fk_booster/fk_booster.dart';

/// Handles serialization and deserialization of [ProductEntity].
///
/// Uses [FromMap] to parse API responses, [ToMap] to serialize for requests,
/// and [GetId] to extract the product ID for URL construction.
class ProductApiParser extends EntityParser<ProductEntity>
    with
        FromMap<ProductEntity>,
        ToMap<ProductEntity>,
        GetId<ProductEntity, String> {
  const ProductApiParser();

  @override
  ProductEntity fromMap(JsonMap map) => ProductEntity(
    id: map.getString('id'),
    name: map.getString('name'),
    description: map.getString('description'),
    price: map.getString('price'),
    quantity: map.getInt('quantity'),
    active: map.getBool('active'),
    createdAt: map.getDateTime('created_at'),
    updatedAt: map.getDateTime('updated_at'),
  );

  @override
  JsonMap toMap(ProductEntity entity) => {
    'name': entity.name,
    'description': entity.description,
    'price': double.tryParse(entity.price ?? '0'),
    'quantity': entity.quantity,
    'active': entity.active,
  };

  @override
  String getId(ProductEntity entity) => entity.id ?? '';
}
