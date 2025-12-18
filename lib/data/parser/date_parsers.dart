import 'package:fk_booster/domain/entity/date.dart';

extension DateParsers on Date? {
  String? toApi() {
    if (this == null) return null;
    final month = this!.month.toString().padLeft(2, '0');
    final day = this!.day.toString().padLeft(2, '0');
    return '${this!.year}-$month-$day';
  }
}

extension DateTimeParsers on DateTime? {
  String? toApi() => this?.toIso8601String();
}
