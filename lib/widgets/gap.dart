import 'package:flutter/material.dart';

/// The Gap basically implements a usual [SizedBox] but with less verbose.
/// [x] meaning the [Gap] will represents the horizontal axis, and [y] the
/// vertical.
class Gap extends StatelessWidget {
  /// This is the default constructor and works exactly like [SizedBox], but,
  /// changing the word height to [y] and width to [x].
  const Gap({
    this.y = 0,
    this.x = 0,
    super.key,
  });

  /// This constructor will receive only the value of the horizontal axis [Gap]
  const Gap.x(this.x, {super.key}) : y = 0;

  /// This constructor will receive only the value of the vertical axis [Gap]
  const Gap.y(this.y, {super.key}) : x = 0;

  final double y;
  final double x;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: y, width: x);
  }
}
