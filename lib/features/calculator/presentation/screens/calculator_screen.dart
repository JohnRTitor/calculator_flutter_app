import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/keypad.dart';
import 'package:calculator_flutter_app/shared/layouts/responsive_keypad_layout.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/screens/function_evaluator_screen.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/app/theme/app_theme_extension.dart';

/// The main screen for the calculator functionality.
///
/// Lays out the display panel at the top and the keypad filling the rest of the vertical space.
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFuncMode = ref.watch(calculatorProvider.select((state) => state.isFuncMode));
    final uiStyle = ref.watch(uiStyleProvider);
    final isGlass = uiStyle == UiStyle.liquidGlass;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: _buildSegmentedToggle(context, ref, isFuncMode, isGlass, uiStyle),
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

  Widget _buildSegmentedToggle(
      BuildContext context, WidgetRef ref, bool isFuncMode, bool isGlass, UiStyle uiStyle) {
    final theme = Theme.of(context);
    final glassPrimary = resolveGlassStyle(
      theme.colorScheme,
      brightness: theme.brightness,
      role: GlassSurfaceRole.primary,
      isSelected: true,
    );

    return SharedSurface(
      uiStyle: uiStyle,
      borderRadius: BorderRadius.circular(24),
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: SizedBox(
        width: 260,
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: _buildToggleChip(
                context: context,
                label: 'Calculator',
                isSelected: !isFuncMode,
                isGlass: isGlass,
                glassPrimary: glassPrimary,
                theme: theme,
                onTap: () {
                  if (isFuncMode) ref.read(calculatorProvider.notifier).toggleFuncMode();
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildToggleChip(
                context: context,
                label: 'Fn Evaluator',
                isSelected: isFuncMode,
                isGlass: isGlass,
                glassPrimary: glassPrimary,
                theme: theme,
                onTap: () {
                  if (!isFuncMode) ref.read(calculatorProvider.notifier).toggleFuncMode();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isGlass,
    required GlassStyle glassPrimary,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final themeExt = theme.extension<AppThemeExtension>()!;
    final bgColor = isSelected
        ? themeExt.chipBackground
        : Colors.transparent;
    final fgColor = isSelected
        ? themeExt.chipText
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: fgColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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
        children: [
          Expanded(child: Keypad()),
        ],
      ),
      keypadMinHeight: 450,
    );
  }
}
