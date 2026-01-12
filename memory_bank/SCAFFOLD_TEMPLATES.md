fk_booster Scaffold Templates

Use these copy-ready templates to add features and pages in projects that consume fk_booster. Replace placeholders with your names.

New Feature: `<feature_name>`
Folders
- `lib/app/features/<feature_name>/domain/entity/`
- `lib/app/features/<feature_name>/domain/repository/`
- `lib/app/features/<feature_name>/data/entity_parser/`
- `lib/app/features/<feature_name>/data/repository/`

Domain entity (example outline)
```dart
// lib/app/features/<feature_name>/domain/entity/<entity_name>.dart
class <EntityName> {
  // ...fields...
  const <EntityName>({ /* ... */ });
  // ...equality, copy, etc.
}
```

Domain repository interface (example outline)
```dart
// lib/app/features/<feature_name>/domain/repository/<feature_name>_repository.dart
abstract class <FeatureName>Repository {
  // Define methods returning domain types
  // Future<List<<EntityName>>> fetchAll();
  // Future<void> create(<EntityName> entity);
}
```

Parser (example outline)
```dart
// lib/app/features/<feature_name>/data/entity_parser/<entity_name>_parser.dart
import '../../domain/entity/<entity_name>.dart';

class <EntityName>Parser {
  <EntityName> fromJson(Map<String, dynamic> json) {
    // ...map fields...
    return <EntityName>(/* ... */);
  }

  Map<String, dynamic> toJson(<EntityName> entity) {
    // ...map fields...
    return {/* ... */};
  }
}
```

Repository implementation (example outline)
```dart
// lib/app/features/<feature_name>/data/repository/<feature_name>_repository_impl.dart
import '../../domain/repository/<feature_name>_repository.dart';
import '../entity_parser/<entity_name>_parser.dart';

class <FeatureName>RepositoryImpl implements <FeatureName>Repository {
  final <EntityName>Parser _parser;
  // Inject IO clients (e.g., http, db) here

  <FeatureName>RepositoryImpl(this._parser);

  // @override
  // Future<List<<EntityName>>> fetchAll() async {
  //   final raw = await _client.get(...);
  //   return (raw as List).map((j) => _parser.fromJson(j)).toList();
  // }
}
```

New Page: `<page_name>`
Folders
- `lib/app/pages/<page_name>/`

Injection (example outline)
```dart
// lib/app/pages/<page_name>/<page_name>_injection.dart
import 'package:fk_booster/fk_booster.dart';
import '../../features/<feature_name>/domain/repository/<feature_name>_repository.dart';
import '../../features/<feature_name>/data/repository/<feature_name>_repository_impl.dart';
import '../../features/<feature_name>/data/entity_parser/<entity_name>_parser.dart';
import '<page_name>_view_model.dart';

<FeatureName>Repository make<FeatureName>Repository() {
  return <FeatureName>RepositoryImpl(<EntityName>Parser());
}

<PageName>ViewModel make<PageName>ViewModel() {
  return <PageName>ViewModel(repo: make<FeatureName>Repository());
}
```

ViewModel (example outline)
```dart
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
```dart
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

