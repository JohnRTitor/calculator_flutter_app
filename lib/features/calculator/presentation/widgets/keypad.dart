import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/animated_equals_button.dart';

class Keypad extends ConsumerWidget {
  const Keypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final isSci = state.isScientificMode;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Memory Row
          if (state.isMemoryMode)
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, 'MC', ButtonType.action, () {
                    ref.read(calculatorProvider.notifier).memoryClear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory Cleared'), duration: Duration(milliseconds: 1000)));
                    return true;
                  }, tooltip: 'Memory Clear'),
                  _buildBtn(ref, 'MR', ButtonType.action, () {
                    if (!ref.read(calculatorProvider.notifier).memoryRecall()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory is empty'), duration: Duration(milliseconds: 1000)));
                      return false;
                    }
                    return true;
                  }, tooltip: 'Memory Recall'),
                  _buildBtn(ref, 'M+', ButtonType.action, () {
                    if (ref.read(calculatorProvider.notifier).memoryAdd()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Memory'), duration: Duration(milliseconds: 1000)));
                      return true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid input for memory'), duration: Duration(milliseconds: 1000)));
                      return false;
                    }
                  }, tooltip: 'Memory Add'),
                  _buildBtn(ref, 'M-', ButtonType.action, () {
                    if (ref.read(calculatorProvider.notifier).memorySubtract()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subtracted from Memory'), duration: Duration(milliseconds: 1000)));
                      return true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid input for memory'), duration: Duration(milliseconds: 1000)));
                      return false;
                    }
                  }, tooltip: 'Memory Subtract'),
                  _buildBtn(ref, 'MS', ButtonType.action, () {
                    if (ref.read(calculatorProvider.notifier).memoryStore()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stored in Memory'), duration: Duration(milliseconds: 1000)));
                      return true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid input for memory'), duration: Duration(milliseconds: 1000)));
                      return false;
                    }
                  }, tooltip: 'Memory Store'),
                ],
              ),
            ),
          
          if (isSci) ...[
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, state.isDegreeMode ? 'Deg' : 'Rad', ButtonType.scientific, () { ref.read(calculatorProvider.notifier).toggleDegreeMode(); return true; }),
                  _buildBtn(ref, 'Inv', ButtonType.scientific, () { ref.read(calculatorProvider.notifier).toggleInvMode(); return true; }, isActive: state.isInvMode),
                  _buildBtn(ref, 'hyp', ButtonType.scientific, () { ref.read(calculatorProvider.notifier).toggleHypMode(); return true; }, isActive: state.isHypMode),
                  _buildBtn(ref, 'Ans', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('Ans')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(
                    ref,
                    state.isInvMode ? (state.isHypMode ? 'asinh' : 'asin') : (state.isHypMode ? 'sinh' : 'sin'),
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append(state.isInvMode ? (state.isHypMode ? 'asinh(' : 'asin(') : (state.isHypMode ? 'sinh(' : 'sin(')),
                  ),
                  _buildBtn(
                    ref,
                    state.isInvMode ? (state.isHypMode ? 'acosh' : 'acos') : (state.isHypMode ? 'cosh' : 'cos'),
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append(state.isInvMode ? (state.isHypMode ? 'acosh(' : 'acos(') : (state.isHypMode ? 'cosh(' : 'cos(')),
                  ),
                  _buildBtn(
                    ref,
                    state.isInvMode ? (state.isHypMode ? 'atanh' : 'atan') : (state.isHypMode ? 'tanh' : 'tan'),
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append(state.isInvMode ? (state.isHypMode ? 'atanh(' : 'atan(') : (state.isHypMode ? 'tanh(' : 'tan(')),
                  ),
                  _buildBtn(ref, 'EXP', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('E')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, 'log', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('log(')),
                  _buildBtn(ref, 'ln', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('ln(')),
                  _buildBtn(ref, '√', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('sqrt('), tooltip: 'Square Root'),
                  _buildBtn(ref, '^', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('^'), tooltip: 'Power'),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildBtn(ref, 'π', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('π')),
                  _buildBtn(ref, 'e', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('e')),
                  _buildBtn(ref, '!', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('!'), tooltip: 'Factorial'),
                  _buildBtn(ref, '%', ButtonType.scientific, () => ref.read(calculatorProvider.notifier).append('%'), tooltip: 'Modulo'),
                ],
              ),
            )
          ],

          // Standard rows
          Expanded(
            flex: 1,
            child: Row(
              children: [
                _buildBtn(ref, 'AC', ButtonType.clear, () { ref.read(calculatorProvider.notifier).clear(); return true; }, tooltip: 'Clear Screen'),
                _buildBtn(ref, '(', ButtonType.action, () => ref.read(calculatorProvider.notifier).append('(')),
                _buildBtn(ref, ')', ButtonType.action, () => ref.read(calculatorProvider.notifier).append(')')),
                _buildBtn(ref, '÷', ButtonType.operator, () => ref.read(calculatorProvider.notifier).append('÷'), tooltip: 'Divide'),
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
                _buildIconBtn(ref, const Icon(Icons.backspace_outlined), ButtonType.action, () { ref.read(calculatorProvider.notifier).delete(); return true; }, tooltip: 'Backspace'),
                AnimatedEqualsButton(onEvaluate: () => ref.read(calculatorProvider.notifier).evaluate()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(WidgetRef ref, String text, ButtonType type, bool Function() onPressed, {String? tooltip, bool isActive = false}) {
    Widget btn = CalculatorButton(
      text: text,
      type: type,
      onPressed: onPressed,
      isActive: isActive,
    );
    if (tooltip != null) {
      btn = Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: btn,
      );
    }
    return Expanded(child: btn);
  }

  Widget _buildIconBtn(WidgetRef ref, Widget icon, ButtonType type, bool Function() onPressed, {String? tooltip}) {
    Widget btn = CalculatorButton(
      text: '',
      icon: icon,
      type: type,
      onPressed: onPressed,
    );
    if (tooltip != null) {
      btn = Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: btn,
      );
    }
    return Expanded(child: btn);
  }
}
