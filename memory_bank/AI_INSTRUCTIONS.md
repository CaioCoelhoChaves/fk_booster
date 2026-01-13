AI Agent Bootstrap Instructions

Read-first directive
- Before acting on this repository (or any repo that has this folder copied), load and apply all conventions documented in:
  - `memory_bank/ARCHITECTURE_OVERVIEW.md` (visual guide - start here!)
  - `memory_bank/PROJECT_STRUCTURE.md`
  - `memory_bank/DEPENDENCY_INJECTION.md`
  - `memory_bank/VIEWSTATE.md`
  - `memory_bank/COMMANDS.md`
  - `memory_bank/VIEWMODEL_STATES.md`
  - `memory_bank/VIEWMODEL_INTEGRATION.md` (recommended for understanding integration)
  - `memory_bank/ENTITIES.md`
  - `memory_bank/ENTITY_PARSERS.md`
  - `memory_bank/REPOSITORIES.md`
  - `memory_bank/SCAFFOLD_TEMPLATES.md`

Goals for the agent
- Adhere strictly to fk_booster architecture: split business logic into features (domain/data) and UI into pages (page/view_model/injection).
- Maintain naming conventions and file placements outlined in the memory bank.
- When creating or editing code:
  - Prefer adding interfaces in `domain/` and implementations in `data/`.
  - Bind dependencies in `startup_injection.dart` (global) or `<page_name>_injection.dart` (local).
  - Use ViewState (not State) for page widgets to enable automatic DI and ViewModel integration.
  - Use fk_booster ViewModel/ViewState/Command patterns for UI interactions:
    - Define `Command0<T>` for operations with no arguments
    - Define `Command1<T, A>` for operations with one argument
    - Use `CommandBuilder<T>` widgets to render reactive UI based on command states
  - Implement state-aware UI by providing builders for loading, completed, and error states

Behavioral rules
- Do not place UI code in `features/`.
- Do not place business logic inside page widgets; put it inside ViewModels.
- Do not break naming conventions or folder layout unless explicitly instructed.
- If something is missing, scaffold using the templates and explain assumptions briefly in comments.

Scope of application
- These instructions are copy-and-paste friendly. If you’re in a different project that uses fk_booster, assume these conventions by default.
