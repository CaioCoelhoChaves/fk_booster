# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Core classes:
    - FkEntity
    - FkEntityParser
    - FkRepository
      - Mixins:
        - FkDelete
        - FkGetAll
        - FkMultipleDelete
        - FkCreate
        - FkUpdate
        - FkMultipleUpdate
    - FkRestRepository
      - Mixins:
        - FkRestCreate
    - FkCommand
    - FkView
    - FkViewModel
    - FkViewState
- FkInjections to dependency injections.
- Http classes:
  - FkHttpClient
  - FkHttpException
  - FkHttpResponse
  - FkDioHttpClient
- FkRoute
- Widgets:
  - Gap
- example project
