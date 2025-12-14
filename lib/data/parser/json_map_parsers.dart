import 'package:fk_booster/data/data.dart';
import 'package:fk_booster/domain/entity/date.dart';

extension JsonMapParsers on JsonMap {
  String? getString(String key) {
    final value = this[key];
    return value as String?;
  }

  Date? getDate(String key) {
    final value = getString(key);
    if (value == null) return null;
    final dateTimeValue = DateTime.parse(value);
    return Date(dateTimeValue.year, dateTimeValue.month, dateTimeValue.day);
  }

  DateTime? getDateTime(String key) {
    final value = getString(key);
    if (value == null) return null;
    return DateTime.parse(value);
  }
}

extension JsonMapBuilder on JsonMap {
  void add(String key, String? value, {bool forceNull = false}) {
    if (value != null || forceNull) this[key] = value;
  }
}
