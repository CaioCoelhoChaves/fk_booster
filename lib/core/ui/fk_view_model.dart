import 'package:fk_booster/core/ui/fk_view_state.dart';
import 'package:signals/signals.dart';

abstract class FkViewModel<State extends FkViewState> extends Signal<State> {
  FkViewModel(super.internalValue);

}
