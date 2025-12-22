import 'package:fk_booster/fk_booster.dart';
import 'package:flutter/material.dart';

/// Used to build a Widget that the content depends on a [ViewModelState] that
/// is updated by a [Command].
///
/// To use the component just pass the [command] that your Widget wants to
/// listen.
///
/// The builders are all optionals, if the current [ViewModelState] of your
/// listened [Command] does not match any of the passed builders your Widget
/// will show an empty [SizedBox].
///
/// The [builder] is built in all cases if the specific state builder is not
/// provided.
///
class CommandBuilder<T> extends StatelessWidget {
  const CommandBuilder({
    required this.command,
    this.builder,
    this.initialStateBuilder,
    this.loadingBuilder,
    this.completedBuilder,
    this.errorBuilder,
    super.key,
  });

  /// The command that will be observed to re-build after the state changes.
  final Command<T> command;

  /// The main builder used in "all cases" if the specific state builder is not
  /// provided.
  final Widget Function(ViewModelState<T> state)? builder;

  /// The builder used when the command state is [Initial]
  final Widget Function(Initial<T> state)? initialStateBuilder;

  /// The builder used when the command state is [Running]
  final Widget Function(Running<T> state)? loadingBuilder;

  /// The builder used when the command state is [Completed]
  final Widget Function(Completed<T> state)? completedBuilder;

  /// The builder used when the command state is [Error]
  final Widget Function(Error<T> state)? errorBuilder;

  @override
  Widget build(BuildContext context) => Watch(
    (_) {
      if (loadingBuilder != null && command.value is Running) {
        return loadingBuilder!(command.value as Running<T>);
      }

      if (errorBuilder != null && command.value is Error) {
        return errorBuilder!(command.value as Error<T>);
      }

      if (completedBuilder != null && command.value is Completed) {
        return completedBuilder!(command.value as Completed<T>);
      }

      if (initialStateBuilder != null && command.value is Initial) {
        return initialStateBuilder!(command.value as Initial<T>);
      }

      if (builder != null) return builder!(command.value);

      print(command.value);
      return const SizedBox.shrink();
    },
    dependencies: [command],
  );
}
