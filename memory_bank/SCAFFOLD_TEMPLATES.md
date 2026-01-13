fk_booster Scaffold Templates

Use these copy-ready templates to add features and pages in projects that consume fk_booster. Replace placeholders with your names.

**Reference Documentation**:
- See `ENTITIES.md` for Entity conventions
- See `ENTITY_PARSERS.md` for Parser conventions
- See `REPOSITORIES.md` for Repository conventions
- See `DEPENDENCY_INJECTION.md` for DI system details
- See `VIEWSTATE.md` for ViewState and ViewModel patterns

---

New Feature: `<feature_name>`
Folders
- `lib/app/features/<feature_name>/domain/entity/`
- `lib/app/features/<feature_name>/domain/repository/`
- `lib/app/features/<feature_name>/data/entity_parser/`
- `lib/app/features/<feature_name>/data/repository/`

Domain entity (example outline)
```text
// lib/app/features/<feature_name>/domain/entity/<entity_name>_entity.dart
import 'package:fk_booster/domain/domain.dart';

class <EntityName>Entity extends Entity {
  const <EntityName>Entity({
    required this.id,
    required this.name,
    // Add other fields...
  });

  const <EntityName>Entity.empty()
    : id = null,
      name = null;

  final String? id;
  final String? name;
  // Add other fields...

  @override
  List<Object?> get props => [id, name];

  <EntityName>Entity copyWith({
    String? id,
    String? name,
  }) {
    return <EntityName>Entity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```
See `ENTITIES.md` for complete Entity conventions and best practices.

Domain repository interface (example outline)
```text
// lib/app/features/<feature_name>/domain/repository/<feature_name>_repository.dart
import 'package:example/app/features/<feature_name>/domain/entity/<entity_name>_entity.dart';
import 'package:fk_booster/domain/domain.dart';

abstract class <FeatureName>Repository extends Repository<<EntityName>Entity>
    with
        Create<<EntityName>Entity, <EntityName>Entity>,
        GetAll<<EntityName>Entity>,
        GetById<<EntityName>Entity, String>,
        Delete<<EntityName>Entity, <EntityName>Entity> {}
```
See `REPOSITORIES.md` for complete Repository conventions and patterns.

Entity Parser contract (domain)
```text
// lib/app/features/<feature_name>/domain/entity/<entity_name>_entity_parser.dart
import 'package:fk_booster/data/parser/entity_parser.dart';
import '<entity_name>_entity.dart';

// Include ONLY the mixins you actually need for your use-cases
abstract class <EntityName>EntityParser extends EntityParser<<EntityName>Entity>
    with FromMap, ToMap, GetId<<EntityName>Entity, String> {}
```

Parser implementation for API (data)
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
  String getId(<EntityName>Entity entity) => entity.id ?? '';
}
```

Parser implementation for DB (data) — optional variant
```text
// lib/app/features/<feature_name>/data/entity_parser/<entity_name>_entity_db_parser.dart
import 'package:fk_booster/fk_booster.dart';
import '../../domain/entity/<entity_name>_entity.dart';
import '../../domain/entity/<entity_name>_entity_parser.dart';

class <EntityName>EntityDbParser extends <EntityName>EntityParser {
  @override
  <EntityName>Entity fromMap(JsonMap map) => <EntityName>Entity(
    id: map.getString('id'),
    name: map.getString('name'),
    // DB-specific key mapping if needed
  );

  @override
  JsonMap toMap(<EntityName>Entity e) => JsonMap()
    ..add('id', e.id)
    ..add('name', e.name);

  @override
  String getId(<EntityName>Entity entity) => entity.id ?? '';
}
```

Repository implementation (example outline)
```text
// lib/app/features/<feature_name>/data/repository/<feature_name>_api_repository.dart
import 'package:example/app/features/<feature_name>/domain/entity/<entity_name>_entity.dart';
import 'package:example/app/features/<feature_name>/domain/entity/<entity_name>_entity_parser.dart';
import 'package:example/app/features/<feature_name>/domain/repository/<feature_name>_repository.dart';
import 'package:fk_booster/data/data.dart';

class <FeatureName>ApiRepository extends DioRepository<<EntityName>Entity>
    implements <FeatureName>Repository {
  const <FeatureName>ApiRepository({
    required this.parser,
    required super.dio,
  }) : super(baseUrl: '/<feature_endpoint>');

  final <EntityName>EntityParser parser;

  @override
  Future<<EntityName>Entity> create(<EntityName>Entity entity) => rawCreate(
    entity: entity,
    entityParser: parser,
    responseParser: parser,
  );

  @override
  Future<<EntityName>Entity> delete(<EntityName>Entity entity) => rawDelete(
    entity: entity,
    idParser: parser,
    responseParser: parser,
  );

  @override
  Future<List<<EntityName>Entity>> getAll() => rawGetAll(entityParser: parser);

  @override
  Future<<EntityName>Entity> getById(String id) => rawGetById(
    id: id,
    idParser: parser,
    entityParser: parser,
  );
}
```
See `REPOSITORIES.md` for complete Repository implementation guide.

Parser tests (example outline)
```text
// test/app/features/<feature_name>/data/entity_parser/<entity_name>_entity_api_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:<your_app>/app/features/<feature_name>/domain/entity/<entity_name>_entity.dart';
import 'package:<your_app>/app/features/<feature_name>/data/entity_parser/<entity_name>_entity_api_parser.dart';

void main() {
  group('<EntityName>EntityApiParser', () {
    final parser = <EntityName>EntityApiParser();

    test('fromMap parses happy path', () {
      final json = JsonMap()
        ..add('id', '1')
        ..add('name', 'Alice');
      final e = parser.fromMap(json);
      expect(e.id, '1');
      expect(e.name, 'Alice');
    });

    test('toMap writes only required keys', () {
      final e = <EntityName>Entity(id: '1', name: 'Alice');
      final json = parser.toMap(e);
      expect(json['id'], '1');
      expect(json['name'], 'Alice');
    });

    test('getId returns empty when null', () {
      const e = <EntityName>Entity.empty();
      expect(parser.getId(e), isEmpty);
    });
  });
}
```

New Page: `<page_name>`
Folders
- `lib/app/pages/<page_name>/`

Injection (example outline)
```text
// lib/app/pages/<page_name>/<page_name>_injection.dart
import 'package:fk_booster/fk_booster.dart';
import '../../features/<feature_name>/domain/repository/<feature_name>_repository.dart';
import '../../features/<feature_name>/data/repository/<feature_name>_repository_impl.dart';
import '../../features/<feature_name>/data/entity_parser/<entity_name>_entity_api_parser.dart';
import '<page_name>_view_model.dart';

<FeatureName>Repository make<FeatureName>Repository() {
  return <FeatureName>RepositoryImpl(<EntityName>EntityApiParser());
}

<PageName>ViewModel make<PageName>ViewModel() {
  return <PageName>ViewModel(repo: make<FeatureName>Repository());
}
```

ViewModel (example outline)
```text
// lib/app/pages/<page_name>/<page_name>_view_model.dart
import 'package:fk_booster/fk_booster.dart';
import '../../features/<feature_name>/domain/repository/<feature_name>_repository.dart';

class <PageName>ViewModel extends ViewModelBase {
  final <FeatureName>Repository repo;

  <PageName>ViewModel({required this.repo});

  // Define commands
  // final load = CommandBuilder().async(() async {
  //   setLoading();
  //   final items = await repo.fetchAll();
  //   setContent(items);
  // }).build();
}
```

Page widget (example outline)
```text
// lib/app/pages/<page_name>/<page_name>_page.dart
import 'package:flutter/material.dart';
import 'package:fk_booster/fk_booster.dart';
import '<page_name>_injection.dart';
import '<page_name>_view_model.dart';

class <PageName>Page extends StatelessWidget {
  const <PageName>Page({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = make<PageName>ViewModel();
    return Scaffold(
      appBar: AppBar(title: const Text('<PageName>')),
      body: ViewStateBuilder(
        viewModel: vm,
        builder: (context, state) {
          // switch on state: loading/content/error
          // return appropriate widgets
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

Checklist (copy for PRs)
- Feature: domain entities and interfaces created.
- Feature: data parsers and repository implementations created.
- Page: injection, ViewModel, and page widget created.
- DI: global bindings in `startup_injection.dart` if shared, or local page injection if isolated.
- Naming: snake case for files/folders; entity names singular; repository interfaces in domain, impls in data.

See also
- `ENTITIES.md` for domain Entity conventions.
- `ENTITY_PARSERS.md` for parser-specific guidance (mixins, mapping, multiple sources, testing tips).
- `REPOSITORIES.md` for repository patterns (mixins, DioRepository, custom methods, testing tips).
