import 'package:signals/signals.dart';

abstract interface class ViewModel {
  void onViewInit();
  void onViewDispose();
}

abstract class StatelessViewModel implements ViewModel {
  const StatelessViewModel();

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}
}

abstract class StatefulViewModel<State> extends Signal<State>
    implements StatelessViewModel {
  StatefulViewModel(super.internalValue);

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}
}

class NoneViewModel extends StatelessViewModel {}
