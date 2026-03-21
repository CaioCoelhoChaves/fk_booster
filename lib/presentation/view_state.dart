import 'dart:async';
import 'package:fk_booster/injection/dependency_injection.dart';
import 'package:fk_booster/presentation/view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class ViewState<T extends StatefulWidget, V extends StatelessViewModel>
    extends State<T> {
  /// The view model of the view.
  late final V viewModel;

  /// The get it instance of the application.
  final GetIt _getIt = GetIt.instance;

  /// The text theme of the current theme.
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Method called when the view is created.
  @override
  void initState() {
    super.initState();
    injection?.registerDependencies(_getIt);
    initViewModel();
    viewModel.onViewInit();
  }

  /// Initialize the view model of the view by searching in the application
  /// injections.
  ///
  void initViewModel() => viewModel = _getIt.get<V>();

  @override
  Widget build(BuildContext context);

  /// Method called when the view is no longer in the route stack.
  @override
  Future<void> dispose() async {
    super.dispose();
    viewModel.onViewDispose();
    await injection?.disposeDependencies(_getIt);
  }

  /// The dependency injection instance for this view.
  /// if the class doesn't have a dependency injection instance
  /// you can just don't override this method in your view.
  DependencyInjection? get injection => null;
}
