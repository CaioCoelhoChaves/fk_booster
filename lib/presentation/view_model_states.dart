part of 'command.dart';

abstract class ViewModelState<T> {
  const ViewModelState();

  Initial<T> toInitial() => Initial._();

  Running<T> toRunning() => Running._();

  Completed<T> toLoaded({required T data}) => Completed._(data: data);

  Error<T> toError({required Object error}) => Error(error: error);
}

class Initial<T> extends ViewModelState<T> {
  const Initial._();
}

class Running<T> extends ViewModelState<T> {
  const Running._();
}

class Completed<T> extends ViewModelState<T> {
  const Completed._({required this.data});
  final T data;
}

class Error<T> extends ViewModelState<T> {
  const Error({required this.error});
  final Object error;
}
