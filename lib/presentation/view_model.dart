import 'package:flutter/foundation.dart';
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

class StatefulViewModel<State> extends Signal<State>
    implements StatelessViewModel {
  StatefulViewModel(super.internalValue);

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}

  @override
  void afterCreate(State val) {
    super.afterCreate(val);
    initializeSubscriptions();
  }

  @protected
  void initializeSubscriptions() {}
}

class NoneViewModel extends StatelessViewModel {}
