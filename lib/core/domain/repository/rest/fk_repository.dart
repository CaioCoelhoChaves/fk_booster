import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

abstract class FkRepository<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>> {
  const FkRepository({required this.parser});

  @protected
  final EntityParser parser;
}
