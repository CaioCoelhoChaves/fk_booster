# 📋 Instruções para GitHub Copilot - FK Booster Architecture

Este documento descreve a arquitetura esperada do projeto para auxiliar GitHub Copilot na geração de código consistente e seguindo os padrões estabelecidos.

---

## 🏗️ Estrutura Geral do Projeto

O projeto é um pacote Flutter (`fk_booster`) que fornece componentes e padrões reutilizáveis. A aplicação exemplo utiliza uma arquitetura **Clean Architecture** com separação clara entre camadas.

```
fk_booster/
├── lib/
│   ├── presentation/          # Camada de apresentação (componentes base)
│   │   ├── command.dart       # Padrão Command
│   │   ├── view_model.dart    # Classes base de ViewModel
│   │   ├── view_state.dart    # ViewState base
│   │   └── view_model_states.dart  # Estados de ViewModel
│   ├── domain/                # Camada de domínio
│   ├── data/                  # Camada de dados
│   ├── injection/             # Injeção de dependências
│   └── widgets/               # Componentes reutilizáveis
│
└── example/
    └── lib/app/
        ├── features/          # Estrutura de features (modular)
        │   └── users/         # Exemplo: Feature de usuários
        │       ├── data/
        │       └── domain/
        ├── pages/             # Páginas da aplicação
        │   ├── users/
        │   └── create_user/
        ├── router/            # Configuração de rotas
        └── startup_injection.dart
```

---

## 📁 Estrutura de Uma Feature

Cada feature segue um padrão modular e autossuficiente. Aqui está a estrutura completa usando a feature **users** como exemplo:

### 1. Camada de Domain (Lógica de Negócio)

```
features/users/domain/
├── entity/
│   ├── user_entity.dart              # Entidade de domínio
│   └── user_entity_parser.dart       # Interface de parser (abstração)
└── repository/
    └── user_repository.dart          # Interface de repositório (abstrato)
```

#### Typedefs e Mixins Utilizados

O FK Booster fornece os seguintes typedefs e mixins para composição:

**Typedefs (typedefs.dart):**
```dart
// Tipo para JSON genérico
typedef JsonMap = Map<String, dynamic>;

// Tipo para lista de JSON
typedef JsonList = List<Map<String, dynamic>>;
```

**Mixins de Parser (entity_parser.dart):**
```dart
// Converte Entity para JsonMap
mixin ToMap<Entity> on EntityParser<Entity> {
  JsonMap toMap(Entity entity);
}

// Converte JsonMap para Entity
mixin FromMap<Entity> on EntityParser<Entity> {
  Entity fromMap(JsonMap map);
}

// Extrai ID da Entity
mixin GetId<Entity, ID> on EntityParser<Entity> {
  ID getId(Entity entity);
}
```

**Mixins de Repositório (domain.dart):**
```dart
// Define contrato para criação
mixin Create<Entity, Response> {
  Future<Response> create(Entity entity);
}

// Define contrato para obter todos
mixin GetAll<Entity> {
  Future<List<Entity>> getAll();
}

// Define contrato para obter por ID
mixin GetById<Entity, ID> {
  Future<Entity> getById(ID id);
}

// Define contrato para deletar
mixin Delete<Entity, Response> {
  Future<Response> delete(Entity entity);
}
```

**user_entity.dart:**
```dart
import 'package:fk_booster/domain/domain.dart';

// Entidade que estende Entity do FK Booster
class UserEntity extends Entity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.birthday,
    required this.description,
    required this.createdAt,
  });

  const UserEntity.empty()
    : id = null,
      name = null,
      email = null,
      birthday = null,
      description = null,
      createdAt = null;

  final String? id;
  final String? name;
  final String? email;
  final Date? birthday;
  final String? description;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    birthday,
    description,
    createdAt,
  ];

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    Date? birthday,
    String? description,
    DateTime? createdAt,
  }) => UserEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    birthday: birthday ?? this.birthday,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
  );
}
```

**user_entity_parser.dart:**
```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/data/parser/entity_parser.dart';

// Interface abstrata que usa mixins do FK Booster
abstract class UserEntityParser extends EntityParser<UserEntity>
    with ToMap, FromMap, GetId<UserEntity, String> {}
```

**user_repository.dart:**
```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:fk_booster/domain/domain.dart';

// Interface de repositório que herda de Repository e usa mixins
abstract class UserRepository extends Repository<UserEntity>
    with
        Create<UserEntity, UserEntity>,
        GetAll<UserEntity>,
        GetById<UserEntity, String>,
        Delete<UserEntity, UserEntity> {}
```

### 2. Camada de Data (Implementação)

```
features/users/data/
├── repository/
│   └── user_api_repository.dart      # Implementação de repositório
└── entity_parser/
    └── user_entity_api_parser.dart   # Implementação de parser
```

**user_api_repository.dart:**
```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/data/data.dart';

// Implementação concreta do repositório que estende DioRepository
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

#### Padrão DioRepository

`DioRepository<Entity>` é uma classe abstrata que estende `Repository<Entity>` e fornece métodos `raw*` para operações HTTP:

```dart
// Método para criar entidade
Future<TResponse> rawCreate<TResponse>({
  required Entity entity,
  required ToMap<Entity> entityParser,      // Parser para serializar Entity
  required FromMap<TResponse> responseParser, // Parser para desserializar resposta
}) async

// Método para obter todas as entidades
Future<List<Entity>> rawGetAll({
  required FromMap<Entity> entityParser,  // Parser para converter JsonMap em Entity
}) async

// Método para obter por ID
Future<Entity> rawGetById<ID>({
  required ID id,
  required GetId<Entity, ID> idParser,      // Parser para extrair/enviar ID
  required FromMap<Entity> entityParser,    // Parser para converter resposta
}) async

// Método para deletar
Future<TResponse> rawDelete<TResponse, ID>({
  required Entity entity,
  required GetId<Entity, ID> idParser,      // Parser para extrair ID
  required FromMap<TResponse> responseParser, // Parser para resposta
}) async
```

**Características:**
- `baseUrl`: Define o endpoint base (ex: '/users')
- `createUrl`, `getAllUrl`, `getByIdUrl`, `deleteUrl`: Propriedades para customizar URLs
- Recebe `Dio` via constructor para fazer requisições HTTP
- Reutiliza os parsers para serialização/desserialização

**user_entity_api_parser.dart:**
```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:fk_booster/fk_booster.dart';

// Implementação concreta do parser
class UserEntityApiParser extends UserEntityParser {
  @override
  UserEntity fromMap(JsonMap map) => UserEntity(
    id: map.getString('id'),
    name: map.getString('name'),
    email: map.getString('email'),
    birthday: map.getDate('birthday'),
    description: map.getString('description'),
    createdAt: map.getDateTime('created_at'),
  );

  @override
  JsonMap toMap(UserEntity e) => JsonMap()
    ..add('id', e.id)
    ..add('name', e.name)
    ..add('email', e.email)
    ..add('description', e.description)
    ..add('birthday', e.birthday?.toApi());

  @override
  String getId(UserEntity entity) => entity.id ?? '';
}
```

---

## 📄 Arquitetura de Pages

Cada página segue um padrão padronizado com 3 componentes principais:

### Estrutura de Diretório

```
pages/users/
├── users_page.dart              # Widget StatefulWidget (UI)
├── users_view_model.dart        # ViewModel (lógica de apresentação)
└── users_injection.dart         # Injeção de dependências da página
```

### 1. **Page (users_page.dart)**

A página é responsável **apenas por renderização**. Herda de `ViewState` que gerencia o ciclo de vida e injeção.

#### Opção 1: Usando CommandBuilder (Recomendado)

```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/pages/users/users_injection.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:example/app/router/route_names.dart';
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
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(RouteNames.createUser),
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
              Text(
                'Error: ${state.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
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
    // TODO(users): Implement delete functionality
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
```

#### Opção 2: Usando Watch (Alternativa)

```dart
// ...importações...

body: Watch(
  dependencies: [viewModel.getAll],
  (_) {
    final state = viewModel.getAll.value;

    // Use os estados do Command para renderizar
    if (state is Running) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is Error) {
      return Center(
        child: Text('Error: ${(state as Error).error}'),
      );
    }

    if (state is Completed<List<UserEntity>>) {
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
    }

    return const SizedBox.shrink();
  },
),
```

**Diferenças entre CommandBuilder e Watch:**
- `CommandBuilder`: Mais limpo e legível, builders específicos para cada estado (recomendado)
- `Watch`: Mais flexível, permite lógica customizada entre estados

| Aspecto | CommandBuilder | Watch |
|--------|----------------|-------|
| **Legibilidade** | Excelente - código declarativo | Boa - requer pattern matching |
| **Builders Específicos** | Sim - um para cada estado | Não - genérico |
| **Flexibilidade** | Média - estados pré-definidos | Alta - lógica customizada |
| **Recomendado para** | Maioria dos casos | Lógica complexa entre estados |

**Quando usar CommandBuilder:**
- UI simples com estados bem definidos (Loading, Erro, Sucesso)
- Cada estado tem uma visualização clara
- Você quer código mais legível e manutenível

**Quando usar Watch:**
- Lógica complexa envolvendo múltiplos estados
- Você precisa acessar o estado diretamente
- Requer transformações de dados antes de renderizar

### 2. **ViewModel (users_view_model.dart)**

O ViewModel contém a lógica de apresentação. Pode ser `StatelessViewModel` (sem estado local) ou `StatefulViewModel` (com estado local).

```dart
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/fk_booster.dart';

// Exemplo 1: StatelessViewModel (apenas commands)
class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  // Commands são Signals que expõem estados (Running, Completed, Error)
  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  @override
  void onViewInit() {
    // Executar lógica ao inicializar a view
    unawaited(getAll.execute());
  }

  @override
  void onViewDispose() {
    // Limpar recursos quando a view é descartada
  }
}
```

```dart
// Exemplo 2: StatefulViewModel (com estado local)
class CreateUserViewModel extends StatefulViewModel<UserEntity> {
  CreateUserViewModel(this._userRepository) 
    : super(const UserEntity.empty()); // Estado inicial

  final UserRepository _userRepository;
  final formKey = GlobalKey<FormState>();

  // value getter/setter vêm da classe Signal base
  UserEntity get form => value;

  Future<void> onSavePressed() async {
    if (formKey.currentState!.validate()) {
      final userCreated = await _userRepository.create(value);
      print(userCreated);
    }
  }
}
```

**Diferenças:**

| Aspecto | StatelessViewModel | StatefulViewModel |
|--------|------------------|-------------------|
| Uso | Listas, visualizações | Formulários, entrada do usuário |
| Herança | `extends StatelessViewModel` | `extends StatefulViewModel<State>` |
| Estado | Apenas Commands | `value` property + Commands |
| Inicialização | `super()` padrão | `super(initialValue)` |

### 3. **Injection (users_injection.dart)**

A injeção registra todas as dependências necessárias para a página.

```dart
import 'package:example/app/features/users/data/entity_parser/user_entity_api_parser.dart';
import 'package:example/app/features/users/data/repository/user_api_repository.dart';
import 'package:example/app/features/users/domain/entity/user_entity_parser.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:fk_booster/fk_booster.dart';

class UsersInjection extends DependencyInjection {
  // Nome do scope (deve ser único)
  UsersInjection() : super('users');

  @override
  void registerDependencies(GetIt i) {
    // Chama super para criar o novo scope
    super.registerDependencies(i);

    i
      // Registra o Parser
      ..registerLazySingleton<UserEntityParser>(
        UserEntityApiParser.new,
      )
      // Registra o Repository
      ..registerLazySingleton<UserRepository>(
        () => UserApiRepository(
          parser: i.get<UserEntityParser>(),
          dio: i.get<Dio>(), // Compartilhado da injeção global
        ),
      )
      // Registra o ViewModel
      ..registerLazySingleton<UsersViewModel>(
        () => UsersViewModel(userRepository: i.get<UserRepository>()),
      );
  }
}
```

**Princípios:**
- Cada página tem seu próprio `DependencyInjection` com escopo isolado
- O scope é criado em `initState` e descartado em `dispose`
- Use `registerLazySingleton` para instanciar sob demanda
- Use `registerSingleton` para instâncias que devem ser criadas imediatamente
- Reutilize dependências globais (como Dio) do get_it principal

---

## 🎨 Componentes de Apresentação

### CommandBuilder

O `CommandBuilder` é um widget que simplifica a renderização condicionada baseada no estado de um `Command`.

```dart
/// Signature do CommandBuilder
CommandBuilder<T>({
  required Command<T> command,
  Widget Function(ViewModelState<T> state)? builder,
  Widget Function(Initial<T> state)? initialStateBuilder,
  Widget Function(Running<T> state)? loadingBuilder,
  Widget Function(Completed<T> state)? completedBuilder,
  Widget Function(Error<T> state)? errorBuilder,
})
```

**Características:**
- Observa automaticamente mudanças no estado do Command
- Oferece builders específicos para cada estado
- Se um builder específico não for fornecido, tenta usar o `builder` genérico
- Se nenhum builder for fornecido, exibe um `SizedBox.shrink()`
- Evita repetição de lógica de pattern matching manual

**Exemplo de Uso:**
```dart
CommandBuilder<List<UserEntity>>(
  command: viewModel.getAll,
  loadingBuilder: (_) => const Center(
    child: CircularProgressIndicator(),
  ),
  completedBuilder: (state) {
    final users = state.data;
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(users[index].name ?? ''),
      ),
    );
  },
  errorBuilder: (state) => Center(
    child: Text('Error: ${state.error}'),
  ),
)
```

---

O padrão Command encapsula ações executáveis com gerenciamento de estado automático (Running, Completed, Error).

### Estados do Command

```dart
// Definidos em view_model_states.dart

abstract class ViewModelState<T> {
  const ViewModelState();
}

class Initial<T> extends ViewModelState<T> {
  // Estado inicial, nada foi executado
}

class Running<T> extends ViewModelState<T> {
  // Comando está em execução
}

class Completed<T> extends ViewModelState<T> {
  final T data;
  // Comando completou com sucesso e retornou data
}

class Error<T> extends ViewModelState<T> {
  final Object error;
  // Comando falhou com erro
}
```

### Tipos de Commands

```dart
// Command0: Sem argumentos
final getAll = Command0<List<UserEntity>>(
  () => userRepository.getAll(),
);

// Usar:
await getAll.execute();
```

```dart
// Command1: Um argumento
final deleteUser = Command1<void, String>(
  (id) => userRepository.delete(id),
);

// Usar:
await deleteUser.execute('user-id');
```

### Estrutura Interna

```dart
abstract class Command<T> extends Signal<ViewModelState<T>> {
  // Properties úteis
  bool get running => value is Running;
  bool get error => value is Error;
  bool get completed => value is Completed;
  T? get result => value is Completed<T> ? (value as Completed<T>).data : null;

  // Métodos
  void clearResult() => value = Initial._();
  Future<void> _execute(CommandAction0<T> action) async {
    if (running) return; // Previne execução duplicada
    value = Running._();
    try {
      value = value.toLoaded(data: await action());
    } on Exception catch (exception) {
      value = value.toError(error: exception);
    }
  }
}
```

### Exemplo Completo de Uso

```dart
// ViewModel
class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  late final deleteUser = Command1<void, String>(
    userRepository.delete,
  );

  @override
  void onViewInit() {
    unawaited(getAll.execute());
  }
}

// Page
body: Watch(
  dependencies: [viewModel.getAll],
  (_) {
    final state = viewModel.getAll.value;

    if (state is Running) {
      return const CircularProgressIndicator();
    }

    if (state is Error) {
      return Text('Erro: ${(state as Error).error}');
    }

    if (state is Completed<List<UserEntity>>) {
      return ListView(
        children: state.data.map((user) => ListTile(
          title: Text(user.name ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => viewModel.deleteUser.execute(user.id ?? ''),
          ),
        )).toList(),
      );
    }

    return const SizedBox.shrink();
  },
),
```

---

## 🗂️ Sistema de Rotas

As rotas são organizadas em 3 arquivos para manter clareza e reutilização.

### 1. **route_names.dart** - Constantes de nomes

```dart
abstract class RouteNames {
  static const String users = 'users';
  static const String createUser = 'create-user';
  static const String userDetail = 'user-detail';
}
```

### 2. **route_paths.dart** - Caminhos URL

```dart
abstract class RoutePaths {
  static const String users = '/users';
  static const String create = '/create';
  static const String detail = '/detail/:id';
}
```

### 3. **router.dart** - Configuração do Go Router

```dart
import 'package:example/app/pages/create_user/create_user_page.dart';
import 'package:example/app/pages/users/users_page.dart';
import 'package:example/app/router/route_names.dart';
import 'package:example/app/router/route_paths.dart';
import 'package:fk_booster/fk_booster.dart';

class AppRouter {
  AppRouter();

  final GoRouter router = GoRouter(
    initialLocation: RoutePaths.users,
    routes: <RouteBase>[
      GoRoute(
        name: RouteNames.users,
        path: RoutePaths.users,
        builder: (_, _) => const UsersPage(),
        routes: [
          GoRoute(
            name: RouteNames.createUser,
            path: RoutePaths.create,
            builder: (_, _) => const CreateUserPage(),
          ),
        ],
      ),
    ],
  );
}
```

### Navegação

```dart
// Por nome (recomendado)
context.goNamed(RouteNames.createUser);
context.goNamed(RouteNames.userDetail, pathParameters: {'id': 'user-123'});

// Por caminho (evitar)
context.go('/users/detail/user-123');

// Com parâmetros
context.goNamed(RouteNames.userDetail, pathParameters: {'id': userId});
```

---

## 💉 Sistema de Injeção de Dependências

O projeto usa `get_it` com escopos. Há duas camadas:

### 1. Injeção Global (startup_injection.dart)

Registra dependências que são reutilizadas em toda a aplicação.

```dart
class StartupInjection extends DependencyInjection {
  const StartupInjection() : super('Startup');

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i);
    
    // Cliente HTTP global
    i.registerLazySingleton(
      () => Dio()
        ..options = BaseOptions(
          baseUrl: 'http://localhost:8000',
        ),
    );
    
    // Router global
    i.registerLazySingleton(AppRouter.new);
    
    // Outros serviços globais...
  }
}
```

### 2. Injeção por Página (page_injection.dart)

Cada página tem seu próprio escopo que é criado e destruído com a página.

```dart
class UsersInjection extends DependencyInjection {
  UsersInjection() : super('users'); // Escopo isolado

  @override
  void registerDependencies(GetIt i) {
    super.registerDependencies(i); // Cria novo escopo

    i
      ..registerLazySingleton<UserEntityParser>(UserEntityApiParser.new)
      ..registerLazySingleton<UserRepository>(
        () => UserApiRepository(
          parser: i.get<UserEntityParser>(),
          dio: i.get<Dio>(), // Acessa dependência global
        ),
      )
      ..registerLazySingleton<UsersViewModel>(
        () => UsersViewModel(userRepository: i.get<UserRepository>()),
      );
  }
}
```

### Ciclo de Vida

```dart
class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  late final V viewModel;
  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    injection?.registerDependencies(_getIt); // ← Cria escopo
    initViewModel();
    viewModel.onViewInit();
  }

  void initViewModel() => viewModel = _getIt.get<UsersViewModel>();

  @override
  Future<void> dispose() async {
    super.dispose();
    viewModel.onViewDispose();
    await injection?.disposeDependencies(_getIt); // ← Destrói escopo
  }

  DependencyInjection? get injection => UsersInjection();
}
```

---

## 📋 Checklist para Novas Features

Ao criar uma nova feature, siga este checklist:

### Domain Layer
- [ ] Criar `domain/entity/{entity}.dart` com a classe de entidade
- [ ] Criar `domain/entity/{entity}_parser.dart` com a interface de parser
- [ ] Criar `domain/repository/{repository}.dart` com a interface de repositório

### Data Layer
- [ ] Criar `data/repository/{entity}_api_repository.dart` implementando o repositório
- [ ] Criar `data/entity_parser/{entity}_api_parser.dart` implementando o parser

### Presentation Layer
- [ ] Criar `pages/{page}/{page}_page.dart` estendendo ViewState
- [ ] Criar `pages/{page}/{page}_view_model.dart` (StatelessViewModel ou StatefulViewModel)
- [ ] Criar `pages/{page}/{page}_injection.dart` estendendo DependencyInjection
- [ ] Adicionar Commands necessários no ViewModel

### Routes
- [ ] Adicionar nome em `router/route_names.dart`
- [ ] Adicionar caminho em `router/route_paths.dart`
- [ ] Adicionar GoRoute em `router/router.dart`

---

## 🎯 Boas Práticas

1. **Separação de Responsabilidades**
    - Page: Apenas renderização
    - ViewModel: Lógica de apresentação
    - Repository: Acesso a dados
    - Entity: Modelo de dados puro

2. **Reatividade**
    - Use Commands para ações assíncronas
    - Use Watch para reagir a mudanças
    - Use Signals para estado reativo

3. **Injeção de Dependências**
    - Sempre use interfaces abstratas no domain
    - Implemente no data layer
    - Registre no injection layer

4. **Nomeação**
    - PascalCase: Classes, Enums
    - camelCase: Variáveis, métodos, propriedades
    - UPPER_CASE: Constantes
    - `_private`: Membros privados

5. **Tratamento de Erros**
    - Commands já capuram exceções
    - Exiba estado Error na UI
    - Use o valor de error para debugging

6. **Reutilização**
    - Crie parsers reutilizáveis
    - Compartilhe repositórios entre páginas via injeção global
    - Evite duplicação de lógica

---

## 🔧 Extensions Úteis do FK Booster

### JsonMap Extensions (json_map_parsers.dart)

```dart
// Obtém string segura do JsonMap
String? getString(String key)

// Obtém Date segura do JsonMap (converte de ISO 8601)
Date? getDate(String key)

// Obtém DateTime segura do JsonMap (converte de ISO 8601)
DateTime? getDateTime(String key)

// Adiciona valor ao JsonMap
void add(String key, String? value, {bool forceNull = false})
```

### Date Extensions (date_parsers.dart)

```dart
// Converte Date para string ISO 8601 para enviar à API
String? toApi() // Exemplo: '2023-12-18'

// Converte DateTime para string ISO 8601 para enviar à API
String? toApi() // Exemplo: '2023-12-18T15:30:45.123456'
```

**Exemplo de Uso:**
```dart
// Leitura do JsonMap
final user = UserEntity(
  id: map.getString('id'),
  birthday: map.getDate('birthday'),
  createdAt: map.getDateTime('created_at'),
);

// Escrita para JsonMap
final json = JsonMap()
  ..add('name', user.name)
  ..add('birthday', user.birthday?.toApi())
  ..add('created_at', user.createdAt?.toApi());
```

---

## 📚 Referência Rápida de Imports

```dart
// Acesso a signals
import 'package:signals/signals.dart';

// Componentes FK Booster
import 'package:fk_booster/fk_booster.dart';
// Inclui: Command0, Command1, ViewModelState, ViewModel, etc.

// Navegação
import 'package:go_router/go_router.dart';

// Injeção
import 'package:get_it/get_it.dart';

// HTTP
import 'package:dio/dio.dart';
```

---

Última atualização: 2025-12-18

