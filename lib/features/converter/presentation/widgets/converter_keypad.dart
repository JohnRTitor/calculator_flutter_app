import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/converter/providers/converter_provider.dart';

class ConverterKeypad extends ConsumerWidget {
  const ConverterKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Build a 5x4 grid
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, 'C', isSpecial: true),
                  _buildButton(context, ref, '⌫', isSpecial: true),
                  // Additional buttons for other features later (e.g. swap)
                  const Expanded(child: SizedBox()),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '7'),
                  _buildButton(context, ref, '8'),
                  _buildButton(context, ref, '9'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '4'),
                  _buildButton(context, ref, '5'),
                  _buildButton(context, ref, '6'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '1'),
                  _buildButton(context, ref, '2'),
                  _buildButton(context, ref, '3'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildButton(context, ref, '00'),
                  _buildButton(context, ref, '0'),
                  _buildButton(context, ref, '.'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, String label, {bool isSpecial = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isSpecial ? colorScheme.tertiaryContainer : colorScheme.surfaceContainerHighest,
            foregroundColor: isSpecial ? colorScheme.onTertiaryContainer : colorScheme.onSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          ),
          onPressed: () {
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
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
