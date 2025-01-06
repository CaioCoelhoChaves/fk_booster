class FkHttpException implements Exception {
  const FkHttpException({required this.error, required this.message});

  final Object? error;
  final String? message;
}
