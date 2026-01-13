# ViewState and ViewModel Guide

## Overview
This guide explains the `ViewState` pattern and its integration with `ViewModel` in fk_booster. These components work together with the [Dependency Injection system](./DEPENDENCY_INJECTION.md) to provide:
- **Automatic DI lifecycle management** in Flutter widgets
- **ViewModel binding** and retrieval
- **Lifecycle hooks** for initialization and disposal
- **Clean separation** between UI and business logic

**Key Insight**: `ViewState` is a specialized replacement for Flutter's `State<T>` that understands dependency injection and ViewModels.

---

## ViewState Class

### Location in fk_booster
`lib/presentation/view_state.dart`

### Purpose
`ViewState` extends Flutter's `State<T>` to automatically:
1. Register and dispose dependency injection scopes
2. Retrieve ViewModels from GetIt
3. Call ViewModel lifecycle hooks
4. Provide convenient shortcuts (e.g., `textTheme`)

### Why Not Use Regular State?
Regular Flutter `State<T>` doesn't know about:
- Dependency injection scopes
- ViewModel lifecycle management
- Automatic cleanup of page-specific dependencies

`ViewState` handles all of this automatically, reducing boilerplate and preventing memory leaks.

---

## Implementation

### Full ViewState Code

```dart
import 'dart:async';
import 'package:fk_booster/injection/dependency_injection.dart';
import 'package:fk_booster/presentation/view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class ViewState<T extends StatefulWidget, V extends ViewModel>
    extends State<T> {
  late final V viewModel;
  final GetIt _getIt = GetIt.instance;
  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    injection?.registerDependencies(_getIt);
    initViewModel();
    viewModel.onViewInit();
  }

  void initViewModel() => viewModel = _getIt.get<V>();

  @override
  Widget build(BuildContext context);

  @override
  Future<void> dispose() async {
    super.dispose();
    viewModel.onViewDispose();
    await injection?.disposeDependencies(_getIt);
  }

  DependencyInjection? get injection => null;
}
```

### Type Parameters

- **`T extends StatefulWidget`**: The page widget type (e.g., `UsersPage`)
- **`V extends ViewModel`**: The ViewModel type that will be automatically retrieved (e.g., `UsersViewModel`)

### Key Properties

- **`viewModel`**: Automatically retrieved ViewModel instance from GetIt
- **`_getIt`**: Reference to GetIt instance for DI operations
- **`textTheme`**: Convenience getter for accessing Theme's TextTheme
- **`injection`**: Override this to provide page-specific DI

---

## Lifecycle Flow

### 1. initState()
Called when the widget is inserted into the tree.

```dart
@override
void initState() {
  super.initState();
  injection?.registerDependencies(_getIt);  // 1. Register DI scope
  initViewModel();                           // 2. Retrieve ViewModel
  viewModel.onViewInit();                    // 3. Initialize ViewModel
}
```

**Detailed Steps**:
1. **`injection?.registerDependencies(_getIt)`**
   - If `injection` is not null, creates a new GetIt scope
   - Registers all page-specific dependencies (Parsers, Repositories, ViewModel)
   - See [DEPENDENCY_INJECTION.md](./DEPENDENCY_INJECTION.md) for details

2. **`initViewModel()`**
   - Retrieves ViewModel from GetIt: `viewModel = _getIt.get<V>()`
   - ViewModel must be registered in the injection class

3. **`viewModel.onViewInit()`**
   - Calls ViewModel's initialization hook
   - Use this to fetch initial data, set up listeners, etc.

---

### 2. build()
Called to render the UI. Must be implemented by subclass.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Users')),
    body: CommandBuilder(
      command: viewModel.getAll,  // Access ViewModel properties
      loadingBuilder: (_) => CircularProgressIndicator(),
      completedBuilder: (state) => ListView(...),
    ),
  );
}
```

**Access**:
- `viewModel`: Access ViewModel properties and methods
- `context`: Standard Flutter BuildContext
- `textTheme`: Shortcut to Theme.of(context).textTheme

---

### 3. dispose()
Called when the widget is permanently removed from the tree.

```dart
@override
Future<void> dispose() async {
  super.dispose();
  viewModel.onViewDispose();                 // 1. Cleanup ViewModel
  await injection?.disposeDependencies(_getIt);  // 2. Drop DI scope
}
```

**Detailed Steps**:
1. **`viewModel.onViewDispose()`**
   - Calls ViewModel's cleanup hook
   - Use this to cancel subscriptions, close streams, etc.

2. **`injection?.disposeDependencies(_getIt)`**
   - If `injection` is not null, drops the GetIt scope
   - Automatically disposes all dependencies in the scope

**Important**: GetIt handles disposal of registered dependencies automatically. You don't need to manually dispose repositories or parsers.

---

## ViewModel Interface

### Location in fk_booster
`lib/presentation/view_model.dart`

### Base Interface

```dart
abstract interface class ViewModel {
  void onViewInit();
  void onViewDispose();
}
```

All ViewModels must implement these lifecycle hooks, which are called automatically by `ViewState`.

---

### StatelessViewModel

For ViewModels that don't manage state directly (use Commands instead).

```dart
abstract class StatelessViewModel implements ViewModel {
  const StatelessViewModel();

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}
}
```

**Use when**:
- ViewModel only coordinates Commands
- No internal state to manage
- Most common case

**Example**:
```dart
class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  @override
  void onViewInit() {
    unawaited(getAll.execute());  // Fetch data when view initializes
  }
}
```

---

### StatefulViewModel<State>

For ViewModels that manage internal state (forms, filters, selections).

```dart
abstract class StatefulViewModel<State> extends Signal<State>
    implements StatelessViewModel {
  StatefulViewModel(super.internalValue);

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}
}
```

**Type Parameter**: `State` - The type of state being managed (e.g., `UserEntity` for a form)

**Use when**:
- ViewModel manages form state
- ViewModel manages UI state (filters, selections, etc.)
- Need reactive state updates

**Example**:
```dart
class CreateUserViewModel extends StatefulViewModel<UserEntity> {
  CreateUserViewModel(this._userRepository) : super(const UserEntity.empty());
  
  final UserRepository _userRepository;
  final formKey = GlobalKey<FormState>();

  Future<void> onSavePressed() async {
    if (formKey.currentState!.validate()) {
      await _userRepository.create(value);  // `value` is the current state
    }
  }
}
```

**State Access**:
- `value`: Get/set current state
- Extends `Signal`, so UI automatically rebuilds when state changes

---

### NoneViewModel

Placeholder ViewModel when no ViewModel is needed.

```dart
class NoneViewModel extends StatelessViewModel {}
```

**Use when**: Page doesn't need a ViewModel (very rare).

---

## Creating Pages with ViewState

### Basic Page Structure

```dart
import 'package:example/app/pages/users/users_injection.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: CommandBuilder(
        command: viewModel.getAll,
        loadingBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        completedBuilder: (state) => ListView.builder(
          itemCount: state.data.length,
          itemBuilder: (context, index) {
            final user = state.data[index];
            return ListTile(
              title: Text(user.name ?? 'Unknown'),
              subtitle: Text(user.email ?? 'No email'),
            );
          },
        ),
        errorBuilder: (state) => Center(
          child: Text('Error: ${state.error}'),
        ),
      ),
    );
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
```

### Key Points

1. **Page Widget is StatefulWidget**
   ```dart
   class UsersPage extends StatefulWidget {
     const UsersPage({super.key});
     
     @override
     State<UsersPage> createState() => _UsersPageState();
   }
   ```

2. **State extends ViewState, not State**
   ```dart
   class _UsersPageState extends ViewState<UsersPage, UsersViewModel>
   ```

3. **Specify both type parameters**
   - First: Your StatefulWidget class (`UsersPage`)
   - Second: Your ViewModel class (`UsersViewModel`)

4. **Override injection getter**
   ```dart
   @override
   DependencyInjection? get injection => UsersInjection();
   ```
   - Return a **new instance** of your injection class
   - Return `null` if page has no specific dependencies

5. **Access ViewModel in build**
   ```dart
   viewModel.getAll        // Access properties
   viewModel.someMethod()  // Call methods
   ```

---

## Complete Integration Example

### Scenario: Users List Page

#### 1. Create ViewModel
**File**: `lib/app/pages/users/users_view_model.dart`
```dart
import 'dart:async';
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/fk_booster.dart';

class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  @override
  void onViewInit() {
    unawaited(getAll.execute());  // Fetch users when page opens
  }
}
```

#### 2. Create Injection
**File**: `lib/app/pages/users/users_injection.dart`
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
          dio: i.get<Dio>(),
        ),
      )
      ..registerLazySingleton<UsersViewModel>(
        () => UsersViewModel(userRepository: i.get<UserRepository>()),
      );
  }
}
```

#### 3. Create Page
**File**: `lib/app/pages/users/users_page.dart`
```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/pages/users/users_injection.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('create-user'),
        child: const Icon(Icons.add),
      ),
      body: CommandBuilder(
        command: viewModel.getAll,
        loadingBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        completedBuilder: (state) => Visibility(
          visible: state.data.isNotEmpty,
          replacement: const Center(
            child: Text('No users found'),
          ),
          child: ListView.builder(
            itemCount: state.data.length,
            itemBuilder: (context, index) {
              final user = state.data[index];
              return ListTile(
                title: Text(user.name ?? 'Unknown'),
                subtitle: Text(user.email ?? 'No email'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteUser(user),
                ),
              );
            },
          ),
        ),
        errorBuilder: (state) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.error}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.getAll.execute,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteUser(UserEntity user) {
    // TODO: Implement delete
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
```

---

## Execution Flow Diagram

```
User navigates to UsersPage
  │
  ├─── Flutter creates UsersPage widget
  │       └─── createState() → _UsersPageState (ViewState)
  │
  ├─── ViewState.initState()
  │       │
  │       ├─── injection?.registerDependencies(GetIt.instance)
  │       │       └─── UsersInjection.registerDependencies()
  │       │               ├─── GetIt.pushNewScope('users')
  │       │               ├─── Register UserEntityParser
  │       │               ├─── Register UserRepository
  │       │               └─── Register UsersViewModel
  │       │
  │       ├─── initViewModel()
  │       │       └─── viewModel = GetIt.instance.get<UsersViewModel>()
  │       │
  │       └─── viewModel.onViewInit()
  │               └─── getAll.execute() → Fetches users from API
  │
  ├─── ViewState.build(context)
  │       └─── Renders Scaffold with CommandBuilder
  │               └─── CommandBuilder listens to getAll state
  │                       ├─── Loading → Shows CircularProgressIndicator
  │                       ├─── Completed → Shows ListView with users
  │                       └─── Error → Shows error message
  │
User navigates away from UsersPage
  │
  └─── ViewState.dispose()
          │
          ├─── viewModel.onViewDispose()
          │       └─── Cleanup (if any)
          │
          └─── injection?.disposeDependencies(GetIt.instance)
                  └─── UsersInjection.disposeDependencies()
                          └─── GetIt.dropScope('users')
                                  ├─── Dispose UsersViewModel
                                  ├─── Dispose UserRepository
                                  └─── Dispose UserEntityParser
```

---

## Common Patterns

### Pattern 1: Page Without Injection

If page only uses global dependencies (registered in StartupInjection):

```dart
class SimplePage extends StatefulWidget {
  const SimplePage({super.key});

  @override
  State<SimplePage> createState() => _SimplePageState();
}

class _SimplePageState extends ViewState<SimplePage, SimpleViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Simple Page'),
    );
  }

  @override
  DependencyInjection? get injection => null;  // No page-specific dependencies
}
```

**Requirements**:
- `SimpleViewModel` must be registered in `StartupInjection`
- Or use `NoneViewModel` if no ViewModel needed

---

### Pattern 2: ViewModel with Form State

When ViewModel manages form state using `StatefulViewModel`:

**ViewModel**:
```dart
class CreateUserViewModel extends StatefulViewModel<UserEntity> {
  CreateUserViewModel(this._userRepository) : super(const UserEntity.empty());
  
  final UserRepository _userRepository;
  final formKey = GlobalKey<FormState>();

  Future<void> onSavePressed() async {
    if (formKey.currentState!.validate()) {
      await _userRepository.create(value);
    }
  }
}
```

**Page**:
```dart
class _CreateUserPageState extends ViewState<CreateUserPage, CreateUserViewModel> {
  UserEntity get form => viewModel.value;  // Shortcut to current state
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(label: Text('Name')),
              onChanged: (value) => viewModel.value = form.copyWith(
                name: value,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text('Email')),
              onChanged: (value) => viewModel.value = form.copyWith(
                email: value,
              ),
            ),
            ElevatedButton(
              onPressed: viewModel.onSavePressed,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  DependencyInjection? get injection => CreateUserInjection();
}
```

**Key Points**:
- `viewModel.value` gets/sets current state
- State changes trigger UI rebuild automatically (Signal behavior)
- Form key stored in ViewModel for validation

---

### Pattern 3: Custom initState

When you need custom initialization logic:

```dart
class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();  // MUST call super first (DI + ViewModel setup)
    
    // Your custom initialization
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Custom scroll handling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: [...],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _scrollController.dispose();  // Clean up custom resources
    await super.dispose();  // MUST call super last (ViewModel + DI cleanup)
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
```

**Critical Order**:
- **initState**: Call `super.initState()` **FIRST**
- **dispose**: Call `super.dispose()` **LAST**

---

### Pattern 4: Accessing Theme and Context

ViewState provides convenient access to theme:

```dart
class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            'Users',
            style: textTheme.headlineMedium,  // Using ViewState's textTheme
          ),
          Text(
            'Subtitle',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
```

**Available**:
- `textTheme`: Shortcut to `Theme.of(context).textTheme`
- `context`: Standard BuildContext

---

## Best Practices

### ✅ DO

1. **Always extend ViewState, not State**
   ```dart
   class _UsersPageState extends ViewState<UsersPage, UsersViewModel>
   ```

2. **Specify both type parameters correctly**
   ```dart
   ViewState<UsersPage, UsersViewModel>
   //        ↑ Widget    ↑ ViewModel
   ```

3. **Override injection getter**
   ```dart
   @override
   DependencyInjection? get injection => UsersInjection();
   ```

4. **Call super.initState() FIRST in custom initState**
   ```dart
   @override
   void initState() {
     super.initState();  // FIRST
     // Your code...
   }
   ```

5. **Call super.dispose() LAST in custom dispose**
   ```dart
   @override
   Future<void> dispose() async {
     // Your cleanup...
     await super.dispose();  // LAST
   }
   ```

6. **Use ViewModel lifecycle hooks**
   ```dart
   @override
   void onViewInit() {
     // Initialize data, start subscriptions
   }
   
   @override
   void onViewDispose() {
     // Cancel subscriptions, close streams
   }
   ```

### ❌ DON'T

1. **Don't use State<T>, use ViewState<T, V>**
   ```dart
   // ❌ Bad
   class _UsersPageState extends State<UsersPage>
   
   // ✅ Good
   class _UsersPageState extends ViewState<UsersPage, UsersViewModel>
   ```

2. **Don't create ViewModel manually**
   ```dart
   // ❌ Bad
   late final viewModel = UsersViewModel(...);
   
   // ✅ Good - ViewState retrieves it automatically
   // Just use: viewModel.someProperty
   ```

3. **Don't forget to override injection**
   ```dart
   // ❌ Bad - Will cause ViewModel not found error
   class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
     // Missing injection getter
   }
   
   // ✅ Good
   @override
   DependencyInjection? get injection => UsersInjection();
   ```

4. **Don't manually dispose ViewModel**
   ```dart
   // ❌ Bad
   @override
   Future<void> dispose() async {
     viewModel.dispose();  // ViewState handles this
     await super.dispose();
   }
   ```

5. **Don't access viewModel before super.initState()**
   ```dart
   // ❌ Bad
   @override
   void initState() {
     viewModel.someMethod();  // viewModel not initialized yet!
     super.initState();
   }
   
   // ✅ Good
   @override
   void initState() {
     super.initState();  // Initializes viewModel
     viewModel.someMethod();  // Now safe to use
   }
   ```

---

## Troubleshooting

### Error: "Late initialization error: viewModel has not been initialized"

**Cause**: Accessing `viewModel` before `super.initState()` is called.

**Solution**: Always call `super.initState()` first:
```dart
@override
void initState() {
  super.initState();  // ← Initialize viewModel
  viewModel.someMethod();  // ← Now safe
}
```

---

### Error: "Object/factory with type UsersViewModel is not registered"

**Cause**: ViewModel not registered in injection class.

**Solution**: Add ViewModel registration:
```dart
@override
void registerDependencies(GetIt i) {
  super.registerDependencies(i);
  i.registerLazySingleton<UsersViewModel>(
    () => UsersViewModel(...),
  );
}
```

---

### Error: "injection getter returns null but ViewModel is not found"

**Cause**: ViewModel is not registered globally and injection is null.

**Solution Options**:
1. Override injection getter:
   ```dart
   @override
   DependencyInjection? get injection => UsersInjection();
   ```
2. Or register ViewModel in `StartupInjection` (if truly global)

---

### Memory Leaks / Dependencies Not Cleaning Up

**Cause**: Not using ViewState or not calling super.dispose().

**Solution**: 
1. Ensure State extends ViewState:
   ```dart
   class _YourPageState extends ViewState<YourPage, YourViewModel>
   ```
2. If overriding dispose, call super.dispose() last:
   ```dart
   @override
   Future<void> dispose() async {
     // Your cleanup
     await super.dispose();  // ← MUST call
   }
   ```

---

## Integration with Commands

ViewState works seamlessly with fk_booster's Command system. Commands are typically defined in ViewModels and rendered with `CommandBuilder`:

**ViewModel**:
```dart
class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );
}
```

**Page**:
```dart
class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  Widget build(BuildContext context) {
    return CommandBuilder(
      command: viewModel.getAll,  // Command from ViewModel
      loadingBuilder: (_) => CircularProgressIndicator(),
      completedBuilder: (state) => ListView(...),
      errorBuilder: (state) => ErrorWidget(state.error),
    );
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
```

For more on Commands, see the Commands documentation (if available in memory bank).

---

## Summary

**ViewState**:
- Extends Flutter's `State<T>` with DI integration
- Automatically manages DI scope lifecycle
- Retrieves and binds ViewModel
- Calls ViewModel lifecycle hooks
- Provides convenient shortcuts (textTheme)

**ViewModel**:
- Base interface with lifecycle hooks (`onViewInit`, `onViewDispose`)
- `StatelessViewModel`: For ViewModels without internal state
- `StatefulViewModel<T>`: For ViewModels managing state (forms, filters)
- Accessed via `viewModel` property in ViewState

**Together**, they provide:
- ✅ Automatic DI integration
- ✅ Clean lifecycle management
- ✅ Separation of UI and business logic
- ✅ Reduced boilerplate
- ✅ Testable architecture

**Key Principle**: ViewState bridges the gap between Flutter's widget lifecycle and fk_booster's DI + ViewModel architecture, handling all the wiring automatically.

**See Also**: [DEPENDENCY_INJECTION.md](./DEPENDENCY_INJECTION.md) for details on the DI system that ViewState integrates with.

