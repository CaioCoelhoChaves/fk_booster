# EntityParsers in fk_booster (Practical Guide)

Purpose
- Explain WHAT EntityParsers are and HOW to use them within fk_booster architecture.
- Copy-and-paste friendly: safe to use in other projects without full source visibility.

Summary
- EntityParsers serialize/deserialize data between I/O formats (API/DB/cache) and domain Entities.
- The contract (abstract parser) lives in the domain; concrete implementations live in the data layer.
- Only mix in the behaviors you actually need: FromMap, ToMap, GetId.

Architecture and placement
- Domain (contract): alongside the Entity in the feature domain.
  - Path: `lib/app/features/<feature>/domain/entity/<entity>_entity_parser.dart`
  - Class: `<EntityName>EntityParser extends EntityParser<<EntityName>Entity> with ...`
- Data (implementations): one per data source as needed.
  - Path: `lib/app/features/<feature>/data/entity_parser/<entity>_entity_<source>_parser.dart`
  - Class: `<EntityName>EntityApiParser`, `<EntityName>EntityDbParser`, `<EntityName>EntityCacheParser`, ...

Available mixins and when to include
- FromMap: require a factory from `JsonMap` to Entity.
  - Method: `Entity fromMap(JsonMap map)`
  - Use when READING external data (e.g., API responses, DB rows) into Entities.
- ToMap: require a conversion from Entity to `JsonMap`.
  - Method: `JsonMap toMap(Entity entity)`
  - Include ONLY if you actually SEND/STORE these fields (e.g., POST/PUT or DB writes).
- GetId<Entity, ID>: extract the Entity identifier.
  - Method: `ID getId(Entity entity)`
  - Useful for routes/keys (REST endpoints, cache keys). `ID` must match your Entity id type.

Contract (in domain)
```text
// lib/app/features/<feature_name>/domain/entity/<entity_name>_entity_parser.dart
import 'package:fk_booster/data/parser/entity_parser.dart';
import '<entity_name>_entity.dart';

// Include only the mixins you need for this Entity and your use-cases
abstract class <EntityName>EntityParser extends EntityParser<<EntityName>Entity>
    with FromMap, ToMap, GetId<<EntityName>Entity, String> {}
```

Implementation example for API (in data)
```text
// lib/app/features/<feature_name>/data/entity_parser/<entity_name>_entity_api_parser.dart
import 'package:fk_booster/fk_booster.dart';
import '../../domain/entity/<entity_name>_entity.dart';
import '../../domain/entity/<entity_name>_entity_parser.dart';

class <EntityName>EntityApiParser extends <EntityName>EntityParser {
  @override
  <EntityName>Entity fromMap(JsonMap map) => <EntityName>Entity(
    id: map.getString('id'),
    name: map.getString('name'),
    // Map other fields using map.getString, map.getInt, map.getBool, map.getDate, map.getDateTime, etc.
  );

  @override
  JsonMap toMap(<EntityName>Entity e) => JsonMap()
    ..add('id', e.id)
    ..add('name', e.name);
    // Add only the fields you actually need to send/store; use e.field?.toApi() for nullable dates

  @override
  String getId(<EntityName>Entity e) => e.id ?? '';
}
```

JsonMap helpers (fk_booster)
- Reading: `getString`, `getInt`, `getDouble`, `getBool`, `getDate`, `getDateTime` return `null` when missing/invalid (safe parsing).
- Writing: fluent API `JsonMap()..add('key', value)`.

Key mapping and nullability
- Prefer snake_case keys for APIs/DB and camelCase for Entity fields.
  - Example: `created_at` (I/O) ↔ `createdAt` (Entity)
- Respect Entity nullability:
  - For `Type?` fields, use nullable-safe conversions (e.g., `e.birthday?.toApi()`).
  - Only include keys in `toMap` when they should be transmitted/stored.

Multiple data sources (API/DB/Cache)
- Create one implementation per source: `<EntityName>EntityApiParser`, `<EntityName>EntityDbParser`, etc.
- All implement the same domain contract `<EntityName>EntityParser`.
- Repositories choose the right parser via DI.

Repository usage (conceptual)
```dart
class <FeatureName>RepositoryImpl implements <FeatureName>Repository {
  <FeatureName>RepositoryImpl(this._api, this._parser);

  final <ApiClient> _api;
  final <EntityName>EntityParser _parser; // domain contract

  @override
  Future<<EntityName>Entity> getById(String id) async {
    final json = await _api.get('/<route>/$id');
    return _parser.fromMap(json);
  }

  @override
  Future<void> update(<EntityName>Entity entity) async {
    final body = _parser.toMap(entity);
    await _api.put('/<route>/${_parser.getId(entity)}', data: body);
  }
}
```

Testing tips
- fromMap
  - Happy path with full payload.
  - Missing/invalid types to verify safe parsing.
- toMap
  - Only required keys; ensure nullable fields behave as expected.
- getId
  - Null/empty edge cases (fallbacks).

Checklist
- [ ] Define the contract in `domain/entity/<entity>_entity_parser.dart` with only needed mixins.
- [ ] Create implementations in `data/entity_parser/` per data source.
- [ ] Use `JsonMap` helpers for safe parsing and fluent writes.
- [ ] Honor Entity nullability; send only necessary fields.
- [ ] Register the chosen implementation in DI (global or page-level) and use it in repositories.
- [ ] Add tests for fromMap/toMap/getId.

Common pitfalls
- Placing parser implementations in domain (should be in data).
- Adding `ToMap` when you never send the Entity to any source.
- Wrong key casing (snake_case vs camelCase) or mismatched names.
- Ignoring nullability differences between I/O and Entity.
- Reusing an API parser for DB when the schema/keys differ.
