import 'dart:async';

import 'package:fk_booster/injection/dependency_injection.dart';
import 'package:fk_booster/presentation/view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// This is the class that substitutes the [State] of a [StatefulWidget] in a
/// to able the application to work with the architecture defined by the
/// package.
///
/// The [ViewModel] type defined in the second class parameter it is the one
/// that is going to be automatically get by the [ViewState], so, if you are
/// using it remember to register it correctly.
///
/// Add your page injections in the [injection] method by overriding it.
abstract class ViewState<T extends StatefulWidget, V extends ViewModel>
    extends State<T> {
  late final V viewModel;
  final GetIt _getIt = GetIt.instance;
  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    injection?.registerDependencies(_getIt);
    initViewModel();
    viewModel.onViewInit();
  }

  void initViewModel() => viewModel = _getIt.get<V>();

  @override
  Widget build(BuildContext context);

  @override
  Future<void> dispose() async {
    super.dispose();
    viewModel.onViewDispose();
    await injection?.disposeDependencies(_getIt);
  }

  DependencyInjection? get injection => null;
}
