# fk_booster Architecture Overview

## Visual Architecture Map

```
┌────────────────────────────────────────────────────────────────────────┐
│                          Flutter Application                            │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                        Presentation Layer                        │  │
│  │                                                                  │  │
│  │  Page Widget (StatefulWidget)                                   │  │
│  │         │                                                       │  │
│  │         └─► ViewState (State subclass)                         │  │
│  │               │                                                │  │
│  │               ├─► Retrieves ViewModel from DI (GetIt)          │  │
│  │               ├─► Manages Widget Lifecycle                     │  │
│  │               └─► Integrates with DI scopes                    │  │
│  │                      │                                         │  │
│  │                      └─► UI Rendering                          │  │
│  │                          │                                     │  │
│  │                          ├─► CommandBuilder<T>                │  │
│  │                          │     └─► Watches Command signals    │  │
│  │                          │         └─► Renders based on state│  │
│  │                          │                                   │  │
│  │                          └─► Direct Widget Access           │  │
│  │                              └─► viewModel property          │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                 │                                       │
│                                 │ depends on                            │
│                                 ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Business Logic Layer                          │  │
│  │                                                                  │  │
│  │  ViewModel (StatelessViewModel or StatefulViewModel<T>)         │  │
│  │         │                                                       │  │
│  │         ├─► Command0<T>  (no args)  ─┐                        │  │
│  │         ├─► Command1<T, A> (1 arg) ──┼─► Executes             │  │
│  │         └─► Commands...           ──┘   async operations      │  │
│  │                                                                 │  │
│  │  Commands emit:                                                │  │
│  │  Initial<T> ──► Running<T> ──► Completed<T> or Error<T>      │  │
│  │                                                                 │  │
│  │  onViewInit()  ──► Lifecycle hook (fetch initial data)        │  │
│  │  onViewDispose() ──► Cleanup hook (cancel listeners)          │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                 │                                       │
│                                 │ delegates to                          │
│                                 ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Data Access Layer                             │  │
│  │                                                                  │  │
│  │  Repository (Interface in domain, Implementation in data)       │  │
│  │         │                                                       │  │
│  │         ├─► API Repository (HTTP via Dio)                      │  │
│  │         ├─► DB Repository (Local database)                     │  │
│  │         └─► Cache Repository (Memory/persistent cache)         │  │
│  │                      │                                          │  │
│  │                      └─► Uses EntityParser<Entity>             │  │
│  │                          │                                     │  │
│  │                          ├─► FromMap (raw → entity)           │  │
│  │                          ├─► ToMap (entity → raw)             │  │
│  │                          └─► getId (extract ID)               │  │
│  │                                                                 │  │
│  │  Returns:                                                       │  │
│  │  Domain Entities (UserEntity, ProductEntity, etc.)             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                 │                                       │
│                                 │ connects via                          │
│                                 ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                  Dependency Injection Layer                      │  │
│  │                  (GetIt with Scoped Lifecycle)                  │  │
│  │                                                                  │  │
│  │  Global Scope (Startup):                                        │  │
│  │  ├─► Dio (HTTP Client)                                         │  │
│  │  ├─► Router                                                    │  │
│  │  ├─► Analytics, Logger, etc.                                   │  │
│  │                                                                  │  │
│  │  Page Scope (per page):                                         │  │
│  │  ├─► EntityParsers                                             │  │
│  │  ├─► Repositories                                              │  │
│  │  └─► ViewModels                                                │  │
│  │                                                                  │  │
│  │  Lifecycle:                                                     │  │
│  │  Page Open  → pushNewScope  → registerDependencies            │  │
│  │  Page Close → dropScope  → Auto-dispose all                   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Layer Breakdown

### Presentation Layer (UI)
**Files**: `pages/<page_name>/<page_name>_page.dart`

**Responsibility**: Render UI and respond to user interactions

**Key Components**:
- `<Page>` - StatefulWidget (standard Flutter)
- `_<Page>State` - Extends ViewState (custom)
- Uses CommandBuilder to react to async operations
- Calls ViewModel methods on user actions

**Never contains**:
- Business logic
- API calls
- Database queries
- State management beyond ViewState

### Business Logic Layer (ViewModel)
**Files**: `pages/<page_name>/<page_name>_view_model.dart`

**Responsibility**: Orchestrate operations and manage page state

**Key Components**:
- `<Page>ViewModel` - Extends StatelessViewModel or StatefulViewModel
- Commands (Command0, Command1)
- Lifecycle hooks (onViewInit, onViewDispose)

**Contains**:
- Command definitions
- Initial data loading
- Action method implementations
- State computations

**Never contains**:
- Flutter widget code
- Direct DB/API access (delegates to repositories)

### Data Access Layer (Repositories)
**Files**: 
- Domain: `features/<feature>/domain/repository/<feature>_repository.dart`
- Data: `features/<feature>/data/repository/<feature>_repository_impl.dart`

**Responsibility**: Handle all data access operations

**Key Components**:
- `<Feature>Repository` - Abstract interface (domain)
- `<Feature>ApiRepository` - Implementation (data)
- Delegates to EntityParsers for data transformation

**Contains**:
- API calls via Dio
- Database queries
- Caching logic
- Error handling

**Never contains**:
- Business logic decisions (should delegate to commands)
- UI code

### Entity Parsing Layer (EntityParsers)
**Files**:
- Domain: `features/<feature>/domain/entity/<entity>_entity_parser.dart`
- Data: `features/<feature>/data/entity_parser/<entity>_entity_api_parser.dart`

**Responsibility**: Transform between data formats and domain entities

**Key Components**:
- `FromMap` - Raw data (JSON/DB) → Entity
- `ToMap` - Entity → Raw data (JSON/DB)
- `GetId` - Extract ID from entity

**Operations**:
- JSON parsing from API responses
- Database model conversion
- Field mapping and type conversion
- Nullable field handling

### Domain Layer (Entities)
**Files**: `features/<feature>/domain/entity/<entity>_entity.dart`

**Responsibility**: Represent business domain objects

**Key Components**:
- Pure Dart classes
- No framework dependencies
- Immutable with const constructors
- Extends Entity (Equatable)

**Contains**:
- Field definitions
- Props (for equality)
- copyWith (for immutability pattern)
- Empty constructor (for initialization)

**Never contains**:
- Flutter imports
- Database annotations
- API-specific logic

### Dependency Injection Layer
**Files**:
- Global: `lib/app/startup_injection.dart`
- Page: `pages/<page_name>/<page_name>_injection.dart`

**Responsibility**: Manage dependency registration and lifecycle

**Key Components**:
- `StartupInjection` - Global scope (app lifetime)
- `<Page>Injection` - Page scope (page lifetime)
- Both extend `DependencyInjection`

**Lifecycle**:
```
Page Opens
    ↓
ViewState.initState()
    ↓
injection.registerDependencies(GetIt)
    ├─ GetIt.pushNewScope(scopeName: '<page>')
    ├─ Register all dependencies in this scope
    └─ Create instances lazily as needed
    ↓
Page Closes
    ↓
ViewState.dispose()
    ↓
injection.disposeDependencies(GetIt)
    ├─ GetIt.dropScope('<page>')
    └─ Auto-dispose all scoped dependencies
```

---

## Data Flow Example: Loading Users

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. PAGE OPENS                                                   │
│                                                                 │
│ UsersPage (StatefulWidget)                                      │
│     └─► _UsersPageState (extends ViewState)                    │
│         └─► initState()                                         │
│             ├─ injection.registerDependencies(GetIt)           │
│             │  ├─ Register EntityParser                        │
│             │  ├─ Register Repository                          │
│             │  └─ Register ViewModel                           │
│             ├─ viewModel = GetIt.get<UsersViewModel>()         │
│             └─ viewModel.onViewInit()                          │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. VIEWMODEL INIT                                               │
│                                                                 │
│ UsersViewModel.onViewInit()                                     │
│     └─ unawaited(getAll.execute())                            │
│         └─ Command0<List<UserEntity>>.execute()               │
│            └─ getAll._execute(_userRepository.getAll)         │
│               ├─ command.value = Running<List<UserEntity>>()  │
│               └─ await _userRepository.getAll()               │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. REPOSITORY CALL                                              │
│                                                                 │
│ UserRepository.getAll()                                         │
│     └─ UserApiRepository.getAll()                              │
│        └─ rawGetAll(entityParser: parser)                      │
│           ├─ Dio HTTP GET /users                               │
│           └─ receive JSON: [{id: "1", name: "Alice"}, ...]     │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. PARSING                                                      │
│                                                                 │
│ EntityParser.fromMap(jsonMap)                                   │
│     └─ for each JSON item:                                     │
│        └─ UserEntity(                                          │
│             id: jsonMap.getString('id'),     // "1"            │
│             name: jsonMap.getString('name'),  // "Alice"       │
│           )                                                    │
│                                                                 │
│ Result: List<UserEntity>                                       │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. COMMAND STATE UPDATE                                         │
│                                                                 │
│ command.value = Completed<List<UserEntity>>(                   │
│   data: [UserEntity(id: "1", name: "Alice"), ...]             │
│ )                                                               │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. UI REBUILD                                                   │
│                                                                 │
│ CommandBuilder<List<UserEntity>> watches command               │
│     └─ command signal changes                                  │
│     └─ CommandBuilder.build() is called                        │
│        └─ command.value is Completed<List<UserEntity>>        │
│           └─ completedBuilder(state) is called                │
│              └─ ListView.builder(                              │
│                   itemCount: state.data.length,  // 1+         │
│                   itemBuilder: (context, index) {              │
│                       final user = state.data[index];          │
│                       return ListTile(                         │
│                         title: Text(user.name),  // "Alice"    │
│                       );                                       │
│                   }                                            │
│                 )                                              │
│                                                                 │
│ UI displays: ListTile with "Alice"                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Management Flow

```
Command State Lifecycle:
┌────────────┐
│  Initial   │  ← Command created, no action yet
└─────┬──────┘
      │ execute() called
      ▼
┌────────────┐
│  Running   │  ← Async operation in progress
└─────┬──────┘    (show loading spinner)
      │ operation completes
      │
   ┌──┴──┐
   │     │
   ▼     ▼
┌──────────┐  ┌──────────┐
│Completed │  │  Error   │  ← Operation finished
│(success) │  │ (failed) │
└──────────┘  └──────────┘
   │              │
   └──────┬───────┘
          │ execute() again OR clearResult()
          ▼
      ┌────────────┐
      │  Running   │  ← New operation starts
      └────────────┘

UI Rendering:
Initial   → Show "Ready to load" message
Running   → Show loading spinner
Completed → Show results/content
Error     → Show error message + retry button
```

---

## Key Architectural Principles

### 1. Separation of Concerns
- **Presentation**: Only render and respond to user input
- **Business Logic**: Orchestrate operations and manage state
- **Data Access**: Handle all I/O operations
- **Domain**: Define business objects (entities)
- **DI**: Manage dependencies and lifetimes

### 2. Reactive State Management
- Commands emit `ViewModelState<T>` signals
- UI automatically rebuilds when state changes
- No manual state synchronization needed
- Prevents inconsistent UI states

### 3. Scoped Dependency Lifecycle
- Global scope (Startup): App lifetime (HTTP client, router)
- Page scope: Page lifetime (ViewModel, repositories)
- Automatic disposal prevents memory leaks
- Clear isolation between pages

### 4. Type Safety and Immutability
- Entities are immutable value objects
- Commands are generic over result type
- ViewModelState variants ensure exhaustive handling
- Dart's type system enforces correctness

### 5. Clean Architecture
- Domain layer has zero dependencies
- Data layer implements domain interfaces
- Presentation layer depends on domain (via repositories)
- Easy testing at each layer

---

## Complete Feature Example

```
Feature: Users
├── Domain (Business contracts)
│   ├── entity/
│   │   ├── user_entity.dart
│   │   └── user_entity_parser.dart (interface)
│   └── repository/
│       └── user_repository.dart (interface)
│
├── Data (Implementations)
│   ├── entity_parser/
│   │   └── user_entity_api_parser.dart
│   └── repository/
│       └── user_api_repository.dart
│
└── (No presentation code - used by pages)

Page: Users
├── users_page.dart (StatefulWidget + ViewState)
├── users_view_model.dart (ViewModel with Commands)
└── users_injection.dart (DI registration)

Data Flow:
users_page.dart
  │ uses
  ▼
users_view_model.dart
  │ executes
  ▼
user_repository.dart (interface)
  │ implemented by
  ▼
user_api_repository.dart
  │ uses
  ▼
user_entity_api_parser.dart
  │ transforms
  ▼
user_entity.dart
  │ returns to
  ▼
Command<List<UserEntity>>
  │ emits state
  ▼
CommandBuilder in users_page.dart
  │ renders
  ▼
UI (ListView, error, loading, etc)
```

---

## File Organization

```
lib/app/
├── startup_injection.dart        ← Global DI setup
├── router/
│   └── router.dart               ← App routing
├── theme/
│   └── theme.dart                ← App theming
│
├── features/                      ← Business features (clean arch)
│   ├── users/
│   │   ├── domain/
│   │   │   ├── entity/
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── user_entity_parser.dart
│   │   │   └── repository/
│   │   │       └── user_repository.dart
│   │   └── data/
│   │       ├── entity_parser/
│   │       │   └── user_entity_api_parser.dart
│   │       └── repository/
│   │           └── user_api_repository.dart
│   │
│   └── products/
│       ├── domain/
│       │   ├── entity/
│       │   └── repository/
│       └── data/
│           ├── entity_parser/
│           └── repository/
│
└── pages/                         ← UI screens
    ├── users/
    │   ├── users_page.dart
    │   ├── users_view_model.dart
    │   └── users_injection.dart
    │
    └── create_user/
        ├── create_user_page.dart
        ├── create_user_view_model.dart
        └── create_user_injection.dart
```

---

## When to Use Each Component

| Task | Component | File |
|------|-----------|------|
| Show data with loading/error | CommandBuilder | Page |
| Fetch data on page open | Command in onViewInit | ViewModel |
| Handle form submission | Command or StatefulViewModel | ViewModel |
| Make API call | Repository.method | Repository |
| Transform JSON to entity | EntityParser.fromMap | EntityParser |
| Define data structure | Entity fields | Entity |
| Register dependencies | DependencyInjection | Injection |
| Handle navigation | Router methods | Router |

---

## Cross-References

- `VIEWSTATE.md` - Widget lifecycle integration
- `COMMANDS.md` - Command execution patterns
- `VIEWMODEL_STATES.md` - State definitions
- `VIEWMODEL_INTEGRATION.md` - Complete integration examples
- `ENTITIES.md` - Entity design
- `ENTITY_PARSERS.md` - Data transformation
- `REPOSITORIES.md` - Data access patterns
- `DEPENDENCY_INJECTION.md` - DI system details
- `SCAFFOLD_TEMPLATES.md` - Ready-to-use templates

