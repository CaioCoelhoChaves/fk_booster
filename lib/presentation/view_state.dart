import 'package:fk_booster/injection/dependency_injection.dart';
import 'package:fk_booster/presentation/view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class ViewState<T extends StatefulWidget, V extends StatelessViewModel>
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
