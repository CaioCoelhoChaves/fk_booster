import 'package:example/app/pages/users/users_injection.dart';
import 'package:example/app/pages/users/users_view_model.dart';
import 'package:example/app/router/route_names.dart';
import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ViewState<UsersPage, UsersViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(RouteNames.createUser),
        child: const Icon(Icons.create),
      ),
    );
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
