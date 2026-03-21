---
trigger: model_decision
description: When needing to understand the app expected architecture
---

---
name: "flutter-architecting-apps"
description: "Architects a Flutter application using the project's custom layered approach (UI/Presentation, Domain/Logic, Data). Use when structuring a new project or refactoring for scalability."

# Architecting Flutter Applications

## Contents
- [Core Architectural Principles](#core-architectural-principles)
- [Structuring the Layers](#structuring-the-layers)
- [Implementing the Data Layer](#implementing-the-data-layer)
- [Feature Implementation Workflow](#feature-implementation-workflow)
- [Examples](#examples)

## Core Architectural Principles

Design Flutter applications to scale by strictly adhering to the following principles:

*   **Enforce Separation of Concerns:** Decouple UI rendering from business logic and data fetching. Organize the codebase into distinct layers (UI/Presentation, Domain/Logic, Data) and further separate by feature within those layers.
*   **Maintain a Single Source of Truth (SSOT):** Centralize application state and data in the Data layer. Ensure the SSOT is the only component authorized to mutate its respective data.
*   **Implement Unidirectional Data Flow (UDF):** Flow state downwards from the Data layer to the UI layer. Flow events upwards from the UI layer to the Data layer.
*   **Treat UI as a Function of State:** Drive the UI entirely via reactive state objects (Signals, Commands). Rebuild widgets reactively when the underlying state changes.

## Structuring the Layers

Separate the application into 3 distinct layers. Restrict communication so that a layer only interacts with the layer directly adjacent to it.

```
features/
  <feature_name>/              # Business contracts only (no Flutter deps)
    domain/
      entity/
        <entity_name>_entity.dart
        <entity_name>_entity_parser.dart   # abstract parser interface
      repository/
        <entity_name>_repository.dart      # abstract repository interface
    data/                      # Concrete implementations
      entity_parser/
        <entity_name>_api_parser.dart
      repository/
        <entity_name>_api_repository.dart

pages/
  <page_name>/
    <page_name>_page.dart
    <page_name>_view_model.dart
    <page_name>_view_model_state.dart      # optional
    <page_name>_injection.dart
```

### 1. UI Layer (Presentation)

#### Page

Pages are the top-level screens of the application. They are always `StatefulWidget`s, but **must** replace `extends State<T>` with `extends ViewState<T, V>` from `fk_booster`.

*   **Location:** `pages/<page_name>/<page_name>_page.dart`
*   **Responsibility:** Render the UI and delegate all user interactions to the ViewModel.
*   **Rule:** Always a `StatefulWidget` whose `State` extends `ViewState<PageClass, ViewModelClass>`.
*   `ViewState` automatically resolves the ViewModel via `GetIt`, calls `onViewInit()` on creation and `onViewDispose()` on disposal.
*   Override `injection` to register page-scoped dependencies via a `DependencyInjection` class.

```dart
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ViewState<UserListPage, UserListViewModel> {
  @override
  DependencyInjection get injection => UserListInjection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: CommandBuilder<List<UserEntity>>(
        command: viewModel.fetchUsers,
        loadingBuilder: (_) => const CircularProgressIndicator(),
        errorBuilder: (_) => const Text('Error loading users.'),
        completedBuilder: (state) => ListView.builder(
          itemCount: state.data.length,
          itemBuilder: (_, i) => Text(state.data[i].name),
        ),
      ),
    );
  }
}
```

#### Widgets

Widgets used to compose the page UI should preferably be `StatelessWidget`. `StatefulWidget` is allowed when local ephemeral state is strictly required (e.g. animation controllers, focus nodes).

#### ViewModel

*   **Location:** `pages/<page_name>/<page_name>_view_model.dart`
*   **Responsibility:** Control UI state, execute API calls via `Command`, bridge state and the view, and handle user interaction events.
*   **Rule:** Must extend either `StatelessViewModel` or `StatefulViewModel<State>` from `fk_booster`.
  *   Use `StatelessViewModel` when the page state is fully managed through `Command` and/or `Signal` fields.
  *   Use `StatefulViewModel<State>` when a single reactive top-level state object is needed. `StatefulViewModel` extends `Signal<State>`, so the ViewModel itself is a listenable signal.
*   Lifecycle: override `onViewInit()` for initialisation logic, `onViewDispose()` for cleanup.

```dart
class UserListViewModel extends StatelessViewModel {
  UserListViewModel({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  late final Command0<List<UserEntity>> fetchUsers =
      Command0(_userRepository.getAll);

  @override
  void onViewInit() => fetchUsers.execute();
}
```

#### ViewModelState

*   **Location:** `pages/<page_name>/<page_name>_view_model_state.dart`
*   **Usage:** Optional. Use as the `State` generic type of a `StatefulViewModel` to hold multiple reactive fields in a single immutable value class.

#### Command

`Command` encapsulates an async API call and exposes its lifecycle as a reactive `Signal`:

| State | Meaning |
|-------|---------|
| `Initial` | Not yet executed |
| `Running` | Executing |
| `Completed<T>` | Successfully finished, holds `data` |
| `Error` | Failed, holds the exception |

*   Use `Command0<T>` for actions with no arguments.
*   Use `Command1<T, A>` for actions with one argument.
*   Listen to a `Command` in the UI using `CommandBuilder<T>`.

```dart
// In ViewModel
late final fetchUser = Command1<UserEntity, String>(_userRepository.getById);

// In Page (UI)
CommandBuilder<UserEntity>(
  command: viewModel.fetchUser,
  loadingBuilder: (_) => const CircularProgressIndicator(),
  errorBuilder: (s) => Text('Error: ${s.error}'),
  completedBuilder: (s) => Text('Hello, ${s.data.name}'),
);
```

### 2. Logic Layer (Domain)

Stores the application's contracts (repository interfaces) and entities. ViewModels interact with this layer directly through the repository interfaces.

#### Entity

*   All domain entities **must** extend `Entity` from `fk_booster` (which extends `Equatable`).
*   Entities must be immutable — use `final` fields and `const` constructors.

```dart
class UserEntity extends Entity {
  const UserEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
```

#### Repository (Domain Contract)

*   **Location:** `domain/repository/<entity_name>_repository.dart`
*   **Responsibility:** Define the contract (abstract interface) for data operations expected by the application.
*   **Rule:** Must extend `Repository<Entity>` from `fk_booster`. Use the provided operation mixins to define standard CRUD signatures.

| Mixin | Method signature |
|-------|-----------------|
| `Create<Entity, Response>` | `Future<Response> create(Entity entity)` |
| `Delete<Entity, Response>` | `Future<Response> delete(Entity entity)` |
| `GetAll<Entity>` | `Future<List<Entity>> getAll()` |
| `GetById<Entity, IdType>` | `Future<Entity> getById(IdType id)` |
| `Update<Entity, Response>` | `Future<Response> update(Entity entity)` |

```dart
abstract class UserRepository extends Repository<UserEntity>
    with
        Create<UserEntity, UserEntity>,
        Delete<UserEntity, UserEntity>,
        GetAll<UserEntity>,
        GetById<UserEntity, String>,
        Update<UserEntity, UserEntity> {}
```

Custom operations beyond standard CRUD may also be defined directly in the repository interface.

### 3. Data Layer (Model)

Handles all data traffic: concrete repository implementations and entity serialization/deserialization through `EntityParser` classes.

#### API Repository (Concrete Implementation)

*   **Location:** `data/repository/<entity_name>_api_repository.dart`
*   **Rule:** Must extend `DioRepository<Entity>` (the real HTTP implementation) **and** implement the domain repository interface.
*   `DioRepository` exposes `rawCreate`, `rawGetAll`, `rawGetById`, `rawUpdate`, `rawDelete` helpers that handle HTTP calls and delegate serialization to the provided parsers.

```dart
class UserApiRepository extends DioRepository<UserEntity>
    implements UserRepository {
  const UserApiRepository({
    required this.parser,
    required super.dio,
  }) : super(baseUrl: '/users');

  final UserEntityParser parser;

  @override
  Future<UserEntity> create(UserEntity entity) => rawCreate(
    entity: entity,
    entityParser: parser,
    responseParser: parser,
  );

  @override
  Future<UserEntity> delete(UserEntity entity) => rawDelete(
    entity: entity,
    idParser: parser,
    responseParser: parser,
  );

  @override
  Future<List<UserEntity>> getAll() => rawGetAll(entityParser: parser);

  @override
  Future<UserEntity> getById(String id) => rawGetById(
    id: id,
    idParser: parser,
    entityParser: parser,
  );

  @override
  Future<UserEntity> update(UserEntity entity) => rawUpdate(
    entity: entity,
    entityParser: parser,
    idParser: parser,
    responseParser: parser,
  );
}
```

#### EntityParser

*   **Responsibility:** Serialize (`toMap`) and deserialize (`fromMap`) entity data. Provides the entity ID to the repository (`getId`).
*   **Rule:** Must extend `EntityParser<Entity>` and compose the required behaviour with mixins:

| Mixin | Method | When to use |
|-------|--------|-------------|
| `FromMap<Entity>` | `Entity fromMap(JsonMap map)` | Deserializing API responses |
| `ToMap<Entity>` | `JsonMap toMap(Entity entity)` | Serializing entities for requests |
| `GetId<Entity, ID>` | `ID getId(Entity entity)` | Providing the ID for update/delete URLs |

```dart
class UserEntityParser extends EntityParser<UserEntity>
    with FromMap<UserEntity>, ToMap<UserEntity>, GetId<UserEntity, String> {
  const UserEntityParser();

  @override
  UserEntity fromMap(JsonMap map) => UserEntity(
    id: map['id'] as String,
    name: map['name'] as String,
  );

  @override
  JsonMap toMap(UserEntity entity) => {
    'id': entity.id,
    'name': entity.name,
  };

  @override
  String getId(UserEntity entity) => entity.id;
}
```

## Feature Implementation Workflow
Follow this sequential workflow when adding a new feature to the application.

**Task Progress:**
- [ ] **Step 1: Define the Entity.** Create an immutable Dart class extending `Entity` for the feature's core data structure.
- [ ] **Step 2: Create the EntityParser.** Implement `EntityParser` with the appropriate mixins (`FromMap`, `ToMap`, `GetId`) to handle serialization.
- [ ] **Step 3: Define the Domain Repository.** Create an abstract repository interface extending `Repository<Entity>` with the required CRUD operation mixins.
- [ ] **Step 4: Implement the API Repository.** Create a concrete class extending `DioRepository<Entity>` and implementing the domain repository. Use `rawCreate`, `rawGetAll`, etc., passing the `EntityParser`.
- [ ] **Step 5: Implement the ViewModel.** Create a ViewModel extending `StatelessViewModel` or `StatefulViewModel`. Expose `Command` fields for each async operation. Call initial commands in `onViewInit()`.
- [ ] **Step 6: Implement the Page.** Create a `StatefulWidget` whose state extends `ViewState<PageClass, ViewModelClass>`. Bind to Commands using `CommandBuilder`. Register dependencies via `injection`.
- [ ] **Step 7: Run Validator.** Execute unit tests for Repositories, EntityParsers, and ViewModels. Execute widget tests for Pages.
    *   *Feedback Loop:* Review test failures -> Fix logic/mocking errors -> Re-run tests until passing.