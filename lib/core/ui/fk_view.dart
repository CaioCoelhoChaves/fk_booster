import 'package:fk_booster/core/ui/fk_view_model.dart';
import 'package:flutter/cupertino.dart';

abstract class FkView<ViewModel extends FkViewModel> extends StatelessWidget {
  const FkView({required this.viewModel, super.key});

  final ViewModel viewModel;

  @override
  Widget build(BuildContext context);
}
