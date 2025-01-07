import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

abstract class FkRestRepository<Entity extends FkEntity,
        EntityParser extends FkEntityParser<Entity>>
    extends FkRepository<Entity, EntityParser> {
  const FkRestRepository({
    required this.httpClient,
    required super.parser,
  });

  @protected
  final FkHttpClient httpClient;

  @protected
  String endpoint();
}
