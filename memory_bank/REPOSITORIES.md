# Repositories in fk_booster (Complete Guide)

## Purpose
- Explain WHAT Repositories are and HOW to implement them using fk_booster architecture.
- Copy-and-paste friendly: safe to use in other projects without full source visibility.
- Repositories are responsible for accessing external data sources (APIs, databases, cache) in a correct and structured way.

## Summary
- **Repositories** are the bridge between domain logic and external data sources (API, DB, cache).
- **Domain layer** defines the repository contract (abstract interface) specifying WHAT operations are available.
- **Data layer** implements the repository, using parsers and HTTP clients (Dio, HTTP, etc.) to perform the actual I/O.
- Use **mixins** to declare standard CRUD operations (Create, GetById, GetAll, Update, Delete) in your domain contracts.
- Extend **base repository classes** like `DioRepository` to inherit common HTTP logic, then implement your specific contract.

---

## Architecture and Placement

### Domain (Contract)
- **Path**: `lib/app/features/<feature>/domain/repository/<feature>_repository.dart`
- **Purpose**: Define the abstract interface that declares what operations this feature's repository must provide.
- **Class naming**: `<FeatureName>Repository` (abstract class)
- **What to include**:
  - Abstract class extending `Repository<Entity>` from `fk_booster/domain/domain.dart`
  - Mixin the CRUD operations you need: `Create`, `GetById`, `GetAll`, `Update`, `Delete`
  - Add any custom methods specific to your feature

### Data (Implementation)
- **Path**: `lib/app/features/<feature>/data/repository/<feature>_api_repository.dart` (or `_db_repository.dart`, `_cache_repository.dart`)
- **Purpose**: Concrete implementation that fulfills the domain contract using a specific data source.
- **Class naming**: `<FeatureName>ApiRepository`, `<FeatureName>DbRepository`, etc.
- **What to include**:
  - Extend a base repository class (e.g., `DioRepository<Entity>`)
  - Implement your domain contract (e.g., `implements <FeatureName>Repository`)
  - Override methods to delegate to `raw*` methods provided by the base class
  - Inject dependencies via constructor (HTTP client, parsers, etc.)

---

## Available Repository Mixins (Domain Layer)

These mixins are provided by `fk_booster/domain/domain.dart` to standardize CRUD operations in your repository contracts.

### `Create<Entity, Response>`
Declares an entity creation operation.
```dart
mixin Create<Entity, Response> {
  Future<Response> create(Entity entity);
}
```
- **Entity**: The domain entity type to create
- **Response**: The type returned after creation (often the created Entity, or a success/error type)
- **Use when**: Your feature needs to create new records (POST)

### `GetById<Entity, IdType>`
Declares a fetch-by-ID operation.
```dart
mixin GetById<Entity, IdType> {
  Future<Entity> getById(IdType id);
}
```
- **Entity**: The domain entity type to retrieve
- **IdType**: The type of the identifier (e.g., `String`, `int`)
- **Use when**: Your feature needs to fetch a single record by unique identifier (GET /resource/:id)

### `GetAll<Entity>`
Declares a fetch-all operation.
```dart
mixin GetAll<Entity> {
  Future<List<Entity>> getAll();
}
```
- **Entity**: The domain entity type
- **Returns**: A list of all entities
- **Use when**: Your feature needs to retrieve multiple records (GET /resource)

### `Update<Entity, Response>`
Declares an entity update operation.
```dart
mixin Update<Entity, Response> {
  Future<Response> update(Entity entity);
}
```
- **Entity**: The domain entity type to update
- **Response**: The type returned after update (often the updated Entity)
- **Use when**: Your feature needs to modify existing records (PUT/PATCH)

### `Delete<Entity, Response>`
Declares an entity deletion operation.
```dart
mixin Delete<Entity, Response> {
  Future<Response> delete(Entity entity);
}
```
- **Entity**: The domain entity type to delete
- **Response**: The type returned after deletion (often the deleted Entity, or void)
- **Use when**: Your feature needs to remove records (DELETE)

---

## Base Repository Classes (Data Layer)

### `Repository<Entity>` (Abstract Base)
The root abstract class for all repositories, located in `fk_booster/domain/repository/repository.dart`.

**Purpose**: Defines the low-level "raw" methods that handle the actual I/O logic.

**Key methods** (all abstract, to be implemented by concrete base classes like `DioRepository`):

```dart
abstract class Repository<Entity> {
  Future<TResponse> rawCreate<TResponse>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required FromMap<TResponse> responseParser,
  });

  Future<Entity> rawGetById<ID>({
    required ID id,
    required GetId<Entity, ID> idParser,
    required FromMap<Entity> entityParser,
  });

  Future<List<Entity>> rawGetAll({
    required FromMap<Entity> entityParser,
  });

  Future<TResponse> rawUpdate<TResponse, ID>({
    required Entity entity,
    required ToMap<Entity> entityParser,
    required GetId<Entity, ID> idParser,
    required FromMap<TResponse> responseParser,
  });

  Future<TResponse> rawDelete<TResponse, ID>({
    required Entity entity,
    required GetId<Entity, ID> idParser,
    required FromMap<TResponse> responseParser,
  });
}
```

**Why "raw" methods?**
- They require explicit parser arguments for every operation.
- Your feature-specific repository implementations call these raw methods, passing the appropriate parsers.
- This keeps the base class generic and reusable across different entities and data sources.

---

### `DioRepository<Entity>` (HTTP/REST Base)
A concrete base class for HTTP-based repositories using the Dio package, located in `fk_booster/data/repository/dio_repository.dart`.

**Purpose**: Provides a ready-to-use implementation of `Repository<Entity>` for RESTful APIs.

**Constructor**:
```dart
const DioRepository({required this.dio, required this.baseUrl});
final Dio dio;
final String baseUrl;
```

**URL customization** (override if needed):
```dart
String get createUrl => baseUrl;              // POST
String get getByIdUrl => '$baseUrl/:id';      // GET by ID
String get getAllUrl => baseUrl;              // GET all
String get updateUrl => '$baseUrl/:id';       // PUT/PATCH
String get deleteUrl => '$baseUrl/:id';       // DELETE
```
- The `:id` placeholder is automatically replaced with the entity's ID.

**Implementation details**:
- `rawCreate`: Performs `dio.post(createUrl, data: ...)` and parses the response.
- `rawGetById`: Performs `dio.get(getByIdUrl)` with ID substitution and parses the response.
- `rawGetAll`: Performs `dio.get(getAllUrl)`, expects a JSON array, and maps each item to an entity.
- `rawUpdate`: Performs `dio.put(updateUrl, data: ...)` with ID substitution and parses the response.
- `rawDelete`: Performs `dio.delete(deleteUrl)` with ID substitution and parses the response.

---

## How to Implement a Repository

### Step 1: Define the Domain Contract
Create an abstract repository interface in the domain layer.

**Path**: `lib/app/features/<feature>/domain/repository/<feature>_repository.dart`

```dart
import 'package:example/app/features/<feature>/domain/entity/<entity>_entity.dart';
import 'package:fk_booster/domain/domain.dart';

abstract class <FeatureName>Repository extends Repository<<EntityName>Entity>
    with
        Create<<EntityName>Entity, <EntityName>Entity>,
        GetAll<<EntityName>Entity>,
        GetById<<EntityName>Entity, String>,
        Delete<<EntityName>Entity, <EntityName>Entity> {}
```

**Notes**:
- Only mixin the operations you actually need.
- For `GetById`, specify the ID type (e.g., `String`, `int`).
- For `Create`, `Update`, `Delete`, specify the response type (often the Entity itself).
- You can add custom methods if standard CRUD is not enough:
  ```dart
  abstract class UserRepository extends Repository<UserEntity>
      with GetAll<UserEntity> {
    Future<List<UserEntity>> getActiveUsers();
  }
  ```

---

### Step 2: Implement the Repository in the Data Layer
Create a concrete implementation that extends a base class (e.g., `DioRepository`) and implements your domain contract.

**Path**: `lib/app/features/<feature>/data/repository/<feature>_api_repository.dart`

```dart
import 'package:example/app/features/<feature>/domain/entity/<entity>_entity.dart';
import 'package:example/app/features/<feature>/domain/entity/<entity>_entity_parser.dart';
import 'package:example/app/features/<feature>/domain/repository/<feature>_repository.dart';
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

  // If you have Update mixin:
  // @override
  // Future<<EntityName>Entity> update(<EntityName>Entity entity) => rawUpdate(
  //   entity: entity,
  //   entityParser: parser,
  //   idParser: parser,
  //   responseParser: parser,
  // );
}
```

**Key points**:
- **Constructor**: Inject `Dio` (via `super.dio`) and the entity parser. Set `baseUrl` to your API endpoint.
- **Parser**: The parser handles all serialization (toMap) and deserialization (fromMap). See `ENTITY_PARSERS.md` for details.
- **Method implementations**: Each mixin method (`create`, `getById`, etc.) calls the corresponding `raw*` method from `DioRepository`, passing the required parsers.
- **Custom URL overrides**: If your API has non-standard routes, override the URL getters:
  ```dart
  @override
  String get getAllUrl => '$baseUrl/active'; // custom endpoint
  ```

---

### Step 3: Register in Dependency Injection
Register your repository implementation in your DI container so it can be injected into ViewModels or UseCases.

**Example** (using `get_it`):
```dart
import 'package:example/app/features/<feature>/domain/repository/<feature>_repository.dart';
import 'package:example/app/features/<feature>/data/repository/<feature>_api_repository.dart';

// In your DI setup:
getIt.registerLazySingleton<<FeatureName>Repository>(
  () => <FeatureName>ApiRepository(
    dio: getIt<Dio>(),
    parser: getIt<<EntityName>EntityParser>(),
  ),
);
```

---

## Common Patterns and Best Practices

### 1. Use Parsers for All Serialization
- Never manually convert JSON to entities inside the repository.
- Always delegate to `parser.fromMap(...)` and `parser.toMap(...)`.
- This keeps repositories thin and testable.

### 2. One Repository Per Entity (Usually)
- Typically, one entity has one repository (e.g., `UserRepository` for `UserEntity`).
- If an entity has multiple data sources (API + local DB), create separate implementations:
  - `UserApiRepository`
  - `UserDbRepository`
- Both implement the same `UserRepository` contract.

### 3. Custom Methods Beyond CRUD
If you need operations that don't fit the standard mixins, add them to your domain contract:
```dart
abstract class UserRepository extends Repository<UserEntity>
    with GetAll<UserEntity>, GetById<UserEntity, String> {
  Future<List<UserEntity>> searchByName(String query);
  Future<void> updatePassword(String userId, String newPassword);
}
```

Then implement them in your data layer:
```dart
class UserApiRepository extends DioRepository<UserEntity>
    implements UserRepository {
  // ... standard implementations ...

  @override
  Future<List<UserEntity>> searchByName(String query) async {
    final response = await dio.get<dynamic>('$baseUrl/search', queryParameters: {'name': query});
    final list = response.data as List<dynamic>;
    return list.map((item) => parser.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> updatePassword(String userId, String newPassword) async {
    await dio.patch<dynamic>('$baseUrl/$userId/password', data: {'password': newPassword});
  }
}
```

### 4. Error Handling
- Let exceptions bubble up to the ViewModel/UseCase layer.
- If you need custom error handling, wrap calls in try-catch and throw domain-specific exceptions.
- Example:
  ```dart
  @override
  Future<UserEntity> getById(String id) async {
    try {
      return await rawGetById(id: id, idParser: parser, entityParser: parser);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw UserNotFoundException(id);
      }
      rethrow;
    }
  }
  ```

### 5. Testing Repositories
- Mock the `Dio` client (or HTTP client) in tests.
- Mock the parser if needed, or use real parsers for integration-style tests.
- Verify that the repository calls the correct HTTP methods with the correct URLs and data.

---

## Complete Example: User Repository

### Domain Contract
```dart
// lib/app/features/users/domain/repository/user_repository.dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/domain/domain.dart';

abstract class UserRepository extends Repository<UserEntity>
    with
        Create<UserEntity, UserEntity>,
        GetAll<UserEntity>,
        GetById<UserEntity, String>,
        Delete<UserEntity, UserEntity> {}
```

### Data Implementation
```dart
// lib/app/features/users/data/repository/user_api_repository.dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/data/data.dart';

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
}
```

### Dependency Injection
```dart
// lib/app/injection/dependency_injection.dart
import 'package:dio/dio.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:example/app/features/users/data/entity_parser/user_entity_api_parser.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:example/app/features/users/data/repository/user_api_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // HTTP client
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: 'https://api.example.com')));

  // Parser
  getIt.registerLazySingleton<UserEntityParser>(() => UserEntityApiParser());

  // Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserApiRepository(
      dio: getIt<Dio>(),
      parser: getIt<UserEntityParser>(),
    ),
  );
}
```

---

## Checklist: Adding a New Repository

- [ ] **Domain contract created**: `lib/app/features/<feature>/domain/repository/<feature>_repository.dart`
  - [ ] Extends `Repository<Entity>`
  - [ ] Mixins for needed CRUD operations (Create, GetById, GetAll, Update, Delete)
  - [ ] Custom methods declared if needed
- [ ] **Data implementation created**: `lib/app/features/<feature>/data/repository/<feature>_api_repository.dart`
  - [ ] Extends base repository (e.g., `DioRepository<Entity>`)
  - [ ] Implements domain contract
  - [ ] Constructor injects dependencies (HTTP client, parser)
  - [ ] `baseUrl` set correctly
  - [ ] All mixin methods implemented by calling `raw*` methods
  - [ ] Custom methods implemented if declared in contract
- [ ] **Parser created**: See `ENTITY_PARSERS.md` for parser setup
- [ ] **Registered in DI**: Repository, parser, and HTTP client all registered
- [ ] **Tested**: Unit/integration tests written for repository methods

---

## Summary
- **Domain repositories** define WHAT operations are available (abstract contracts with mixins).
- **Data repositories** define HOW to perform those operations (concrete implementations extending base classes).
- **Mixins** (Create, GetById, GetAll, Update, Delete) standardize CRUD operations.
- **Base classes** (Repository, DioRepository) provide reusable low-level logic.
- **Parsers** handle all serialization/deserialization (see `ENTITY_PARSERS.md`).
- **DI** wires everything together for runtime injection into ViewModels/UseCases.

For more details on Entities, see `ENTITIES.md`. For parsers, see `ENTITY_PARSERS.md`.

