import 'package:fk_booster/core/ui/fk_view_model.dart';
import 'package:signals/signals_flutter.dart';

/// [FkCommand] is used to run command inside a [FkViewModel], making easier
/// to handle different actions that has their own loading action.
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
class FkCommand {
  FkCommand(this._function);
  final Future<void> Function() _function;
  final _running = Signal(false);
  final _completed = Signal(false);
  final _error = Signal<Object?>(null);
  Signal<bool> get running => _running;
  Signal<bool> get completed => _completed;
  Signal<Object?> get exception => _error;

  Future<void> execute() async {
    try {
      _completed.value = false;
      _error.value = null;
      _running.value = true;
      await _function.call();
      _completed.value = true;
    } catch (e) {
      _error.value = e;
    } finally {
      _running.value = false;
    }
  }
}
