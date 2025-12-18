import 'package:example/app/features/users/domain/entity/user_entity.dart';
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
      appBar: AppBar(
        title: const Text('Users'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(RouteNames.createUser),
        child: const Icon(Icons.add),
      ),
      body: Watch(
        dependencies: [viewModel.getAll],
        (_) {
          final state = viewModel.getAll.value;

          if (state is Running) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${(state as Error).error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is Completed<List<UserEntity>>) {
            final users = state.data;

            if (users.isEmpty) {
              return const Center(
                child: Text('No users found'),
              );
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name ?? 'Unknown'),
                  subtitle: Text(user.email ?? 'No email'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteUser(user),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _deleteUser(UserEntity user) {
    // TODO(users): Implement delete functionality
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
