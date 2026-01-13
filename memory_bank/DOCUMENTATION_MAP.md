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
      ┌──────┴──────┬──────────┬──────────┬──────────┐
      │             │          │          │          │
      ▼             ▼          ▼          ▼          ▼
┌──────────┐  ┌──────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│DEPENDENCY│  │VIEWSTATE │ │ENTITIES│ │PARSERS │ │REPOSIT-│
│INJECTION │  │   .md    │ │  .md   │ │  .md   │ │ORIES.md│
│   .md    │  │          │ │        │ │        │ │        │
└────┬─────┘  └────┬─────┘ └────────┘ └────────┘ └────────┘
     │             │
     └──────┬──────┘
            │
    (Work together for 
     page architecture)
```

---

## Documentation Hierarchy

### 1. Entry Point
**`AI_INSTRUCTIONS.md`** - Start here
- Tells AI agents which files to read
- Defines behavioral rules
- Sets scope of application

### 2. Architectural Overview
**`PROJECT_STRUCTURE.md`** - High-level structure
- App root structure (`lib/app/`)
- Features structure (domain/data layers)
- Pages structure (UI layer)
- Dependency direction rules
- Naming conventions

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
  - **Cross-references**: DEPENDENCY_INJECTION.md

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

### 4. Quick Start
**`SCAFFOLD_TEMPLATES.md`** - Copy-paste templates
- New feature scaffold
- New page scaffold
- Complete working examples
- **Cross-references**: All other docs

---

## When to Use Each File

### Creating a New Page
1. **Read first**: `VIEWSTATE.md` + `DEPENDENCY_INJECTION.md`
2. **Then use**: `SCAFFOLD_TEMPLATES.md` (Page section)
3. **Reference**: `PROJECT_STRUCTURE.md` (for folder placement)

**Why this order**: You need to understand ViewState and DI before creating pages, as they work together.

### Creating a New Feature
1. **Read first**: `ENTITIES.md` → `ENTITY_PARSERS.md` → `REPOSITORIES.md`
2. **Then use**: `SCAFFOLD_TEMPLATES.md` (Feature section)
3. **Reference**: `PROJECT_STRUCTURE.md` (for folder structure)

**Why this order**: Features follow a bottom-up approach (Entities → Parsers → Repositories).

### Understanding the Full Architecture
1. `AI_INSTRUCTIONS.md` (overview)
2. `PROJECT_STRUCTURE.md` (structure)
3. `DEPENDENCY_INJECTION.md` (DI system)
4. `VIEWSTATE.md` (UI integration)
5. `ENTITIES.md` → `ENTITY_PARSERS.md` → `REPOSITORIES.md` (business logic)

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
- SCAFFOLD_TEMPLATES.md (Page templates)

### ENTITIES.md
**Depends on**: Nothing (pure domain)
**Referenced by**:
- ENTITY_PARSERS.md (parses to/from entities)
- REPOSITORIES.md (returns entities)
- SCAFFOLD_TEMPLATES.md (entity templates)

### ENTITY_PARSERS.md
**Depends on**:
- ENTITIES.md (parses entities)
**Referenced by**:
- REPOSITORIES.md (repositories use parsers)
- SCAFFOLD_TEMPLATES.md (parser templates)

### REPOSITORIES.md
**Depends on**:
- ENTITIES.md (returns entities)
- ENTITY_PARSERS.md (uses parsers)
- DEPENDENCY_INJECTION.md (registered in DI)
**Referenced by**:
- SCAFFOLD_TEMPLATES.md (repository templates)

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
SCAFFOLD_TEMPLATES.md (Feature section)
```

### Path 3: Full-Stack Developer (Complete Flow)
```
AI_INSTRUCTIONS.md
    ↓
PROJECT_STRUCTURE.md
    ↓
┌─────────────────┬─────────────────┐
│                 │                 │
│  UI Flow        │  Business Flow  │
│                 │                 │
│  DI → ViewState │  Entities →     │
│                 │  Parsers →      │
│                 │  Repositories   │
└─────────────────┴─────────────────┘
    ↓
SCAFFOLD_TEMPLATES.md
```

---

## Cross-Reference Summary

| File | References | Referenced By |
|------|-----------|---------------|
| AI_INSTRUCTIONS.md | All files | None |
| PROJECT_STRUCTURE.md | None | All files |
| DEPENDENCY_INJECTION.md | None | VIEWSTATE, REPOSITORIES, SCAFFOLD_TEMPLATES |
| VIEWSTATE.md | DEPENDENCY_INJECTION | SCAFFOLD_TEMPLATES |
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

### DI + ViewState (Pages)
These two systems work together for page architecture:
- **DI**: Manages dependency lifecycle (create/dispose)
- **ViewState**: Integrates DI with Flutter widget lifecycle
- **Result**: Automatic dependency management per page

**Read together**: `DEPENDENCY_INJECTION.md` + `VIEWSTATE.md`

### Entities + Parsers + Repositories (Features)
These three layers work together for business logic:
- **Entities**: Define business objects (domain)
- **Parsers**: Convert between formats (data)
- **Repositories**: Coordinate data access (data → domain interface)
- **Result**: Clean architecture with testable layers

**Read in sequence**: `ENTITIES.md` → `ENTITY_PARSERS.md` → `REPOSITORIES.md`

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

