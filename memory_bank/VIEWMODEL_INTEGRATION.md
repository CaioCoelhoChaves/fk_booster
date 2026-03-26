# ViewModel Integration Guide

## Overview
This guide explains how **ViewState**, **ViewModel**, and **Commands** work together to create a complete, reactive page architecture in fk_booster.

**Key Concept**: The page's reactive behavior flows from three interconnected layers:
1. **ViewState** ← manages widget lifecycle and DI
2. **ViewModel** ← manages business logic and Commands
3. **Commands** ← execute async operations and emit state

---

## The Complete Flow

```
┌──────────────────────────────────────────────────────────┐
│                  Page Widget (StatefulWidget)             │
│                                                           │
│  class MyPage extends StatefulWidget {                   │
│    @override                                             │
│    State<MyPage> createState() => _MyPageState();        │
│  }                                                        │
└──────────────────┬───────────────────────────────────────┘
                   │
                   │ creates
                   ▼
┌──────────────────────────────────────────────────────────┐
│        ViewState (Custom State subclass)                  │
│                                                           │
│  - Manages widget lifecycle                             │
│  - Integrates DI (registerDependencies, disposeDeps)    │
│  - Retrieves and caches ViewModel from DI               │
│  - Provides viewModel property to build()               │
└──────────────────┬───────────────────────────────────────┘
                   │
                   │ in initState:
                   │ 1. registers DI dependencies
                   │ 2. retrieves viewModel from GetIt
                   │ 3. calls viewModel.onViewInit()
                   │
                   ▼
┌──────────────────────────────────────────────────────────┐
│          ViewModel (StatelessViewModel or StatefulVM)     │
│                                                           │
│  - Defines Command0/Command1 instances                   │
│  - Calls repository methods via Commands                │
│  - Manages page-level state                             │
│  - Responds to onViewInit() and onViewDispose()         │
└──────────────────┬───────────────────────────────────────┘
                   │
                   │ defines & executes
                   ▼
┌──────────────────────────────────────────────────────────┐
│      Command0/Command1 (Signal<ViewModelState<T>>)       │
│                                                           │
│  - Wraps repository methods (async actions)             │
│  - Emits: Initial → Running → Completed/Error           │
│  - Prevents concurrent execution                        │
│  - Stores result and error states                       │
└──────────────────┬───────────────────────────────────────┘
                   │
                   │ emits ViewModelState
                   │ which is observed by
                   ▼
┌──────────────────────────────────────────────────────────┐
│          CommandBuilder<T> (Widget)                       │
│                                                           │
│  - Watches command via Watch() from signals             │
│  - Renders different UI based on state                  │
│  - Provides builders for each state                     │
│  - Automatically rebuilds on state change               │
└──────────────────┬───────────────────────────────────────┘
                   │
                   │ renders
                   ▼
┌──────────────────────────────────────────────────────────┐
│                   UI (Widget Tree)                        │
│                                                           │
│  - Loading spinner (Running state)                      │
│  - Error message (Error state)                          │
│  - Content (Completed state)                            │
│  - Empty/ready (Initial state)                          │
└──────────────────────────────────────────────────────────┘
```

---

## Complete Example: Users Page

### 1. ViewModel Definition

```dart
// lib/app/pages/users/users_view_model.dart
import 'dart:async';
import 'package:fk_booster/fk_booster.dart';
import '../../features/users/domain/entity/user_entity.dart';
import '../../features/users/domain/repository/user_repository.dart';

class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  // Define Command0: no arguments needed
  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  // Define Command1: takes String userId as argument
  late final getUserById = Command1<UserEntity, String>(
    userRepository.getById,
  );

  // Called by ViewState.initState() after ViewModel is retrieved from DI
  @override
  void onViewInit() {
    // Trigger initial data load
    unawaited(getAll.execute());
  }

  // Called by ViewState.dispose() before DI scope is dropped
  @override
  void onViewDispose() {
    // Clean up listeners, streams, etc. if needed
  }
}
```

**Key Points**:
- `late final` for Commands (initialized once, used multiple times)
- `StatelessViewModel` because this ViewModel only manages Commands
- `onViewInit()` is perfect for triggering initial loads
- Commands are just wrappers around repository methods

### 2. ViewState and Page Widget

```dart
// lib/app/pages/users/users_page.dart
import 'package:flutter/material.dart';
import 'package:fk_booster/fk_booster.dart';
import 'users_injection.dart';
import 'users_view_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  // Provide page-specific DI
  @override
  DependencyInjection? get injection => UsersInjection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: CommandBuilder<List<UserEntity>>(
        command: viewModel.getAll,
        
        // Show spinner while loading
        loadingBuilder: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        
        // Show error with details
        errorBuilder: (state) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load users'),
              const SizedBox(height: 16),
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => unawaited(viewModel.getAll.execute()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        
        // Show user list when completed
        completedBuilder: (state) {
          final users = state.data;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name ?? 'Unknown'),
                subtitle: Text(user.email ?? 'No email'),
              );
            },
          );
        },
        
        // Show initial state
        initialStateBuilder: (state) => const Center(
          child: Text('Ready to load users'),
        ),
      ),
    );
  }
}
```

**Key Points**:
- ViewState automatically calls `injection?.registerDependencies()` in `initState()`
- ViewState automatically calls `viewModel.onViewInit()` in `initState()`
- `viewModel` is automatically retrieved from DI
- `CommandBuilder` handles reactive rendering based on command state

### 3. Injection Setup

```dart
// lib/app/pages/users/users_injection.dart
import 'package:fk_booster/fk_booster.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/users/domain/entity/user_entity_parser.dart';
import '../../features/users/data/entity_parser/user_entity_api_parser.dart';
import '../../features/users/domain/repository/user_repository.dart';
import '../../features/users/data/repository/user_api_repository.dart';
import 'users_view_model.dart';

class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);  // MUST call first!
    i
      ..registerLazySingleton<UserEntityParser>(
        () => UserEntityApiParser(),
      )
      ..registerLazySingleton<UserRepository>(
        () => UserApiRepository(
          parser: i.get<UserEntityParser>(),
          dio: i.get<Dio>(),  // Retrieved from parent Startup scope
        ),
      )
      ..registerLazySingleton<UsersViewModel>(
        () => UsersViewModel(userRepository: i.get<UserRepository>()),
      );
  }
}
```

**Key Points**:
- Must call `super.registerDependencies(i)` first
- Register parsers, repositories, then ViewModel
- Dependencies in parent scopes (Startup) are accessible
- Scoped disposal happens automatically when page closes

---

## Lifecycle Sequence (Complete)

### Page Opens
```
1. Flutter creates UsersPage (StatefulWidget)
   ↓
2. Flutter creates _UsersPageState (ViewState subclass)
   ↓
3. ViewState.initState() is called
   ├─ GetIt.pushNewScope('users')
   ├─ injection.registerDependencies(GetIt)
   │  ├─ registers UserEntityParser
   │  ├─ registers UserRepository
   │  └─ registers UsersViewModel
   ├─ initViewModel() → viewModel = GetIt.get<UsersViewModel>()
   ├─ viewModel.onViewInit()
   │  └─ unawaited(viewModel.getAll.execute())
   │     └─ Command state: Initial → Running → Completed
   └─ first build scheduled
   ↓
4. ViewState.build() is called
   └─ CommandBuilder listens to viewModel.getAll command
      └─ renders loadingBuilder (Running state)
   ↓
5. UserRepository.getAll() completes
   ├─ Command state becomes Completed with data
   ├─ CommandBuilder automatically rebuilds
   └─ renders completedBuilder with user list
```

### Page Closes
```
1. User navigates away or page is disposed
   ↓
2. ViewState.dispose() is called
   ├─ viewModel.onViewDispose()
   │  └─ (cleanup if needed)
   ├─ GetIt.dropScope('users')
   │  └─ automatically disposes:
   │     ├─ UserEntityParser
   │     ├─ UserRepository
   │     ├─ UsersViewModel
   │     └─ all registered instances
   └─ page memory is freed
```

---

## StatelessViewModel vs StatefulViewModel

### StatelessViewModel
Use for ViewModels that **only manage Commands**.

```dart
class MyViewModel extends StatelessViewModel {
  late final command = Command0<List<Item>>(...);

  @override
  void onViewInit() {
    unawaited(command.execute());
  }
}
```

**When to use**:
- ✅ Page fetches and displays data
- ✅ Page has multiple Commands
- ✅ No mutable UI state needed

### StatefulViewModel<T>
Use for ViewModels that **manage mutable state** (like form values).

```dart
class CreateUserViewModel extends StatefulViewModel<UserEntity> {
  CreateUserViewModel() : super(const UserEntity.empty());

  // Mutable state
  void setName(String name) {
    value = value.copyWith(name: name);
  }

  // Can also have Commands
  late final create = Command0<UserEntity>(...);
}
```

**When to use**:
- ✅ Form inputs change state
- ✅ Filters/selections change state
- ✅ State must persist while user interacts

---

## Command Execution Patterns

### Pattern 1: Auto-Load on Page Init
```dart
class UsersViewModel extends StatelessViewModel {
  late final getAll = Command0<List<UserEntity>>(...);

  @override
  void onViewInit() {
    unawaited(getAll.execute());  // Runs automatically
  }
}
```

### Pattern 2: User-Triggered Action
```dart
class UserDetailsViewModel extends StatelessViewModel {
  late final deleteUser = Command1<void, String>(...);

  void onDeletePressed(String userId) {
    unawaited(deleteUser.execute(userId));  // Runs on button press
  }
}
```

```dart
// In UI
ElevatedButton(
  onPressed: () => viewModel.onDeletePressed(userId),
  child: const Text('Delete'),
)
```

### Pattern 3: Multiple Commands
```dart
class UserManagementViewModel extends StatelessViewModel {
  late final getAll = Command0<List<UserEntity>>(...);
  late final createUser = Command1<UserEntity, UserEntity>(...);
  late final deleteUser = Command1<void, String>(...);

  @override
  void onViewInit() {
    unawaited(getAll.execute());
  }
}
```

```dart
// Multiple CommandBuilders in UI
Column(
  children: [
    CommandBuilder(command: viewModel.getAll, ...),
    CommandBuilder(command: viewModel.deleteUser, ...),
  ],
)
```

---

## Best Practices

### 1. One ViewModel per Page
```dart
// ✅ GOOD: Clear separation
class MyPageState extends ViewState<MyPage, MyPageViewModel> {}

// ❌ BAD: Sharing ViewModels causes lifecycle issues
class PageAState extends ViewState<PageA, SharedViewModel> {}
class PageBState extends ViewState<PageB, SharedViewModel> {}
```

### 2. Use `unawaited()` for Fire-and-Forget
```dart
import 'dart:async';

@override
void onViewInit() {
  unawaited(command.execute());  // Avoids lint warnings
}
```

### 3. Handle Command States Explicitly
```dart
// ✅ GOOD: Handle all states
CommandBuilder<List<Item>>(
  command: viewModel.getAll,
  loadingBuilder: (_) => Spinner(),
  errorBuilder: (s) => ErrorWidget(),
  completedBuilder: (s) => ListView(),
)

// ❌ BAD: Missing error handling
CommandBuilder<List<Item>>(
  command: viewModel.getAll,
  completedBuilder: (s) => ListView(),
)
```

### 4. Provide Retry Options
```dart
errorBuilder: (state) => Center(
  child: Column(
    children: [
      Text('Error: ${state.error}'),
      ElevatedButton(
        onPressed: () => unawaited(viewModel.getAll.execute()),
        child: const Text('Retry'),
      ),
    ],
  ),
)
```

### 5. Clear Results When Needed
```dart
completedBuilder: (state) {
  // Show success message
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Created successfully')),
    );
    viewModel.createCommand.clearResult();
  });
  return SuccessWidget();
}
```

---

## Testing

### Test ViewModel with Commands
```dart
test('UsersViewModel.getAll loads users', () async {
  final mockRepository = MockUserRepository();
  when(mockRepository.getAll()).thenAnswer(
    (_) => Future.value([UserEntity(id: '1', name: 'Alice')]),
  );

  final viewModel = UsersViewModel(userRepository: mockRepository);
  
  await viewModel.getAll.execute();

  expect(viewModel.getAll.completed, true);
  expect(viewModel.getAll.result, isNotEmpty);
  expect(viewModel.getAll.result?.first.name, 'Alice');
});
```

### Test CommandBuilder
```dart
testWidgets('CommandBuilder shows loading state', (tester) async {
  final command = Command0<String>(() => Future.delayed(Duration(seconds: 1), () => 'done'));
  
  await tester.pumpWidget(
    MaterialApp(
      home: CommandBuilder<String>(
        command: command,
        loadingBuilder: (_) => const Text('Loading'),
        completedBuilder: (s) => Text(s.data),
      ),
    ),
  );

  expect(find.text('Loading'), findsOneWidget);

  command.execute();
  await tester.pump();  // Let execute start
  
  expect(find.text('Loading'), findsOneWidget);
  
  await tester.pumpAndSettle();  // Wait for completion
  
  expect(find.text('done'), findsOneWidget);
});
```

---

## Summary Table

| Component | Purpose | Location | Lifecycle |
|-----------|---------|----------|-----------|
| **Page Widget** | Flutter StatefulWidget | `pages/<page>/` | App lifetime |
| **ViewState** | Custom State subclass | `pages/<page>/` | Page lifetime |
| **ViewModel** | Business logic manager | `pages/<page>/` | Page lifetime |
| **Command0/1** | Async action wrapper | Defined in ViewModel | Page lifetime |
| **CommandBuilder** | Reactive UI widget | `pages/<page>/` | Page lifetime |
| **DependencyInjection** | DI registration | `pages/<page>/<page>_injection.dart` | Page scope lifetime |

---

## Cross-References

- See `COMMANDS.md` for detailed Command documentation
- See `VIEWSTATE.md` for detailed ViewState documentation
- See `DEPENDENCY_INJECTION.md` for detailed DI documentation
- See `SCAFFOLD_TEMPLATES.md` for copy-paste templates

