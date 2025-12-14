import 'package:fk_booster/domain/entity/date.dart';

extension DateParsers on Date? {
  String? toApi() =>
      this != null ? '${this!.year}-${this!.month}-${this!.day}' : null;
}

extension DateTimeParsers on DateTime? {
  String? toApi() => this?.toIso8601String();
}
