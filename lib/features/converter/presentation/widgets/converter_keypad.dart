import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/converter/presentation/providers/converter_provider.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';

class ConverterKeypad extends ConsumerWidget {
  const ConverterKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiStyle = ref.watch(uiStyleProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Build a 5x4 grid
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, 'C', uiStyle, isSpecial: true),
                  _buildButton(context, ref, '⌫', uiStyle, isSpecial: true),
                  // Additional buttons for other features later (e.g. swap)
                  const Expanded(child: SizedBox()),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '7', uiStyle),
                  _buildButton(context, ref, '8', uiStyle),
                  _buildButton(context, ref, '9', uiStyle),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '4', uiStyle),
                  _buildButton(context, ref, '5', uiStyle),
                  _buildButton(context, ref, '6', uiStyle),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '1', uiStyle),
                  _buildButton(context, ref, '2', uiStyle),
                  _buildButton(context, ref, '3', uiStyle),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '00', uiStyle),
                  _buildButton(context, ref, '0', uiStyle),
                  _buildButton(context, ref, '.', uiStyle),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    UiStyle uiStyle, {
    bool isSpecial = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final GlassSurfaceRole role;
    if (isSpecial) {
      role = label == '⌫'
          ? GlassSurfaceRole.destructive
          : GlassSurfaceRole.accent;
    } else {
      role = GlassSurfaceRole.button;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SharedSurface(
          uiStyle: uiStyle,
          isInteractive: true,
          glassRole: role,
          materialColor: isSpecial
              ? colorScheme.tertiaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24.0),
          onTap: () {
            final notifier = ref.read(converterProvider.notifier);
            if (label == 'C') {
              notifier.onClear();
            } else if (label == '⌫') {
              notifier.onDelete();
            } else if (label == '.') {
              notifier.onDot();
            } else {
              notifier.onDigit(label);
            }
          },
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: label == '⌫'
                    ? (uiStyle == UiStyle.liquidGlass
                          ? colorScheme.error
                          : colorScheme.onErrorContainer)
                    : isSpecial
                    ? (uiStyle == UiStyle.liquidGlass
                          ? colorScheme.tertiary
                          : colorScheme.onTertiaryContainer)
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
