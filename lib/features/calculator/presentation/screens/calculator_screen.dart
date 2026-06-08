import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/keypad.dart';

/// The main screen for the calculator functionality.
///
/// Lays out the display panel at the top and the keypad filling the rest of the vertical space.
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen is very short (e.g., landscape on a small phone),
        // we make the layout scrollable to prevent the keypad from compressing
        // too much or overflowing.
        if (constraints.maxHeight < 650) {
          return const SingleChildScrollView(
            child: Column(
              children: [
                DisplayPanel(),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: SizedBox(
                    height: 450, // Fixed minimum height for the keypad
                    child: Keypad(),
                  ),
                ),
              ],
            ),
          );
        }

        // On normal/tall screens, use Expanded to fill available space dynamically
        // and SafeArea to keep the bottom row above the system navigation bar.
        return const Column(
          children: [
            DisplayPanel(),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Keypad(),
              ),
            ),
          ],
        );
      },
    );
  }
}
