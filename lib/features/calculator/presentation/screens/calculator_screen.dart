import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/keypad.dart';
import 'package:calculator_flutter_app/shared/layouts/responsive_keypad_layout.dart';

/// The main screen for the calculator functionality.
///
/// Lays out the display panel at the top and the keypad filling the rest of the vertical space.
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveKeypadLayout(
      displayArea: DisplayPanel(),
      keypad: Keypad(),
      keypadMinHeight: 450,
    );
  }
}
