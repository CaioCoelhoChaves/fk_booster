fk_booster Project Structure Guide

Overview
This guide defines the expected folder structure for Flutter apps using fk_booster. It’s derived from `example/lib/app` in this package and designed to be reused in other projects.

App root (`lib/app`)
- `app.dart`: App-level composition (MaterialApp/Router, theme, global providers).
- `startup_injection.dart`: Global DI registration for app-wide services.
- `router/`: Routing setup for the application.
- `theme/`: App theming (ThemeData, color schemes, text styles).
- `features/`: Business modules using clean architecture (domain/data layers).
- `pages/`: UI screens with ViewModel and local DI.

Features (`lib/app/features/<feature_name>/`)
Layered structure:
- `domain/`
  - `entity/`: Domain entities and value objects. Pure and framework-agnostic.
  - `repository/`: Abstract repository interfaces that define the feature contract.
- `data/`
  - `entity_parser/`: Parsers/mappers between raw IO formats and domain entities.
  - `repository/`: Concrete repository implementations that fulfill domain interfaces; depend on parsers and IO.

Naming conventions:
- Feature folder: snake case of the concept (e.g., `users`).
- Entities: singular file names (e.g., `user.dart`).
- Domain repository interface: `<feature>_repository.dart`.
- Data repository implementation: `<feature>_repository_impl.dart`.

Pages (`lib/app/pages/<page_name>/`)
Each page bundles UI, ViewModel, and local DI:
- `<page_name>_page.dart`: Flutter widget screen; binds to ViewModel, renders by `ViewState`, triggers `Command`s.
- `<page_name>_view_model.dart`: State manager using fk_booster ViewModel/ViewState/Command patterns; calls domain repositories.
- `<page_name>_injection.dart`: Page-local DI that wires interfaces to implementations and constructs the ViewModel.

Example
- `lib/app/pages/users/`
  - `users_page.dart`
  - `users_view_model.dart`
  - `users_injection.dart`
- `lib/app/features/users/`
  - `domain/entity/` and `domain/repository/`
  - `data/entity_parser/` and `data/repository/`

Dependency direction
- domain → no dependency on data or UI
- data → depends on domain (implements interfaces) and external sources
- pages → depend on domain; DI binds to data implementations out of band

Shared widgets and utilities
- Keep shared UI widgets in `lib/widgets/` (outside features).
- Keep shared types/providers in `lib/injection/` or app-level files, not inside features.

