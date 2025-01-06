import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

abstract class FkRepository<Entity extends FkEntity,
    EntityParser extends FkEntityParser<Entity>> {
  const FkRepository({
    required this.httpClient,
    required this.parser,
  });

  @protected
  final FkHttpClient httpClient;

  @protected
  final EntityParser parser;

  @protected
  String endpoint();
}
