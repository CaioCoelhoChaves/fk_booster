import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

abstract class FkRestApiRepository<Entity extends FkEntity,
        EntityParser extends FkEntityParser<Entity>>
    extends FkRepository<Entity, EntityParser> {
  const FkRestApiRepository({
    required this.httpClient,
    required super.parser,
  });

  @protected
  final FkHttpClient httpClient;

  @protected
  String endpoint();
}
