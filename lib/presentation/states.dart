part of 'command.dart';

abstract class State<T> {
  const State();

  Initial<T> toInitial() => Initial._();

  Running<T> toRunning() => Running._();

  Completed<T> toLoaded({required T data}) => Completed._(data: data);

  Error<T> toError({required Object error}) => Error(error: error);
}

class Initial<T> extends State<T> {
  const Initial._();
}

class Running<T> extends State<T> {
  const Running._();
}

class Completed<T> extends State<T> {
  const Completed._({required this.data});
  final T data;
}

class Error<T> extends State<T> {
  const Error({required this.error});
  final Object error;
}
