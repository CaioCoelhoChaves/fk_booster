import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

abstract class FkInjection<T extends FkEntity> {
  const FkInjection(this.scopeName);
  final String scopeName;
  void call(GetIt i);

  @protected
  T extra() => GetIt.I.get(instanceName: scopeName);
}
