import 'package:fk_booster/presentation/command.dart';
import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';

/// The interface for a view model.
///
abstract interface class ViewModel {
  /// Method called when the view is created.
  ///
  void onViewInit();

  /// Method called when the view is no longer in the route stack.
  ///
  void onViewDispose();
}

/// A abstract view model to be extended in a page view model that doesn't needs
/// any state embedded in it.
///
/// But still can have state management like [Command], [Signal],
/// [ValueNotifier] etc.
///
abstract class StatelessViewModel implements ViewModel {
  const StatelessViewModel();

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}
}

/// A abstract view model to be extended in a page view model that needs a state
/// embedded to store a single reactive object.
///
/// The initial state of this object is expected to be received in the first
/// positional parameter of the contructor.
///
/// Still can be used to have another state management like [Command],
/// [Signal], [ValueNotifier] etc.
///
abstract class StatefulViewModel<State> extends Signal<State>
    implements StatelessViewModel {
  StatefulViewModel(super.internalValue);

  @override
  void onViewDispose() {}

  @override
  void onViewInit() {}
}

/// An actual implementation of a StatelessViewModel to be used when building a
/// page that don't need a view model. This class purpouse is to avoid the need
/// of creating a new class just to satisfy the [ViewModel] interface.
///
class NoneViewModel extends StatelessViewModel {}
