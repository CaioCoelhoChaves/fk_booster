import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

abstract class DependencyInjection {
  const DependencyInjection(this.scopeName);
  final String scopeName;

  void registerDependencies(GetIt i) {
    i.pushNewScope(scopeName: scopeName);
    debugPrint('New scope pushed: $scopeName ================================');
  }

  Future<void> disposeDependencies(GetIt i) async {
    await i.dropScope(scopeName);
    debugPrint('Scope dropped: $scopeName ===================================');
  }
}
