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
  bool hasError = true;

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
      body: CommandBuilder(
        command: viewModel.getAll,
        loadingBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        completedBuilder: (state) => Visibility(
          visible: state.data.isNotEmpty,
          replacement: const Center(
            child: Text('No users found'),
          ),
          child: ListView.builder(
            itemCount: state.data.length,
            itemBuilder: (context, index) {
              final user = state.data[index];
              return ListTile(
                title: Text(user.name ?? 'Unknown'),
                subtitle: Text(user.email ?? 'No email'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteUser(user),
                ),
              );
            },
          ),
        ),
        errorBuilder: (state) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${state.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: viewModel.getAll.execute,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteUser(UserEntity user) {
    // TODO(users): Implement delete functionality
  }

  @override
  DependencyInjection? get injection => UsersInjection();
}
