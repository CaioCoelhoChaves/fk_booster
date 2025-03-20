import 'package:fk_booster/core/ui/fk_view_model.dart';
import 'package:signals/signals_flutter.dart';

abstract class FkCommand {
  FkCommand();
  final _running = Signal(false);
  final _completed = Signal(false);
  final _error = Signal<Object?>(null);
  Signal<bool> get running => _running;
  Signal<bool> get completed => _completed;
  Signal<Object?> get exception => _error;

  Future<void> _execute(Future<void> Function() function) async {
    try {
      _completed.value = false;
      _error.value = null;
      _running.value = true;
      await function();
      _completed.value = true;
    } catch (e) {
      _error.value = e;
    } finally {
      _running.value = false;
    }
  }
}

/// [FkCommand0] is the class used to run a command inside a [FkViewModel],
/// making easier to handle different actions that has their own loading action
/// and don't need any parameter when triggered.
///
/// The idea of this class follows the Command Pattern referenced in Flutter
/// documentation.
/// https://docs.flutter.dev/app-architecture/design-patterns/command
///
/// [_function] is the only attribute expected to be received in the
/// constructor, and it should be a async function that contains a running
/// state.
///
/// The class has 3 getters that returns data about the state of the [_function]
/// the getters are: [running], [completed] and [exception].
///
/// To execute the passed [_function] and change the getters state is only
/// necessary to call the [execute].
class FkCommand0 extends FkCommand {
  FkCommand0(this._function);
  final Future<void> Function() _function;

  Future<void> execute() async => _execute(() async => _function());
}

/// [FkCommand1] is the class used to run a command inside a [FkViewModel],
/// making easier to handle different actions that has their own loading action
/// and need to receive one parameter when triggered.
///
/// The idea of this class follows the Command Pattern referenced in Flutter
/// documentation.
/// https://docs.flutter.dev/app-architecture/design-patterns/command
///
/// [_function] is the only attribute expected to be received in the
/// constructor, and it should be a async function that contains a running
/// state.
///
/// The class has 3 getters that returns data about the state of the [_function]
/// the getters are: [running], [completed] and [exception].
///
/// To execute the passed [_function] and change the getters state is only
/// necessary to call the [execute].
class FkCommand1<Param> extends FkCommand {
  FkCommand1(this._function);
  final Future<void> Function(Param) _function;

  Future<void> execute(Param param) async {
    await _execute(() async => _function(param));
  }
}
