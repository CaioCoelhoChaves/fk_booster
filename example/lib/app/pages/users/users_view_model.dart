import 'dart:async';
import 'package:example/app/features/users/domain/entity/user_entity.dart';
import 'package:example/app/features/users/domain/repository/user_repository.dart';
import 'package:fk_booster/fk_booster.dart';

class UsersViewModel extends StatelessViewModel {
  UsersViewModel({required this.userRepository});

  final UserRepository userRepository;

  late final getAll = Command0<List<UserEntity>>(
    userRepository.getAll,
  );

  @override
  void onViewInit() {
    unawaited(getAll.execute());
  }
}
