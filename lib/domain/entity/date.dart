class Date {
  const Date(this.year, [this.day = 1, this.month = 1]);
  Date.fromDateTime(DateTime dateTime)
    : year = dateTime.year,
      month = dateTime.month,
      day = dateTime.day;

  final int year;
  final int day;
  final int month;
}
