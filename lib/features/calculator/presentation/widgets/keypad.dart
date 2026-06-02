import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/calculator_button.dart';

class Keypad extends ConsumerWidget {
  const Keypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final isSci = state.isScientificMode;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Memory Row
            if (state.hasMemory || isSci)
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildBtn(ref, 'MC', ButtonType.action, () => ref.read(calculatorProvider.notifier).memoryClear()),
                    _buildBtn(ref, 'MR', ButtonType.action, () => ref.read(calculatorProvider.notifier).memoryRecall()),
                    _buildBtn(ref, 'M+', ButtonType.action, () => ref.read(calculatorProvider.notifier).memoryAdd()),
                    _buildBtn(ref, 'M-', ButtonType.action, () => ref.read(calculatorProvider.notifier).memorySubtract()),
                    _buildBtn(ref, 'MS', ButtonType.action, () => ref.read(calculatorProvider.notifier).memoryStore()),
                  ],
                ),
              ),
            
            if (isSci) ...[
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildBtn(ref, 'sin', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('sin(')),
                    _buildBtn(ref, 'cos', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('cos(')),
                    _buildBtn(ref, 'tan', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('tan(')),
                    _buildBtn(ref, 'π', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('π')),
                    _buildBtn(ref, 'e', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('e')),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildBtn(ref, 'log', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('log(')),
                    _buildBtn(ref, 'ln', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('ln(')),
                    _buildBtn(ref, '√', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('sqrt(')),
                    _buildBtn(ref, '^', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('^')),
                    _buildBtn(ref, '!', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('!')),
                  ],
                ),
              )
            ],

            // Standard rows
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, 'AC', ButtonType.clear, () => ref.read(calculatorProvider.notifier).clear()),
                  _buildBtn(ref, '(', ButtonType.action, () => ref.read(calculatorProvider.notifier).append('(')),
                  _buildBtn(ref, ')', ButtonType.action, () => ref.read(calculatorProvider.notifier).append(')')),
                  _buildBtn(ref, '÷', ButtonType.operator, () => ref.read(calculatorProvider.notifier).append('÷')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, '7', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('7')),
                  _buildBtn(ref, '8', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('8')),
                  _buildBtn(ref, '9', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('9')),
                  _buildBtn(ref, '×', ButtonType.operator, () => ref.read(calculatorProvider.notifier).append('×')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, '4', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('4')),
                  _buildBtn(ref, '5', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('5')),
                  _buildBtn(ref, '6', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('6')),
                  _buildBtn(ref, '−', ButtonType.operator, () => ref.read(calculatorProvider.notifier).append('−')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, '1', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('1')),
                  _buildBtn(ref, '2', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('2')),
                  _buildBtn(ref, '3', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('3')),
                  _buildBtn(ref, '+', ButtonType.operator, () => ref.read(calculatorProvider.notifier).append('+')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, '0', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('0')),
                  _buildBtn(ref, '.', ButtonType.number, () => ref.read(calculatorProvider.notifier).append('.')),
                  _buildIconBtn(ref, const Icon(Icons.backspace_outlined), ButtonType.action, () => ref.read(calculatorProvider.notifier).delete()),
                  _buildBtn(ref, '=', ButtonType.equals, () => ref.read(calculatorProvider.notifier).evaluate()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(WidgetRef ref, String text, ButtonType type, VoidCallback onPressed) {
    return Expanded(
      child: CalculatorButton(
        text: text,
        type: type,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildIconBtn(WidgetRef ref, Widget icon, ButtonType type, VoidCallback onPressed) {
    return Expanded(
      child: CalculatorButton(
        text: '',
        icon: icon,
        type: type,
        onPressed: onPressed,
      ),
    );
  }
}
