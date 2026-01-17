# ViewModelState Guide

## Overview
This guide explains **ViewModelState** types and how they represent the lifecycle of asynchronous operations in fk_booster commands.

**Key Concept**: ViewModelState is a sealed type system that represents four possible states during the execution of an async operation: Initial, Running, Completed, or Error.

---

## What is ViewModelState?

ViewModelState is an abstract base class with four concrete implementations, each representing a stage in an async operation:

```dart
abstract class ViewModelState<T> {
  const ViewModelState();

  Initial<T> toInitial() => Initial._();
  Running<T> toRunning() => Running._();
  Completed<T> toLoaded({required T data}) => Completed._(data: data);
  Error<T> toError({required Object error}) => Error(error: error);
}
```

**Generic Type Parameter `T`**: The type of data when the operation completes successfully (e.g., `List<UserEntity>`, `UserEntity`, `void`)

---

## The Four States

### 1. Initial<T>

**When**: Command is created or result has been cleared.

**Properties**: No data, not running, no error.

**Use case**: Before any action has been executed, or after clearing the result.

**Code**:
```dart
class Initial<T> extends ViewModelState<T> {
  const Initial._();
}
```

**Checking**:
```dart
command.value is Initial<T>  // or
command.value.runtimeType == Initial
```

**UI Example**:
```dart
CommandBuilder<List<UserEntity>>(
  command: viewModel.getAll,
  initialStateBuilder: (state) => const Center(
    child: Text('Ready to load users'),
  ),
)
```

**Common Use Cases**:
- Show empty/ready placeholder
- Show "Get Started" message
- Show loading can be triggered by user

---

### 2. Running<T>

**When**: Action is currently executing (async operation in progress).

**Properties**: No data yet, execution is in progress, no error.

**Use case**: Show loading indicators, disable buttons, show progress.

**Code**:
```dart
class Running<T> extends ViewModelState<T> {
  const Running._();
}
```

**Checking**:
```dart
command.running  // bool getter
command.value is Running<T>
```

**UI Example**:
```dart
CommandBuilder<List<UserEntity>>(
  command: viewModel.getAll,
  loadingBuilder: (state) => const Center(
    child: CircularProgressIndicator(),
  ),
)
```

**Common Use Cases**:
- Display loading spinner
- Disable form submit button
- Show "Loading..." text
- Show skeleton loaders
- Prevent user interactions

**Duration**: Short-lived - transitions to Completed or Error when operation finishes.

---

### 3. Completed<T>

**When**: Action completed successfully.

**Properties**: Contains result data of type `T`.

**Use case**: Display result, show success messages, enable user actions on data.

**Code**:
```dart
class Completed<T> extends ViewModelState<T> {
  const Completed._({required this.data});
  final T data;
}
```

**Accessing Result**:
```dart
command.completed  // bool getter
command.result     // T? getter
command.value is Completed<T>
(command.value as Completed<T>).data  // Direct access
```

**UI Example**:
```dart
CommandBuilder<List<UserEntity>>(
  command: viewModel.getAll,
  completedBuilder: (state) {
    final users = state.data;  // Type is List<UserEntity>
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(users[index].name ?? 'Unknown'),
        );
      },
    );
  },
)
```

**Common Use Cases**:
- Display fetched data (lists, forms, details)
- Show result summary
- Enable action buttons on result
- Trigger navigation on completion
- Show success messages

**Persistence**: State persists until `clearResult()` is called or command is executed again.

---

### 4. Error<T>

**When**: Action threw an exception or error occurred.

**Properties**: Contains exception object, no data.

**Use case**: Show error messages, provide retry options, log issues.

**Code**:
```dart
class Error<T> extends ViewModelState<T> {
  const Error({required this.error});
  final Object error;
}
```

**Accessing Error**:
```dart
command.error  // bool getter
command.value is Error<T>
(command.value as Error<T>).error  // The exception object
```

**UI Example**:
```dart
CommandBuilder<List<UserEntity>>(
  command: viewModel.getAll,
  errorBuilder: (state) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 48),
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
)
```

**Common Use Cases**:
- Show error message (human-readable if possible)
- Display error icon
- Provide "Retry" button
- Log error for analytics
- Navigate to error page
- Show toast/snackbar notification

**Error Types**:
```dart
// Can be any exception type
Exception: Generic exception
SocketException: Network error
TimeoutException: Request timeout
FormatException: Data parsing error
CustomException: App-specific errors
```

**Best Practice - Custom Exception Types**:
```dart
// Domain layer
abstract class CustomException implements Exception {
  final String message;
  CustomException(this.message);
}

class NetworkException extends CustomException {
  NetworkException(super.message);
}

class ParseException extends CustomException {
  ParseException(super.message);
}
```

Then in UI:
```dart
errorBuilder: (state) {
  final error = state.error;
  if (error is NetworkException) {
    return Text('Network error: ${error.message}');
  } else if (error is ParseException) {
    return Text('Data parsing error: ${error.message}');
  } else {
    return Text('Unknown error: $error');
  }
}
```

---

## State Transitions

### Complete Lifecycle

```
┌───────────────────┐
│     Initial       │
│   (not started)   │
└────────┬──────────┘
         │ execute() called
         ▼
┌───────────────────┐
│     Running       │
│  (async in progress)
└────────┬──────────┘
         │ async operation completes
         │
    ┌────┴────┐
    │          │
    ▼          ▼
┌──────────┐ ┌──────────┐
│Completed │ │  Error   │
│(success) │ │(failed)  │
└────┬─────┘ └────┬─────┘
     │            │
     │ clearResult() or execute() again
     │            │
     └──────┬─────┘
            ▼
       ┌─────────────┐
       │   Running   │
       │ (next exec) │
       └─────────────┘
```

### Key Points

1. **Initial → Running**: Always happens when `execute()` is called
2. **Running → Completed**: When async operation succeeds
3. **Running → Error**: When async operation throws exception
4. **Completed/Error → Running**: When `execute()` is called again
5. **Completed/Error → Initial**: When `clearResult()` is called
6. **Running → Running**: Cannot transition (prevents concurrent execution)

---

## State Transition Methods

ViewModelState provides convenience methods to transition between states:

```dart
abstract class ViewModelState<T> {
  // Return Initial state
  Initial<T> toInitial() => Initial._();

  // Return Running state
  Running<T> toRunning() => Running._();

  // Return Completed state with data
  Completed<T> toLoaded({required T data}) => Completed._(data: data);

  // Return Error state with exception
  Error<T> toError({required Object error}) => Error(error: error);
}
```

These are used internally by Command:

```dart
Future<void> _execute(CommandAction0<T> action) async {
  if (running) return;
  value = Running._();  // Transition to Running
  try {
    value = value.toLoaded(data: await action());  // Transition to Completed
  } on Exception catch (exception) {
    value = value.toError(error: exception);  // Transition to Error
  }
}
```

---

## Practical State Handling Examples

### Example 1: List Page with Retry
```dart
CommandBuilder<List<UserEntity>>(
  command: viewModel.getAll,
  
  // Loading
  loadingBuilder: (state) => const Center(
    child: CircularProgressIndicator(),
  ),
  
  // Success
  completedBuilder: (state) => ListView.builder(
    itemCount: state.data.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(state.data[index].name ?? 'Unknown'),
    ),
  ),
  
  // Error with retry
  errorBuilder: (state) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Failed to load: ${state.error}'),
        ElevatedButton(
          onPressed: () => unawaited(viewModel.getAll.execute()),
          child: const Text('Retry'),
        ),
      ],
    ),
  ),
  
  // Initial state
  initialStateBuilder: (state) => Center(
    child: ElevatedButton(
      onPressed: () => unawaited(viewModel.getAll.execute()),
      child: const Text('Load Users'),
    ),
  ),
)
```

### Example 2: Form Submission
```dart
ElevatedButton(
  onPressed: command.running ? null : () => _submitForm(),
  child: command.running 
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : const Text('Submit'),
)
```

### Example 3: Success Notification
```dart
completedBuilder: (state) {
  // Show success and clear after delay
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Created successfully')),
    );
    Future.delayed(const Duration(seconds: 2), () {
      viewModel.createCommand.clearResult();
    });
  });
  return const SizedBox.shrink();
}
```

### Example 4: Multiple States in One Widget
```dart
Widget build(BuildContext context) {
  return switch (command.value) {
    Initial() => _buildInitial(),
    Running() => _buildLoading(),
    Completed() => _buildSuccess(command.result!),
    Error() => _buildError(command.value.error),
  };
}
```

---

## Testing ViewModelState

### Unit Test Example
```dart
test('Command transitions through states correctly', () async {
  final action = () async => 'result';
  final command = Command0<String>(action);

  // Initial state
  expect(command.value is Initial, true);
  expect(command.completed, false);
  expect(command.running, false);
  expect(command.error, false);

  // Execute
  unawaited(command.execute());
  
  // Running state
  await Future.delayed(const Duration(milliseconds: 50));
  expect(command.value is Running, true);
  expect(command.running, true);

  // Completed state
  await Future.delayed(const Duration(milliseconds: 100));
  expect(command.value is Completed<String>, true);
  expect(command.completed, true);
  expect(command.result, 'result');
});
```

### Widget Test Example
```dart
testWidgets('CommandBuilder renders correct state', (tester) async {
  var stateRendered = '';
  final command = Command0<String>(() => Future.value('done'));

  await tester.pumpWidget(
    MaterialApp(
      home: CommandBuilder<String>(
        command: command,
        initialStateBuilder: (_) => const Text('initial'),
        loadingBuilder: (_) => const Text('loading'),
        completedBuilder: (s) => Text(s.data),
      ),
    ),
  );

  // Check initial state
  expect(find.text('initial'), findsOneWidget);

  // Execute command
  command.execute();
  await tester.pump();

  // Check loading state
  expect(find.text('loading'), findsOneWidget);

  // Wait for completion
  await tester.pumpAndSettle();

  // Check completed state
  expect(find.text('done'), findsOneWidget);
});
```

---

## Best Practices

### 1. Always Provide Error Handling
```dart
// ✅ GOOD
CommandBuilder<Data>(
  command: myCommand,
  loadingBuilder: (_) => Spinner(),
  errorBuilder: (s) => ErrorWidget(),
  completedBuilder: (s) => DataWidget(),
)

// ❌ BAD: Missing error handler
CommandBuilder<Data>(
  command: myCommand,
  completedBuilder: (s) => DataWidget(),
)
```

### 2. Use Proper Exception Types
```dart
// ✅ GOOD: Custom exceptions for different errors
throw NetworkException('Failed to fetch data');
throw ValidationException('Invalid email format');

// ❌ BAD: Generic exceptions
throw Exception('Something went wrong');
```

### 3. Clear Results When Appropriate
```dart
// ✅ GOOD: Clear after user consumes result
completedBuilder: (state) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(...);
    Future.delayed(Duration(seconds: 2), () {
      viewModel.command.clearResult();
    });
  });
  return SizedBox.shrink();
}
```

### 4. Provide Retry Functionality
```dart
// ✅ GOOD: Always provide a way to retry
errorBuilder: (state) => Column(
  children: [
    Text('Error: ${state.error}'),
    ElevatedButton(
      onPressed: () => viewModel.command.execute(),
      child: const Text('Retry'),
    ),
  ],
)
```

### 5. Use Type Safety
```dart
// ✅ GOOD: Properly typed states
CommandBuilder<List<UserEntity>>(
  completedBuilder: (Completed<List<UserEntity>> state) {
    return ListView.builder(
      itemCount: state.data.length,  // Type safe
    );
  },
)

// ❌ BAD: Losing type safety
CommandBuilder(
  completedBuilder: (state) {
    return ListView.builder(
      itemCount: state.data.length,  // May not compile
    );
  },
)
```

---

## Summary Table

| State | Used For | Has Data? | Example UI |
|-------|----------|-----------|------------|
| **Initial** | Before action starts | ❌ No | "Ready to load" message |
| **Running** | Action executing | ❌ No | Loading spinner |
| **Completed** | Action succeeded | ✅ Yes | Display results |
| **Error** | Action failed | ❌ No | Error message + retry |

---

## Cross-References

- See `COMMANDS.md` for how ViewModelState is used in Commands
- See `COMMANDBUILDER.md` (in COMMANDS.md) for rendering based on states
- See `VIEWMODEL_INTEGRATION.md` for complete state flow examples
- See `SCAFFOLD_TEMPLATES.md` for state handling patterns in UI code

