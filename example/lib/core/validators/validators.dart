class Validators {
  Validators._();

  static String? required(String? text) {
    if(text == null || text.isEmpty) return 'The field is required';
    return null;
  }
}
