# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-alpha] - 2025-12-19

### Added

#### Widgets
- `Gap`

#### Application Architecture Classes

##### Presentation
- `Command0`, `Command1` (FKBooster own implementation of [Command Pattern](https://docs.flutter.dev/app-architecture/design-patterns/command))
- `ViewState` to use in StatefulWidgets (The entry point of the FKBooster architecture)
- `ViewModel` to manage view state and handle user interactions
- ViewModelStates (`Initial`, `Running`, `Completed` and `Error`)

##### Domain
- `Date` class to deal with date objects (instead using DateTime without passing the time variables)
- `Entity` base class for FKBooster entities
- `Repository` interface to be implemented by the data layer repositories with the following methods (`rawCreate`, `rawGetById`, `rawGetAll`, `rawUpdate` and `rawDelete`)
- Repository initial contracts mixins (`Create`, `Delete`, `GetAll`, `GetById` and `Update`)

##### Data
- DateParsers extension with the `toApi` method
- DateTimeParsers extension with the `toApi` method
- Typedefs: `JsonMap`, `JsonList` and `EntityListParser`
- JsonMapParsers extension on `JsonMap` (`getString`, `getDate` and `getDateTime`)
- `toEntityListParser` method
- `DioRepository` to provide an HTTP `repository` implementation using Dio.

##### Dependency Injection
- `DependencyInjection` class abstraction
