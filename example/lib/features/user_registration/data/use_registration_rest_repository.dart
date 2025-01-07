import 'package:example/features/user/data/user_parser.dart';
import 'package:example/features/user/domain/user.dart';
import 'package:example/features/user_registration/data/user_registration_parser.dart';
import 'package:example/features/user_registration/domain/user_registration.dart';
import 'package:example/features/user_registration/domain/user_registration_repository.dart';
import 'package:fk_booster/core/data/repository/rest/fk_rest_repository.dart';
import 'package:fk_booster/core/data/repository/rest/mixin/save_rest_mixin.dart';
import 'package:fk_booster/core/data/typedefs.dart';
import 'package:flutter/foundation.dart';

class UserRegistrationRestRepository
    extends FkRestRepository<UserRegistration, UserRegistrationParser>
    with SaveRest<UserRegistration, UserRegistrationParser, User>
    implements UserRegistrationRepository {
  UserRegistrationRestRepository({
    required super.httpClient,
    required super.parser,
    required this.userParser,
  });

  final UserParser userParser;

  @protected
  @override
  String endpoint() => '/signup';

  @protected
  @override
  User Function(FkJsonMap) saveFromMap() => userParser.fromMap;

  @protected
  @override
  FkJsonMap Function(UserRegistration) saveToMap() => parser.toMap;
}
