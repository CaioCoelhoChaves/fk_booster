# Commands and CommandBuilder Guide

## Overview
This guide explains **Commands** and **CommandBuilder** - the core mechanisms for handling asynchronous actions and UI state updates in fk_booster. These components work together to:
- Execute asynchronous operations (API calls, database queries, etc.)
- Manage loading, success, and error states automatically
- Prevent duplicate execution while an operation is running
- Provide reactive UI updates through Flutter's `Watch` from the signals package

**Key Insight**: Commands encapsulate the entire lifecycle of an async operation and expose states that the UI can react to.

---

## Command Class (Abstract Base)

### Location in fk_booster
`lib/presentation/command.dart`

### Purpose
`Command<T>` is an abstract base class that:
1. Extends `Signal<ViewModelState<T>>` for reactive state management
2. Wraps an async action and tracks its execution state
3. Prevents concurrent executions (ignores calls if already running)
4. Exposes states: Initial → Running → Completed/Error

### States (ViewModelState)

Commands emit four possible states:

#### 1. `Initial<T>` (Initial State)
- **When**: Command is created or result has been cleared
- **Properties**: No data, not running, no error
- **Use case**: Initial page load state before any action is triggered

```dart
command.value is Initial<T>  // Check if initial
command.clearResult();        // Reset to initial state
```

#### 2. `Running<T>` (Loading State)
- **When**: Action is executing
- **Properties**: No data yet, but execution is in progress
- **Use case**: Show loading spinners, disable buttons, etc.

```dart
if (command.running) {
  // Show loading indicator
}
```

#### 3. `Completed<T>` (Success State)
- **When**: Action completed successfully
- **Properties**: Contains the result of type `T`
- **Use case**: Display result data, show success messages

```dart
if (command.completed) {
  final result = command.result;  // T
  // Display result
}
```

#### 4. `Error<T>` (Error State)
- **When**: Action threw an exception
- **Properties**: Contains the exception object
- **Use case**: Show error messages, retry buttons

```dart
if (command.error) {
  // Show error UI
}
```

### Key Properties and Methods

```dart
abstract class Command<T> extends Signal<ViewModelState<T>> {
  // State checking (convenience properties)
  bool get running => value is Running;         // Currently executing?
  bool get error => value is Error;             // Completed with error?
  bool get completed => value is Completed;     // Completed successfully?
  
  // Result access
  T? get result => value is Completed<T> ? (value as Completed<T>).data : null;
  
  // State management
  void clearResult() => value = Initial._();    // Reset to initial state
}
```

### Execution Method

The internal `_execute` method handles the entire operation lifecycle:

```dart
Future<void> _execute(CommandAction0<T> action) async {
  if (running) return;  // Prevent concurrent execution
  value = Running._();   // Set running state
  try {
    value = value.toLoaded(data: await action());  // Execute and set completed
  } on Exception catch (exception) {
    value = value.toError(error: exception);      // Catch errors and set error state
  }
}
```

**Key Points**:
- If `running` is true, subsequent calls are ignored (prevents duplicate requests)
- Sets `Running` state immediately before execution
- Catches exceptions and transitions to `Error` state
- Successful results transition to `Completed` state with data

---

## Command Subclasses

### Command0<T> (No Arguments)

Used for actions that don't require any parameters.

**Location**: `lib/presentation/command.dart`

**Definition**:
```dart
final class Command0<T> extends Command<T> {
  Command0(this._action);
  final CommandAction0<T> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}
```

**Type Parameters**:
- **T**: The return type of the action (the data type when completed)

**Usage Example**:
```dart
class UsersViewModel extends StatelessViewModel {
  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,  // Action with no args that returns Future<List<UserEntity>>
  );

  void onViewInit() {
    unawaited(getAll.execute());  // Execute without arguments
  }
}
```

### Command1<T, A> (One Argument)

Used for actions that require exactly one parameter.

**Location**: `lib/presentation/command.dart`

**Definition**:
```dart
final class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
```

**Type Parameters**:
- **T**: The return type of the action (the data type when completed)
- **A**: The argument type required by the action

**Usage Example**:
```dart
class UserDetailsViewModel extends StatelessViewModel {
  UserDetailsViewModel(this._userRepository);
  final UserRepository _userRepository;

  late final getUserById = Command1<UserEntity, String>(
    _userRepository.getById,  // Action that takes String and returns Future<UserEntity>
  );

  void loadUser(String userId) {
    unawaited(getUserById.execute(userId));  // Execute with userId argument
  }
}
```

---

## CommandAction Typedefs

### CommandAction0<T>
Action with no arguments returning `Future<T>`.

```dart
typedef CommandAction0<T> = Future<T> Function();
```

**Example**:
```dart
CommandAction0<List<UserEntity>> action = () => userRepository.getAll();
```

### CommandAction1<T, A>
Action with one argument of type `A`, returning `Future<T>`.

```dart
typedef CommandAction1<T, A> = Future<T> Function(A);
```

**Example**:
```dart
CommandAction1<UserEntity, String> action = (userId) => userRepository.getById(userId);
```

---

## CommandBuilder Widget

### Location in fk_booster
`lib/presentation/command_builder.dart`

### Purpose
`CommandBuilder` is a Flutter widget that:
1. Watches a `Command<T>` for state changes
2. Renders different UI based on the current `ViewModelState`
3. Automatically rebuilds when the command state changes
4. Provides optional builders for each state

### Full Implementation

```dart
class CommandBuilder<T> extends StatelessWidget {
  const CommandBuilder({
    required this.command,
    this.builder,
    this.initialStateBuilder,
    this.loadingBuilder,
    this.completedBuilder,
    this.errorBuilder,
    super.key,
  });

  final Command<T> command;
  
  final Widget Function(ViewModelState<T> state)? builder;
  final Widget Function(Initial<T> state)? initialStateBuilder;
  final Widget Function(Running<T> state)? loadingBuilder;
  final Widget Function(Completed<T> state)? completedBuilder;
  final Widget Function(Error<T> state)? errorBuilder;

  @override
  Widget build(BuildContext context) => Watch(
    (_) {
      if (loadingBuilder != null && command.value is Running) {
        return loadingBuilder!(command.value as Running<T>);
      }

      if (errorBuilder != null && command.value is Error) {
        return errorBuilder!(command.value as Error<T>);
      }

      if (completedBuilder != null && command.value is Completed) {
        return completedBuilder!(command.value as Completed<T>);
      }

      if (initialStateBuilder != null && command.value is Initial) {
        return initialStateBuilder!(command.value as Initial<T>);
      }

      if (builder != null) return builder!(command.value);

      return const SizedBox.shrink();
    },
    dependencies: [command],
  );
}
```

### Properties

| Property | Type | Required | Purpose |
|----------|------|----------|---------|
| `command` | `Command<T>` | ✅ Yes | The command to observe |
| `builder` | `Widget Function(ViewModelState<T>)?` | ❌ No | Fallback builder for all states |
| `initialStateBuilder` | `Widget Function(Initial<T>)?` | ❌ No | Builder for Initial state |
| `loadingBuilder` | `Widget Function(Running<T>)?` | ❌ No | Builder for Running state |
| `completedBuilder` | `Widget Function(Completed<T>)?` | ❌ No | Builder for Completed state |
| `errorBuilder` | `Widget Function(Error<T>)?` | ❌ No | Builder for Error state |

### State Selection Logic (Priority Order)

1. **loadingBuilder** (if provided and state is `Running`)
2. **errorBuilder** (if provided and state is `Error`)
3. **completedBuilder** (if provided and state is `Completed`)
4. **initialStateBuilder** (if provided and state is `Initial`)
5. **builder** (fallback for any state)
6. **SizedBox.shrink()** (if no builder matches)

### Watch and Reactivity

The `Watch` widget (from the `signals` package):
- **Dependencies**: `[command]` - rebuilds whenever the command changes
- **Reactive**: Only rebuilds when the command's state actually changes
- **Efficient**: Uses signals for fine-grained reactivity

---

## Complete Usage Example

### ViewModel Definition

```dart
class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  // Command0: Fetch all users (no arguments)
  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  @override
  void onViewInit() {
    unawaited(getAll.execute());  // Trigger on page load
  }
}
```

### UI Integration with CommandBuilder

```dart
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  DependencyInjection? get injection => UsersInjection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: CommandBuilder<List<UserEntity>>(
        command: viewModel.getAll,
        
        // Show loading spinner while fetching
        loadingBuilder: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        
        // Show error message if request fails
        errorBuilder: (state) => Center(
          child: Text('Error: ${state.error}'),
        ),
        
        // Show user list when completed
        completedBuilder: (state) => ListView.builder(
          itemCount: state.data.length,
          itemBuilder: (context, index) {
            final user = state.data[index];
            return ListTile(
              title: Text(user.name ?? 'Unknown'),
            );
          },
        ),
        
        // Show initial placeholder
        initialStateBuilder: (state) => const Center(
          child: Text('Ready to load users'),
        ),
      ),
    );
  }
}
```

### Example with Command1 (Argument)

```dart
class UserDetailsViewModel extends StatelessViewModel {
  UserDetailsViewModel({required this.userRepository});

  final UserRepository userRepository;

  // Command1: Fetch single user by ID
  late final getUserById = Command1<UserEntity, String>(
    userRepository.getById,
  );

  void loadUser(String userId) {
    unawaited(getUserById.execute(userId));
  }
}
```

```dart
class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends ViewState<UserDetailsPage, UserDetailsViewModel> {
  @override
  void initState() {
    super.initState();
    // Load user after ViewModel is initialized
    viewModel.loadUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: CommandBuilder<UserEntity>(
        command: viewModel.getUserById,
        loadingBuilder: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (state) => Center(
          child: Text('Error: ${state.error}'),
        ),
        completedBuilder: (state) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${state.data.id}'),
                Text('Name: ${state.data.name}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Best Practices

### 1. Use `unawaited()` for Fire-and-Forget Executions
When you don't need to wait for the command to complete:

```dart
import 'dart:async';

@override
void onViewInit() {
  unawaited(getAll.execute());  // Avoid "not awaited" warnings
}
```

### 2. Clear Results When Appropriate
After consuming a result (e.g., showing a success message), clear it:

```dart
completedBuilder: (state) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    viewModel.myCommand.clearResult();
  });
  return SuccessWidget();
}
```

### 3. Combine Multiple Commands
Use multiple commands in one ViewModel for different operations:

```dart
class UserManagementViewModel extends StatelessViewModel {
  late final getAll = Command0<List<UserEntity>>(...);
  late final deleteUser = Command1<void, String>(...);
  late final createUser = Command1<UserEntity, CreateUserRequest>(...);
}
```

### 4. Handle Errors Appropriately
Always provide error handling for user feedback:

```dart
errorBuilder: (state) => ErrorDialog(
  error: state.error,
  onRetry: () => viewModel.myCommand.execute(),
)
```

### 5. Respect the Single Execution Guarantee
The command automatically prevents concurrent execution, so you don't need to manually check `running`:

```dart
// GOOD: Just execute
await command.execute();

// BAD: Unnecessary check (command already handles this)
if (!command.running) await command.execute();
```

---

## Testing Commands

Commands are easy to test because they're just wrappers around async functions:

```dart
test('Command executes action and sets completed state', () async {
  final action = () async => 'result';
  final command = Command0<String>(action);

  await command.execute();

  expect(command.completed, true);
  expect(command.result, 'result');
});

test('Command prevents concurrent execution', () async {
  var callCount = 0;
  final action = () async {
    callCount++;
    await Future.delayed(const Duration(milliseconds: 100));
    return callCount;
  };
  
  final command = Command0<int>(action);

  // Try to execute concurrently
  unawaited(command.execute());
  unawaited(command.execute());
  
  await Future.delayed(const Duration(milliseconds: 150));

  expect(callCount, 1);  // Only called once
  expect(command.result, 1);
});
```

---

## Relationship with ViewModel and ViewState

```
┌─────────────────────────────────────────┐
│         UsersPage (StatefulWidget)       │
└──────────────────┬──────────────────────┘
                   │
                   │ creates
                   ▼
┌─────────────────────────────────────────┐
│    _UsersPageState extends ViewState     │
│  - Manages lifecycle (initState, build)  │
│  - Integrates with DI (via injection)    │
│  - Provides viewModel automatically      │
└──────────────────┬──────────────────────┘
                   │
                   │ observes
                   ▼
┌─────────────────────────────────────────┐
│    UsersViewModel extends ViewModel      │
│  - Defines Command0/Command1 instances   │
│  - Calls repository methods via Commands │
│  - Manages page-level state              │
└──────────────────┬──────────────────────┘
                   │
                   │ delegates to
                   ▼
┌─────────────────────────────────────────┐
│  Command0<List<UserEntity>>              │
│  - Wraps userRepository.getAll()         │
│  - Emits: Initial → Running → Completed  │
│  - Prevents duplicate execution          │
└──────────────────┬──────────────────────┘
                   │
                   │ observed by
                   ▼
┌─────────────────────────────────────────┐
│      CommandBuilder<List<UserEntity>>    │
│  - Watches command state via Watch       │
│  - Renders based on state (Loading, etc) │
│  - Rebuilds reactively on state change   │
└─────────────────────────────────────────┘
```

---

## Summary

| Concept | Purpose | Location |
|---------|---------|----------|
| **Command<T>** | Abstract base for async operations | `lib/presentation/command.dart` |
| **Command0<T>** | Command with no arguments | `lib/presentation/command.dart` |
| **Command1<T, A>** | Command with one argument | `lib/presentation/command.dart` |
| **ViewModelState<T>** | State type (Initial, Running, Completed, Error) | `lib/presentation/view_model_states.dart` |
| **CommandBuilder<T>** | Widget for reactive UI based on command state | `lib/presentation/command_builder.dart` |

Commands are the **execution layer** between ViewModels and async operations, providing a clean, reactive interface for UI state management in fk_booster.

