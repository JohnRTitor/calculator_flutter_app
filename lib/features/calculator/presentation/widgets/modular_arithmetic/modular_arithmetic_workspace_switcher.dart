import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/pill_switcher.dart';

class ModularArithmeticWorkspaceSwitcher extends StatelessWidget {
  final UiStyle uiStyle;
  final bool isEvaluatorSelected;
  final ValueChanged<bool> onEvaluatorSelected;

  const ModularArithmeticWorkspaceSwitcher({
    super.key,
    required this.uiStyle,
    required this.isEvaluatorSelected,
    required this.onEvaluatorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: PillSwitcher(
          uiStyle: uiStyle,
          label1: 'Evaluator',
          label2: 'Structure Explorer',
          isFirstSelected: isEvaluatorSelected,
          onChanged: onEvaluatorSelected,
        ),
      ),
    );
  }
}
