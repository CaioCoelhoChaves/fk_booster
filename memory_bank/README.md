Memory Bank for fk_booster-enabled Flutter apps

Purpose
- Provide AI agents (e.g., GitHub Copilot) with the exact folder structure and conventions expected by fk_booster.
- Make these files copy-and-paste friendly for projects that consume this package.

How to use
1) Keep this `memory_bank` folder at the root (or under `lib/` if you prefer). It only contains docs for agents; it has no runtime code.
2) Tell your AI agent to read these files before making edits (see `AI_INSTRUCTIONS.md`).
3) Follow the templates and conventions when adding features and pages.
4) See `DOCUMENTATION_MAP.md` for a visual guide of how files relate to each other.

Contents
- `AI_INSTRUCTIONS.md`: A short instruction for AI agents to load and honor these conventions.
- `DOCUMENTATION_MAP.md`: Visual guide showing how all documentation files relate and recommended reading paths.
- `PROJECT_STRUCTURE.md`: The expected folder structure and naming conventions at app root, features, and pages.
- `DEPENDENCY_INJECTION.md`: Complete guide for the DI system using GetIt with scoped lifecycle management.
- `VIEWSTATE.md`: Complete guide for ViewState and ViewModel integration with DI and lifecycle hooks.
- `ENTITIES.md`: Complete guide for creating and using Entities (domain layer only).
- `ENTITY_PARSERS.md`: Complete guide for designing and implementing EntityParsers (contracts in domain, implementations in data).
- `REPOSITORIES.md`: Complete guide for designing and implementing Repositories (contracts in domain, implementations in data).
- `SCAFFOLD_TEMPLATES.md`: Copy-ready templates and checklists for adding a new feature and a new page.

Copy to other projects
- Copy this entire `memory_bank` folder into the target project.
- Update any project-specific references if needed, but the conventions are designed to be generic.

Notes
- These docs assume a Flutter project using fk_booster for MVVM/ViewState/Command patterns and DI.
- If a consuming project doesn’t expose full source, these files still describe how the code should be organized.
