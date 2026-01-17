# Memory Bank Documentation Map

This document shows how all memory bank files relate to each other and when to use each one.

## Quick Reference

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI_INSTRUCTIONS.md                        │
│                  (Start here - tells AI what to read)           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ PROJECT_STRUCTURE│      │   SCAFFOLD       │
    │      .md         │      │  TEMPLATES.md    │
    │   (Overview)     │      │  (Quick start)   │
    └────────┬─────────┘      └──────────────────┘
             │
      ┌──────┴──────┬──────────┬──────────┬──────────┬─────────────┐
      │             │          │          │          │             │
      ▼             ▼          ▼          ▼          ▼             ▼
┌──────────┐  ┌──────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
│DEPENDENCY│  │VIEWSTATE │ │COMMANDS│ │ENTITIES│ │PARSERS │ │REPOSIT- │
│INJECTION │  │   .md    │ │  .md   │ │  .md   │ │  .md   │ │ORIES.md  │
│   .md    │  │          │ │        │ │        │ │        │ │          │
└────┬─────┘  └────┬─────┘ └────┬───┘ └────────┘ └────────┘ └──────────┘
     │             │            │
     │             └────────┬───┘
     │                      │
     └──────────┬───────────┘
                │
                ▼
        ┌──────────────────────┐
        │VIEWMODEL_STATES.md   │
        │ (State definitions)  │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │VIEWMODEL_INTEGRATION │
        │     .md              │
        │(Integration guide)   │
        └──────────────────────┘
```

---

## Documentation Hierarchy

### 1. Entry Point & Visual Overview
**`AI_INSTRUCTIONS.md`** - Bootstrap for agents
- Tells AI agents which files to read
- Defines behavioral rules
- Sets scope of application

**`ARCHITECTURE_OVERVIEW.md`** - Visual guide (START HERE!)
- Complete architecture diagram with all layers
- Data flow examples (step-by-step flow)
- Layer breakdown with responsibilities
- File organization
- State management flow
- When to use each component

**`PROJECT_STRUCTURE.md`** - Folder structure conventions
- App root structure (`lib/app/`)
- Features structure (domain/data layers)
- Pages structure (UI layer)
- Naming conventions

### 2. Quick Start
**`SCAFFOLD_TEMPLATES.md`** - Copy-paste templates
- New feature scaffold
- New page scaffold
- Complete working examples
- **Cross-references**: All other docs

### 3. Core Systems (Read these for implementation)

#### UI Layer (Pages)
- **`DEPENDENCY_INJECTION.md`** ⭐ Core system
  - GetIt scoped DI system
  - StartupInjection (global)
  - Page injections (scoped)
  - Registration methods
  - **Cross-references**: VIEWSTATE.md

- **`VIEWSTATE.md`** ⭐ Core system
  - ViewState class (replaces State)
  - ViewModel types (Stateless/Stateful)
  - Lifecycle integration
  - DI integration
  - **Cross-references**: DEPENDENCY_INJECTION.md, COMMANDS.md

- **`COMMANDS.md`** ⭐ Core system
  - Command<T> abstract base
  - Command0<T> and Command1<T, A>
  - ViewModelState types (Initial, Running, Completed, Error)
  - CommandBuilder widget for reactive UI
  - Command execution and state management
  - **Cross-references**: VIEWSTATE.md, VIEWMODEL_STATES.md

- **`VIEWMODEL_STATES.md`** (Reference)
  - Initial<T> state
  - Running<T> state
  - Completed<T> state
  - Error<T> state
  - State transition methods
  - Practical examples for each state
  - **Cross-references**: COMMANDS.md

#### Business Layer (Features)
- **`ENTITIES.md`**
  - Domain entities (pure business objects)
  - Entity conventions
  - Immutability patterns
  - Value objects
  - **Cross-references**: ENTITY_PARSERS.md

- **`ENTITY_PARSERS.md`**
  - Parser interfaces (domain)
  - Parser implementations (data)
  - JSON/API parsing
  - Type conversions
  - **Cross-references**: ENTITIES.md, REPOSITORIES.md

- **`REPOSITORIES.md`**
  - Repository interfaces (domain)
  - Repository implementations (data)
  - Data source integration
  - Error handling
  - **Cross-references**: ENTITY_PARSERS.md, DEPENDENCY_INJECTION.md

### 4. Integration Guide (Advanced)

**`VIEWMODEL_INTEGRATION.md`** - How it all works together
- Complete lifecycle flows (page open → load → close)
- Integration examples combining DI, ViewState, ViewModel, Commands
- Best practices and patterns
- Testing strategies
- **Cross-references**: All core system docs (DI, ViewState, Commands, ViewModelStates)
  - Value objects
  - **Cross-references**: ENTITY_PARSERS.md

- **`ENTITY_PARSERS.md`**
  - Parser interfaces (domain)
  - Parser implementations (data)
  - JSON/API parsing
  - Type conversions
  - **Cross-references**: ENTITIES.md, REPOSITORIES.md

- **`REPOSITORIES.md`**
  - Repository interfaces (domain)
  - Repository implementations (data)
  - Data source integration
  - Error handling
  - **Cross-references**: ENTITY_PARSERS.md, DEPENDENCY_INJECTION.md

### 4. Quick Start
**`SCAFFOLD_TEMPLATES.md`** - Copy-paste templates
- New feature scaffold
- New page scaffold
- Complete working examples
- **Cross-references**: All other docs

---

## When to Use Each File

### Creating a New Page (Complete Flow)
1. **Quick start**: `SCAFFOLD_TEMPLATES.md` (Page section) for copy-ready code
2. **Understanding**: `VIEWMODEL_INTEGRATION.md` to see how everything connects
3. **Details**: Reference specific docs as needed:
   - `DEPENDENCY_INJECTION.md` for DI setup
   - `VIEWSTATE.md` for ViewState lifecycle
   - `COMMANDS.md` for Command patterns

**Why this order**: See working code first, then understand the integration, then dive into details.

### Creating a New Feature (Complete Flow)
1. **Quick start**: `SCAFFOLD_TEMPLATES.md` (Feature section) for copy-ready code
2. **Details**: Read in sequence:
   - `ENTITIES.md` for entity design
   - `ENTITY_PARSERS.md` for parser implementation
   - `REPOSITORIES.md` for repository patterns
3. **Integration**: Use `VIEWMODEL_INTEGRATION.md` to see how repositories flow to UI

### Understanding the Full Architecture (Sequential Reading)
1. `AI_INSTRUCTIONS.md` - Start here (behavioral rules)
2. `PROJECT_STRUCTURE.md` - App organization
3. `DEPENDENCY_INJECTION.md` - DI system foundations
4. `VIEWSTATE.md` - Widget lifecycle integration
5. `COMMANDS.md` - Async operations and state
6. `VIEWMODEL_INTEGRATION.md` - How DI, ViewState, Commands connect
7. `ENTITIES.md` - Domain layer design
8. `ENTITY_PARSERS.md` - Data transformation
9. `REPOSITORIES.md` - Data access layer
10. `SCAFFOLD_TEMPLATES.md` - Reference templates for everything

---

## File Dependencies

### DEPENDENCY_INJECTION.md
**Depends on**: Nothing (standalone system)
**Referenced by**: 
- VIEWSTATE.md (ViewState uses DI)
- REPOSITORIES.md (Repository registration)
- SCAFFOLD_TEMPLATES.md (Page templates)

### VIEWSTATE.md
**Depends on**: 
- DEPENDENCY_INJECTION.md (uses DI system)
**Referenced by**:
- COMMANDS.md (works with Commands)
- VIEWMODEL_INTEGRATION.md (integration guide)
- SCAFFOLD_TEMPLATES.md (Page templates)

### COMMANDS.md
**Depends on**:
- VIEWMODEL_STATES.md (uses ViewModelState)
**Referenced by**:
- VIEWMODEL_STATES.md (detailed state guide)
- VIEWMODEL_INTEGRATION.md (integration guide)
- SCAFFOLD_TEMPLATES.md (command examples)

### VIEWMODEL_STATES.md
**Depends on**:
- COMMANDS.md (explains states used by commands)
**Referenced by**:
- VIEWMODEL_INTEGRATION.md (state transitions in lifecycle)
- SCAFFOLD_TEMPLATES.md (state handling examples)

### ENTITIES.md
**Depends on**: Nothing (pure domain)
**Referenced by**:
- ENTITY_PARSERS.md (parses to/from entities)
- REPOSITORIES.md (returns entities)
- VIEWMODEL_INTEGRATION.md (entities in data flow)
- SCAFFOLD_TEMPLATES.md (entity templates)

### ENTITY_PARSERS.md
**Depends on**:
- ENTITIES.md (parses entities)
**Referenced by**:
- REPOSITORIES.md (repositories use parsers)
- VIEWMODEL_INTEGRATION.md (parsers in data flow)
- SCAFFOLD_TEMPLATES.md (parser templates)

### REPOSITORIES.md
**Depends on**:
- ENTITIES.md (returns entities)
- ENTITY_PARSERS.md (uses parsers)
- DEPENDENCY_INJECTION.md (registered in DI)
**Referenced by**:
- VIEWMODEL_INTEGRATION.md (shows repository to UI flow)
- SCAFFOLD_TEMPLATES.md (repository templates)

### VIEWMODEL_INTEGRATION.md
**Depends on**:
- DEPENDENCY_INJECTION.md (explains DI in integration)
- VIEWSTATE.md (explains ViewState in integration)
- COMMANDS.md (explains Commands in integration)
- REPOSITORIES.md (shows how repos connect to UI)
**Referenced by**:
- None (integration/reference guide)

### SCAFFOLD_TEMPLATES.md
**Depends on**: All other files (uses all patterns)
**Referenced by**: None (leaf node)

---

## Recommended Reading Paths

### Path 1: UI Developer (Focus on Pages)
```
AI_INSTRUCTIONS.md
    ↓
PROJECT_STRUCTURE.md (Pages section)
    ↓
DEPENDENCY_INJECTION.md ⭐ Critical
    ↓
VIEWSTATE.md ⭐ Critical
    ↓
VIEWSTATE.md ⭐ Critical
    ↓
COMMANDS.md ⭐ Critical
    ↓
VIEWMODEL_INTEGRATION.md (See how it all connects)
    ↓
SCAFFOLD_TEMPLATES.md (Page section)
```

### Path 2: Backend/Business Logic Developer (Focus on Features)
```
AI_INSTRUCTIONS.md
    ↓
PROJECT_STRUCTURE.md (Features section)
    ↓
ENTITIES.md
    ↓
ENTITY_PARSERS.md
    ↓
REPOSITORIES.md
    ↓
DEPENDENCY_INJECTION.md (for registration)
    ↓
VIEWMODEL_INTEGRATION.md (See how repos connect to UI)
    ↓
SCAFFOLD_TEMPLATES.md (Feature section)
```

### Path 3: Full-Stack Developer (Complete Flow)
```
AI_INSTRUCTIONS.md
    ↓
PROJECT_STRUCTURE.md
    ↓
┌─────────────────┬──────────────────────┐
│   UI Side       │   Business Logic     │
│                 │   Side               │
│ DI → ViewState  │ Entities →           │
│ → Commands      │ Parsers →            │
│                 │ Repositories         │
└─────────────────┴──────────────────────┘
    ↓
VIEWMODEL_INTEGRATION.md (See complete flow)
    ↓
SCAFFOLD_TEMPLATES.md (Copy-paste everything)
```

---

## Cross-Reference Summary

| File | References | Referenced By |
|------|-----------|---------------|
| AI_INSTRUCTIONS.md | All files | None |
| PROJECT_STRUCTURE.md | None | All files |
| DEPENDENCY_INJECTION.md | None | VIEWSTATE, COMMANDS, REPOSITORIES, SCAFFOLD_TEMPLATES |
| VIEWSTATE.md | DEPENDENCY_INJECTION, COMMANDS | COMMANDS, SCAFFOLD_TEMPLATES |
| COMMANDS.md | VIEWSTATE | SCAFFOLD_TEMPLATES |
| ENTITIES.md | None | ENTITY_PARSERS, REPOSITORIES, SCAFFOLD_TEMPLATES |
| ENTITY_PARSERS.md | ENTITIES | REPOSITORIES, SCAFFOLD_TEMPLATES |
| REPOSITORIES.md | ENTITIES, ENTITY_PARSERS, DEPENDENCY_INJECTION | SCAFFOLD_TEMPLATES |
| SCAFFOLD_TEMPLATES.md | All files | None |

---

## Quick Tips

### For AI Agents
1. Always start with `AI_INSTRUCTIONS.md`
2. If creating a page: Focus on `DEPENDENCY_INJECTION.md` + `VIEWSTATE.md`
3. If creating a feature: Focus on `ENTITIES.md` → `ENTITY_PARSERS.md` → `REPOSITORIES.md`
4. Use `SCAFFOLD_TEMPLATES.md` for quick scaffolding

### For Developers
1. **New to fk_booster?** Read in this order:
   - README.md → AI_INSTRUCTIONS.md → PROJECT_STRUCTURE.md → Pick your path above

2. **Need a quick template?** Jump straight to `SCAFFOLD_TEMPLATES.md`

3. **Debugging DI issues?** Read `DEPENDENCY_INJECTION.md` → `VIEWSTATE.md`

4. **Understanding data flow?** Read `ENTITIES.md` → `ENTITY_PARSERS.md` → `REPOSITORIES.md`

---

## Key Integrations

### DI + ViewState + Commands (Pages)
These three systems work together for complete page architecture:
- **DI**: Manages dependency lifecycle (create/dispose)
- **ViewState**: Integrates DI with Flutter widget lifecycle
- **Commands**: Execute async operations and emit state updates
- **Result**: Automatic dependency management, lifecycle handling, and reactive UI state

**Read together**: `DEPENDENCY_INJECTION.md` + `VIEWSTATE.md` + `COMMANDS.md`

### Entities + Parsers + Repositories (Features)
These three layers work together for business logic:
- **Entities**: Define business objects (domain)
- **Parsers**: Convert between formats (data)
- **Repositories**: Coordinate data access (data → domain interface)
- **Result**: Clean architecture with testable layers

**Read together**: `ENTITIES.md` + `ENTITY_PARSERS.md` + `REPOSITORIES.md`

### Complete Flow: From Repository to UI
```
Repository.getAll()
    ↓ (returns Future<Entity>)
Command0<Entity>(repository.getAll)
    ↓ (emits ViewModelState)
CommandBuilder<Entity> widget
    ↓ (renders based on state)
UI (Loading → Result/Error)
```

See `COMMANDS.md` for detailed flow diagrams.

---

## Documentation Principles

1. **Standalone but connected**: Each file can be read independently, but cross-references provide context
2. **Copy-paste friendly**: All documentation can be copied to other projects
3. **Examples first**: Every concept includes working examples
4. **Bottom-up approach**: Build from simplest concepts to complex integrations
5. **AI-optimized**: Structured for easy parsing by AI agents

---

## Summary

The memory bank is organized as a **directed acyclic graph (DAG)** of documentation:
- **Entry**: AI_INSTRUCTIONS.md
- **Overview**: PROJECT_STRUCTURE.md
- **Core Systems**: DEPENDENCY_INJECTION.md + VIEWSTATE.md (UI) | ENTITIES.md + ENTITY_PARSERS.md + REPOSITORIES.md (Business)
- **Quick Start**: SCAFFOLD_TEMPLATES.md

**Navigation tip**: Follow the arrows in the diagram above, or use the recommended reading paths for your role.

