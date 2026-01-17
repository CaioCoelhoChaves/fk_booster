# Dependency Injection Guide

## Overview
This guide explains the dependency injection (DI) system used in fk_booster. The DI system provides:
- **Scoped dependency management** per page or feature
- **Automatic lifecycle management** (creation and disposal)
- **Clean separation** between interface contracts and implementations
- **Integration with ViewState** for automatic wiring

**Technology**: This architecture uses **GetIt** as the DI container with scoped lifecycle management.

---

## Core Concepts

### Why Scoped DI?
Instead of having all dependencies in a single global container, fk_booster uses **scoped containers**:

- **Global Scope**: App-wide services (HTTP client, Router, Analytics) that live throughout the entire app lifecycle
- **Page Scopes**: Page-specific dependencies (ViewModels, Repositories, Parsers) that are created when a page opens and disposed when it closes

**Benefits**:
- ✅ Automatic memory management
- ✅ Clear dependency boundaries
- ✅ Isolated testing per page
- ✅ No dependency pollution between pages

### GetIt Scope Mechanism
fk_booster leverages GetIt's `pushNewScope` and `dropScope` features:

```dart
// Push a new scope when page opens
GetIt.instance.pushNewScope(scopeName: 'users');

// Register dependencies in this scope
GetIt.instance.registerLazySingleton<UserRepository>(...);

// Drop scope when page closes (automatically disposes all dependencies)
await GetIt.instance.dropScope('users');
```

---

## DependencyInjection Class

### Location in fk_booster
`lib/injection/dependency_injection.dart`

### Purpose
`DependencyInjection` is an abstract base class that defines a contract for creating scoped dependency containers. Each page or app-level module can have its own injection class.

### Implementation

```dart
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

abstract class DependencyInjection {
  const DependencyInjection(this.scopeName);
  final String scopeName;

  void registerDependencies(GetIt i) {
    i.pushNewScope(scopeName: scopeName);
    debugPrint('New scope pushed: $scopeName ================================');
  }

  Future<void> disposeDependencies(GetIt i) async {
    await i.dropScope(scopeName);
    debugPrint('Scope dropped: $scopeName ===================================');
  }
}
```

### Key Components

- **`scopeName`**: Unique identifier for the scope (e.g., 'users', 'create-user', 'Startup')
- **`registerDependencies`**: Creates new scope and registers all dependencies for this module
- **`disposeDependencies`**: Drops the scope and cleans up all registered dependencies

### Usage Pattern
Extend `DependencyInjection` and override `registerDependencies` to register your dependencies:

```dart
class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);  // MUST call super to push scope
    i
      ..registerLazySingleton<UserRepository>(...)
      ..registerLazySingleton<UsersViewModel>(...);
  }
}
```

---

## Injection Types

### 1. Startup Injection (Global Scope)

Used for app-wide dependencies that persist throughout the entire app lifecycle.

**File Location**: `lib/app/startup_injection.dart`

**Example**:
```dart
import 'package:example/app/router/router.dart';
import 'package:fk_booster/fk_booster.dart';

class StartupInjection extends DependencyInjection {
  const StartupInjection() : super('Startup');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i
      ..registerLazySingleton(
        () => Dio()
          ..options = BaseOptions(
            baseUrl: 'http://localhost:8000',
          ),
      )
      ..registerLazySingleton(AppRouter.new);
  }
}
```

**When to use StartupInjection**:
- HTTP clients (Dio, HttpClient)
- Navigation/Routing (GoRouter, AppRouter)
- Global state management (if any)
- Analytics services
- Logging services
- Database connections
- SharedPreferences or SecureStorage
- Any service that should persist across the entire app

**Registration**: Called once at app startup in `main.dart`:
```dart
void main() {
  final startup = StartupInjection();
  startup.registerDependencies(GetIt.instance);
  runApp(MyApp());
}
```

---

### 2. Page Injection (Scoped)

Used for page-specific dependencies that should be created when the page opens and disposed when it closes.

**File Pattern**: `lib/app/pages/<page_name>/<page_name>_injection.dart`

**Naming Convention**: `<PageName>Injection` (e.g., `UsersInjection`, `CreateUserInjection`)

#### Example 1: Users Page Injection

```dart
import 'package:example/app/features/users/data/entity_parser/user_entity_api_parser.dart';
import 'package:example/app/features/users/data/repository/user_api_repository.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i
      ..registerLazySingleton<UserEntityParser>(UserEntityApiParser.new)
      ..registerLazySingleton<UserRepository>(
        () => UserApiRepository(
          parser: i.get<UserEntityParser>(),
          dio: i.get<Dio>(),  // Retrieved from parent (Startup) scope
        ),
      )
      ..registerLazySingleton<UsersViewModel>(
        () => UsersViewModel(userRepository: i.get<UserRepository>()),
      );
  }
}
```

**Key Points**:
- Scope name is typically the page name in kebab-case: `'users'`, `'create-user'`
- Register domain interfaces (abstract classes) with data implementations (concrete classes)
- Can access dependencies from parent scopes (e.g., `Dio` from Startup scope)
- Always call `super.registerDependencies(i)` first

#### Example 2: Create User Page Injection

```dart
class CreateUserInjection extends DependencyInjection {
  CreateUserInjection() : super('create-user');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i
      ..registerLazySingleton<UserEntityParser>(UserEntityApiParser.new)
      ..registerLazySingleton<UserRepository>(
        () => UserApiRepository(
          parser: i.get<UserEntityParser>(),
          dio: i.get<Dio>(),
        ),
      )
      ..registerSingleton(CreateUserViewModel(i.get<UserRepository>()));
  }
}
```

---

## Registration Methods

GetIt provides different registration methods for different lifecycle needs:

### `registerLazySingleton`
- Dependency is created **only when first requested**
- Lives until scope is dropped
- Reused across multiple requests within the scope
- **Use for**: Repositories, Parsers, Services, most ViewModels

```dart
i.registerLazySingleton<UserRepository>(
  () => UserApiRepository(
    parser: i.get<UserEntityParser>(),
    dio: i.get<Dio>(),
  ),
);
```

**Best for**: Objects that should be created on-demand and reused.

---

### `registerSingleton`
- Dependency is created **immediately** when registered
- Lives until scope is dropped
- Instance is provided directly (not via factory function)
- **Use for**: ViewModels that need immediate initialization, pre-configured objects

```dart
i.registerSingleton(CreateUserViewModel(i.get<UserRepository>()));
```

**Best for**: Objects that must be initialized during registration.

---

### `registerFactory`
- Creates a **new instance** every time it's requested
- No caching, always fresh
- **Use for**: Temporary objects, value objects, ephemeral instances

```dart
i.registerFactory<UserEntity>(() => UserEntity.empty());
```

**Rarely used** in this architecture, but available when needed.

---

## Dependency Registration Pattern

### Order of Registration
Register dependencies in **dependency order** (dependencies before dependents):

```dart
@override
void registerDependencies(GetIt i) {
  super.registerDependencies(i);
  i
    // 1. Parsers (no dependencies beyond global ones)
    ..registerLazySingleton<UserEntityParser>(UserEntityApiParser.new)
    
    // 2. Repositories (depend on Parsers and global services)
    ..registerLazySingleton<UserRepository>(
      () => UserApiRepository(
        parser: i.get<UserEntityParser>(),
        dio: i.get<Dio>(),
      ),
    )
    
    // 3. ViewModels (depend on Repositories)
    ..registerLazySingleton<UsersViewModel>(
      () => UsersViewModel(userRepository: i.get<UserRepository>()),
    );
}
```

### Interface Registration Pattern
Always register by **interface type** and provide **concrete implementation**:

```dart
// ✅ Good - Register interface, provide implementation
i.registerLazySingleton<UserRepository>(  // ← interface type
  () => UserApiRepository(...),            // ← concrete implementation
);

// ❌ Bad - Registering concrete type directly
i.registerLazySingleton<UserApiRepository>(
  () => UserApiRepository(...),
);
```

**Why?** This enables:
- Easy mocking in tests
- Implementation swapping (e.g., API → Local)
- Dependency inversion principle

---

## Accessing Dependencies

### Within Same Scope
Use `i.get<T>()` to retrieve registered dependencies:

```dart
i.registerLazySingleton<UserRepository>(
  () => UserApiRepository(
    parser: i.get<UserEntityParser>(),  // Get from same scope
    dio: i.get<Dio>(),                  // Get from parent scope
  ),
);
```

### From Parent Scopes
GetIt automatically searches parent scopes if dependency is not found in current scope:

```dart
// In UsersInjection (child scope)
dio: i.get<Dio>(),  // Dio registered in StartupInjection (parent scope)
```

**Scope Hierarchy**:
```
Startup (global)
  └── users (page scope)
      └── Can access Dio from Startup
```

---

## Integration with ViewState

The DI system integrates automatically with `ViewState`. See the [VIEWSTATE.md](./VIEWSTATE.md) guide for details.

**Quick Overview**:
```dart
class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  DependencyInjection? get injection => UsersInjection();
  
  // ViewState automatically:
  // 1. Calls injection.registerDependencies() in initState
  // 2. Retrieves viewModel from GetIt
  // 3. Calls injection.disposeDependencies() in dispose
}
```

---

## Common Patterns

### Pattern 1: Shared Dependencies Across Pages

When multiple pages need the same repository:

**Option A: Register in each page (preferred for proper scoping)**
```dart
class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');
  
  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i.registerLazySingleton<UserRepository>(...);
  }
}

class CreateUserInjection extends DependencyInjection {
  CreateUserInjection() : super('create-user');
  
  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i.registerLazySingleton<UserRepository>(...);  // Same repo, different scope
  }
}
```

**Option B: Register globally (only if truly needed across entire app)**
```dart
class StartupInjection extends DependencyInjection {
  const StartupInjection() : super('Startup');
  
  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i.registerLazySingleton<UserRepository>(...);  // Available to all pages
  }
}
```

**Choose Option A** when repository is page-specific.  
**Choose Option B** when repository is truly global (e.g., AuthRepository, SettingsRepository).

---

### Pattern 2: Feature-Specific Injection

For complex features with multiple pages, you can create a feature-level injection:

```dart
class UsersFeatureInjection extends DependencyInjection {
  UsersFeatureInjection() : super('users-feature');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    i
      ..registerLazySingleton<UserEntityParser>(UserEntityApiParser.new)
      ..registerLazySingleton<UserRepository>(...);
    // Note: ViewModels still registered per page
  }
}

// Then each page can extend or reuse this
class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    // Parsers and Repositories come from parent scope if UsersFeatureInjection is registered
    i.registerLazySingleton<UsersViewModel>(...);
  }
}
```

**Note**: This is an advanced pattern, use sparingly.

---

### Pattern 3: Testing with Mock Dependencies

Override dependencies in tests:

```dart
void main() {
  late MockUserRepository mockRepository;
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.instance;
    mockRepository = MockUserRepository();
    
    // Register mock in test scope
    getIt.pushNewScope(scopeName: 'test-users');
    getIt.registerSingleton<UserRepository>(mockRepository);
    getIt.registerSingleton(UsersViewModel(userRepository: mockRepository));
  });

  tearDown(() async {
    await getIt.dropScope('test-users');
  });

  testWidgets('UsersPage displays users', (tester) async {
    when(() => mockRepository.getAll()).thenAnswer((_) async => [testUser]);
    
    await tester.pumpWidget(MaterialApp(home: UsersPage()));
    await tester.pumpAndSettle();
    
    expect(find.text(testUser.name), findsOneWidget);
  });
}
```

---

## Best Practices

### ✅ DO

1. **Use descriptive scope names**
   ```dart
   UsersInjection() : super('users');
   CreateUserInjection() : super('create-user');
   ```

2. **Always call `super.registerDependencies(i)`**
   ```dart
   @override
   void registerDependencies(GetIt i) {
     super.registerDependencies(i);  // ← CRITICAL
     // Your registrations...
   }
   ```

3. **Register interfaces, provide implementations**
   ```dart
   i.registerLazySingleton<UserRepository>(  // ← interface
     () => UserApiRepository(...),            // ← implementation
   );
   ```

4. **Keep injection classes lightweight**
   - Only registration logic
   - No business logic
   - No UI code

5. **Register in dependency order**
   - Parsers first
   - Repositories second
   - ViewModels last

### ❌ DON'T

1. **Don't register page dependencies globally**
   ```dart
   // ❌ Bad - in StartupInjection
   i.registerSingleton(UsersViewModel(...));
   
   // ✅ Good - in UsersInjection
   i.registerLazySingleton<UsersViewModel>(...);
   ```

2. **Don't forget to call super**
   ```dart
   // ❌ Bad - scope won't be created
   @override
   void registerDependencies(GetIt i) {
     i.registerLazySingleton<UserRepository>(...);
   }
   
   // ✅ Good
   @override
   void registerDependencies(GetIt i) {
     super.registerDependencies(i);
     i.registerLazySingleton<UserRepository>(...);
   }
   ```

3. **Don't create circular dependencies**
   ```dart
   // ❌ Bad - A depends on B, B depends on A
   i.registerLazySingleton<ServiceA>(() => ServiceA(i.get<ServiceB>()));
   i.registerLazySingleton<ServiceB>(() => ServiceB(i.get<ServiceA>()));
   ```

4. **Don't manually call dispose on dependencies**
   - GetIt handles disposal automatically when scope is dropped
   - ViewState calls `disposeDependencies` automatically

---

## Troubleshooting

### Error: "Object/factory with type X is not registered"

**Cause**: Dependency not registered in the current or parent scope.

**Solution**: Add registration in your injection class:
```dart
@override
void registerDependencies(GetIt i) {
  super.registerDependencies(i);
  i.registerLazySingleton<MissingType>(...);  // Add this
}
```

### Error: "Cannot find scope X"

**Cause**: Trying to drop a scope that wasn't created.

**Solution**: Ensure `super.registerDependencies(i)` is called:
```dart
@override
void registerDependencies(GetIt i) {
  super.registerDependencies(i);  // ← This pushes the scope
  // ...
}
```

### Error: "Scope X already exists"

**Cause**: Trying to push a scope with a name that already exists.

**Solutions**:
1. Ensure scope was properly dropped before trying to create it again
2. Use unique scope names per page
3. Check if page is being created multiple times without proper disposal

### Dependencies Persist Between Page Navigations

**Cause**: Scope not being dropped properly.

**Solution**: Ensure you're using `ViewState` which automatically handles scope disposal. See [VIEWSTATE.md](./VIEWSTATE.md).

---

## Lifecycle Diagram

```
App Startup
  │
  ├─── StartupInjection.registerDependencies()
  │       └─── GetIt.pushNewScope('Startup')
  │               ├─── Register Dio
  │               ├─── Register Router
  │               └─── Register global services
  │
User navigates to UsersPage
  │
  ├─── UsersInjection.registerDependencies()
  │       └─── GetIt.pushNewScope('users')
  │               ├─── Register UserEntityParser
  │               ├─── Register UserRepository
  │               └─── Register UsersViewModel
  │
  ├─── ViewState retrieves UsersViewModel from GetIt
  │
  ├─── Page renders with ViewModel
  │
User navigates away from UsersPage
  │
  └─── UsersInjection.disposeDependencies()
          └─── GetIt.dropScope('users')
                  ├─── Dispose UsersViewModel
                  ├─── Dispose UserRepository
                  └─── Dispose UserEntityParser
```

---

## Summary

**DependencyInjection**:
- Abstract base class for scoped DI containers
- Uses GetIt's scope mechanism for lifecycle management
- Each page has its own injection class
- Automatically integrates with ViewState

**Key Benefits**:
- ✅ Automatic memory management
- ✅ Clear dependency boundaries
- ✅ Easy testing with mocks
- ✅ Clean architecture enforcement
- ✅ No manual cleanup required

**Core Principle**: Dependencies are scoped to their usage context and automatically cleaned up when no longer needed.

**Next Steps**: See [VIEWSTATE.md](./VIEWSTATE.md) to understand how ViewState integrates with this DI system.

