import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/keypad.dart';
import 'package:calculator_flutter_app/shared/layouts/responsive_keypad_layout.dart';

import 'package:calculator_flutter_app/features/calculator/presentation/screens/function_evaluator_screen.dart';
import 'package:calculator_flutter_app/features/history/presentation/screens/history_screen.dart';
import 'package:calculator_flutter_app/app/navigation/route_transitions.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/shared/widgets/pill_switcher.dart';

/// The main screen for the calculator functionality.
///
/// Lays out the display panel at the top and the keypad filling the rest of the vertical space.
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  bool isFuncMode = false;

  @override
  Widget build(BuildContext context) {
    final uiStyle = ref.watch(uiStyleProvider);
    final isGlass = uiStyle == UiStyle.liquidGlass;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ).copyWith(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHistoryButton(context, isGlass, uiStyle),
              const SizedBox(width: 8),
              _buildSegmentedToggle(uiStyle),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isFuncMode
                ? const FunctionEvaluatorScreen()
                : const _ScientificLayout(),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(UiStyle uiStyle) {
    return PillSwitcher(
      uiStyle: uiStyle,
      label1: 'Calculator',
      label2: 'Fn Evaluator',
      isFirstSelected: !isFuncMode,
      onChanged: (isFirst) {
        setState(() {
          isFuncMode = !isFirst;
        });
      },
    );
  }

  Widget _buildHistoryButton(
    BuildContext context,
    bool isGlass,
    UiStyle uiStyle,
  ) {
    final theme = Theme.of(context);
    final glassCard = resolveGlassStyle(
      theme.colorScheme,
      brightness: theme.brightness,
      role: GlassSurfaceRole.card,
    );

    return isGlass
        ? SharedSurface(
            uiStyle: uiStyle,
            glassRole: GlassSurfaceRole.button,
            frosted: true,
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.history, size: 20),
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    FadePageRoute(
                      page: HistoryScreen(initialIsFuncMode: isFuncMode),
                    ),
                  );
                  if (result != null && result != isFuncMode) {
                    setState(() {
                      isFuncMode = result;
                    });
                  }
                },
                tooltip: 'History',
                color: glassCard.foregroundColor,
              ),
            ),
          )
        : SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.history, size: 20),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  FadePageRoute(
                    page: HistoryScreen(initialIsFuncMode: isFuncMode),
                  ),
                );
                if (result != null && result != isFuncMode) {
                  setState(() {
                    isFuncMode = result;
                  });
                }
              },
              tooltip: 'History',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
  }
}

class _ScientificLayout extends StatelessWidget {
  const _ScientificLayout();

  @override
  Widget build(BuildContext context) {
    return const ResponsiveKeypadLayout(
      displayArea: DisplayPanel(),
      keypad: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Expanded(child: Keypad())],
      ),
      keypadMinHeight: 450,
    );
  }
}
