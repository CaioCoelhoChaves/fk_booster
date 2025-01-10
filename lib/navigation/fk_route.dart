import 'dart:developer';

import 'package:fk_booster/core/domain/entity/fk_empty.dart';
import 'package:fk_booster/core/domain/entity/fk_entity.dart';
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

class FkRoute<ViewModel extends FkViewModel, Page extends FkView<ViewModel>,
    Extra extends FkEntity> extends GoRoute {
  FkRoute({
    required FkInjection<Extra> injection,
    required FkRouterPageBuilder<ViewModel, Page> pageBuilder,
    required super.path,
    ExitCallback? onExit,
    super.name,
    super.parentNavigatorKey,
    super.redirect,
    super.routes = const <RouteBase>[],
  }) : super(
          pageBuilder: (BuildContext context, GoRouterState state) {
            if (!_inMemoryInjections.contains(injection.scopeName)) {
              _initRouteInjections<Extra>(state, injection);
            }
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
            _dropRouteInjections(injection.scopeName);
            return true;
          },
        );

  static void _initRouteInjections<Extra extends FkEntity>(
    GoRouterState state,
    FkInjection<Extra> injection,
  ) {
    GetIt.I.pushNewScope(
      init: (I) {
        if (Extra != FkEmpty) {
          if (state.extra.runtimeType != Extra) {
            throw Exception(
              "Type: ${Extra.runtimeType} defined as 'extra' in FkRoute is "
              'not the same received as extra from the top route '
              '${state.topRoute}',
            );
          }
          I.registerSingleton<Extra>(
            state.extra! as Extra,
            instanceName: injection.scopeName,
          );
        }
        injection.call(I);
        _inMemoryInjections.add(injection.scopeName);
        log(
          '${injection.scopeName} scope pushed - '
          'in memory injections: $_inMemoryInjections',
        );
      },
      scopeName: injection.scopeName,
    );
  }

  static void _dropRouteInjections(String scopeName) {
    GetIt.I.dropScope(scopeName);
    _inMemoryInjections.remove(scopeName);
    log(
      '$scopeName scope dropped - '
      'in memory injections: $_inMemoryInjections',
    );
  }

  static final Set<String> _inMemoryInjections = {};
}
