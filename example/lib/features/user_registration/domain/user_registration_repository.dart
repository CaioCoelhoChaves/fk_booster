import 'package:example/features/user/domain/user.dart';
import 'package:example/features/user_registration/data/user_registration_parser.dart';
import 'package:example/features/user_registration/domain/user_registration.dart';
import 'package:fk_booster/core/domain/repository/rest/fk_repository.dart';
import 'package:fk_booster/core/domain/repository/rest/mixins/save_mixin.dart';

abstract class UserRegistrationRepository
    extends FkRepository<UserRegistration, UserRegistrationParser>
    with Save<UserRegistration, UserRegistrationParser, User> {
  UserRegistrationRepository({required super.parser});
}