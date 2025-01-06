import 'package:fk_booster/core/ui/fk_view.dart';
import 'package:fk_booster/core/ui/fk_view_model.dart';
import 'package:fk_booster/dependency_injection/fk_injections.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

typedef FkRouterPageBuilder<ViewModel extends FkViewModel,
        Page extends FkView<ViewModel>>
    = Page Function(
  BuildContext context,
  GoRouterState routeState,
  ViewModel viewModel,
);

class FkRoute<ViewModel extends FkViewModel, Page extends FkView<ViewModel>>
    extends GoRoute {
  FkRoute({
    required FkInjection injection,
    required FkRouterPageBuilder<ViewModel, Page> pageBuilder,
    required super.path,
    ExitCallback? onExit,
    super.name,
    super.parentNavigatorKey,
    super.redirect,
    super.routes = const <RouteBase>[],
  }) : super(
          pageBuilder: (BuildContext context, GoRouterState state) {
            injection.call(GetIt.I);
            return CustomTransitionPage(
              child: pageBuilder(
                context,
                state,
                GetIt.I.get<ViewModel>(),
              ),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeIn).animate(animation),
                  child: child,
                );
              },
            );
          },
          onExit: (BuildContext context, GoRouterState state) async {
            if (!(await onExit?.call(context, state) ?? true)) return false;
            GetIt.I.get<ViewModel>();
            return true;
          },
        );
}
