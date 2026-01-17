# fk_booster Entities Guide

## Overview
This guide explains what Entities are in the fk_booster architecture, how to create them, and the conventions to follow. Entities represent business domain objects and are a fundamental part of the clean architecture pattern.

## What is an Entity?

An **Entity** is a domain object that represents business logic data. It's typically used to store:
- Data returned from APIs
- Data from local databases
- Business domain objects that flow through the application

Entities are **framework-agnostic**, immutable, and belong to the **domain layer** of your feature.

## Base Entity Class

All entities extend the base `Entity` class from `fk_booster`:

```text
import 'package:fk_booster/domain/domain.dart';

class MyEntity extends Entity {
  const MyEntity({
    required this.field1,
    required this.field2,
  });
  
  final String? field1;
  final String? field2;
  
  @override
  List<Object?> get props => [field1, field2];
}
```

The base `Entity` class extends `Equatable`, which provides automatic equality comparison based on the `props` you define.

## Entity Conventions

### 1. Location
Entities should be placed in:
```
lib/app/features/<feature_name>/domain/entity/
```

Example:
```
lib/app/features/users/domain/entity/user_entity.dart
```

### 2. Naming
- File name: `<entity_name>_entity.dart` (snake_case)
- Class name: `<EntityName>Entity` (PascalCase)

Examples:
- `user_entity.dart` → `UserEntity`
- `product_entity.dart` → `ProductEntity`
- `order_item_entity.dart` → `OrderItemEntity`

### 3. Nullability Rules

**IMPORTANT:** Field nullability depends on API/data source behavior:

#### Fields should be nullable (`Type?`) when:
- The API/data source **may or may not** return the field
- The field is optional in the backend response
- You want to distinguish between "not provided" and "empty value"

#### Fields should be non-nullable (`Type`) when:
- The field **always** has a default value when null is returned
- Example: A boolean field that defaults to `false` when the API returns null
- The field is guaranteed to exist in the response

**Example:**
```text
class UserEntity extends Entity {
  const UserEntity({
    required this.id,           // nullable: API may not return
    required this.name,         // nullable: API may not return
    required this.isActive,     // non-nullable: defaults to false
    required this.role,         // nullable: optional field
  });

  final String? id;
  final String? name;
  final bool isActive;      // Will default to false if API returns null
  final String? role;

  @override
  List<Object?> get props => [id, name, isActive, role];
}
```

### 4. Constructors

Every entity should have:

#### a) Main constructor (required parameters)
```text
const UserEntity({
  required this.id,
  required this.name,
  required this.email,
});
```

#### b) Empty constructor (for initialization)
Useful for creating empty instances:
```text
const UserEntity.empty()
  : id = null,
    name = null,
    email = null;
```

### 5. Immutability
- All fields should be `final`
- Use `const` constructors when possible
- Never add methods that mutate state

### 6. Equatable Props
Always override the `props` getter to include all fields:
```text
@override
List<Object?> get props => [
  id,
  name,
  email,
  // ... all fields
];
```

This enables automatic equality comparison (two entities with same field values are equal).

### 7. CopyWith Method
Provide a `copyWith` method for creating modified copies:
```text
UserEntity copyWith({
  String? id,
  String? name,
  String? email,
}) {
  return UserEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}
```

## Complete Entity Example

```text
import 'package:fk_booster/domain/domain.dart';

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
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

> For serialization/deserialization and parser contracts, see `memory_bank/ENTITY_PARSERS.md`.

## Key Principles

1. **Domain Purity**: Entities belong to the domain layer and have no dependencies on Flutter, external packages (except Equatable), or data sources.

2. **Immutability**: Entities are immutable. Use `copyWith` to create modified versions.

3. **Value Semantics**: Entities with the same field values are considered equal (thanks to Equatable).

4. **Single Responsibility**: Entities only hold data. Business logic goes in use cases or repositories. Serialization logic goes in parsers (data layer).

5. **Separation**: 
   - **Entity** = domain layer (pure Dart)
   - **EntityParser** = data layer (handles I/O formats)

## Checklist for Creating a New Entity

- [ ] Create entity file in `domain/entity/` folder
- [ ] Extend `Entity` from `fk_booster/domain/domain.dart`
- [ ] Define all fields as `final`
- [ ] Use `const` constructor with `required` parameters
- [ ] Decide nullability based on API behavior
- [ ] Add `.empty()` named constructor
- [ ] Override `props` getter with all fields
- [ ] Implement `copyWith` method
- [ ] Create corresponding parser contract if needed; implementations belong to the data layer (see `ENTITY_PARSERS.md`)

## Common Patterns

### Entity with Lists
```text
class OrderEntity extends Entity {
  const OrderEntity({
    required this.id,
    required this.items,
  });

  final String? id;
  final List<OrderItemEntity>? items;

  @override
  List<Object?> get props => [id, items];
}
```

### Entity with Enums
```text
enum UserRole { admin, user, guest }

class UserEntity extends Entity {
  const UserEntity({
    required this.id,
    required this.role,
  });

  final String? id;
  final UserRole? role;

  @override
  List<Object?> get props => [id, role];
}
```

### Entity with Custom Types
```text
class ProductEntity extends Entity {
  const ProductEntity({
    required this.id,
    required this.price,
    required this.releaseDate,
  });

  final String? id;
  final Money? price;          // Custom value object
  final Date? releaseDate;     // fk_booster Date type

  @override
  List<Object?> get props => [id, price, releaseDate];
}
```

**Note on fk_booster Date type:**
```text
class Date {
  const Date(this.year, [this.day = 1, this.month = 1]);
  Date.fromDateTime(DateTime dateTime);
  
  final int year;
  final int day;
  final int month;
}
```
Use `Date` for dates without time (e.g., birthdays, release dates) and `DateTime` for timestamps with time.

## Summary

Entities are the foundation of your domain model. They are:
- Pure Dart classes
- Immutable and value-based
- Located in the domain layer
- Paired with EntityParsers in the data layer via contracts in domain (see `ENTITY_PARSERS.md`)
- Used throughout your application to represent business data

When in doubt, remember: **Entities describe WHAT the data is, not HOW it's stored or retrieved.**

