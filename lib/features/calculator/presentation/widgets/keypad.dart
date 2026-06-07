import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_state.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/animated_equals_button.dart';

class Keypad extends ConsumerWidget {
  const Keypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final isSci = state.isScientificMode;
    final expanded = state.expandedPanel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // === Dropdown chip row: [▾] [Trig ∨] [Log ∨] [Mem ∨] ===
          _DropdownChipRow(isSci: isSci, expanded: expanded, ref: ref),

          // === Expanded panel content (animated) ===
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _buildExpandedContent(ref, state, expanded),
          ),

          // === Scientific utility row: √ ^ ! π ===
          if (isSci)
            Expanded(
              flex: 60,
              child: Row(
                children: [
                  _btn(
                    ref,
                    '√',
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append('sqrt('),
                  ),
                  _btn(
                    ref,
                    '^',
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append('^'),
                  ),
                  _btn(
                    ref,
                    '!',
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append('!'),
                  ),
                  _btn(
                    ref,
                    'π',
                    ButtonType.scientific,
                    () => ref.read(calculatorProvider.notifier).append('π'),
                  ),
                ],
              ),
            ),

          // === ( ) % / ===
          Expanded(
            flex: 60,
            child: Row(
              children: [
                _btn(
                  ref,
                  '(',
                  ButtonType.action,
                  () => ref.read(calculatorProvider.notifier).append('('),
                ),
                _btn(
                  ref,
                  ')',
                  ButtonType.action,
                  () => ref.read(calculatorProvider.notifier).append(')'),
                ),
                _btn(
                  ref,
                  '%',
                  ButtonType.action,
                  () => ref.read(calculatorProvider.notifier).append('%'),
                ),
                _btn(
                  ref,
                  '/',
                  ButtonType.action,
                  () => ref.read(calculatorProvider.notifier).append('/'),
                  tooltip: 'Fraction',
                ),
              ],
            ),
          ),

          // === Number grid + operators ===
          // 7 8 9 ÷
          Expanded(
            flex: 72,
            child: Row(
              children: [
                _btn(
                  ref,
                  '7',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('7'),
                ),
                _btn(
                  ref,
                  '8',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('8'),
                ),
                _btn(
                  ref,
                  '9',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('9'),
                ),
                _btn(
                  ref,
                  '÷',
                  ButtonType.operator,
                  () => ref.read(calculatorProvider.notifier).append('÷'),
                ),
              ],
            ),
          ),
          // 4 5 6 ×
          Expanded(
            flex: 72,
            child: Row(
              children: [
                _btn(
                  ref,
                  '4',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('4'),
                ),
                _btn(
                  ref,
                  '5',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('5'),
                ),
                _btn(
                  ref,
                  '6',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('6'),
                ),
                _btn(
                  ref,
                  '×',
                  ButtonType.operator,
                  () => ref.read(calculatorProvider.notifier).append('×'),
                ),
              ],
            ),
          ),
          // 1 2 3 −
          Expanded(
            flex: 72,
            child: Row(
              children: [
                _btn(
                  ref,
                  '1',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('1'),
                ),
                _btn(
                  ref,
                  '2',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('2'),
                ),
                _btn(
                  ref,
                  '3',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('3'),
                ),
                _btn(
                  ref,
                  '−',
                  ButtonType.operator,
                  () => ref.read(calculatorProvider.notifier).append('−'),
                ),
              ],
            ),
          ),
          // 0 . mod +
          Expanded(
            flex: 72,
            child: Row(
              children: [
                _btn(
                  ref,
                  '0',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('0'),
                ),
                _btn(
                  ref,
                  '.',
                  ButtonType.number,
                  () => ref.read(calculatorProvider.notifier).append('.'),
                ),
                _btn(
                  ref,
                  'mod',
                  ButtonType.operator,
                  () => ref.read(calculatorProvider.notifier).append('%'),
                  tooltip: 'Modulo',
                ),
                _btn(
                  ref,
                  '+',
                  ButtonType.operator,
                  () => ref.read(calculatorProvider.notifier).append('+'),
                ),
              ],
            ),
          ),
          // AC ANS ⌫ =
          Expanded(
            flex: 72,
            child: Row(
              children: [
                _btn(ref, 'AC', ButtonType.clear, () {
                  ref.read(calculatorProvider.notifier).clear();
                  return true;
                }),
                _btn(
                  ref,
                  'ANS',
                  ButtonType.action,
                  () => ref.read(calculatorProvider.notifier).append('Ans'),
                  tooltip: 'Last Answer',
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '',
                    icon: const Icon(Icons.backspace_outlined, size: 20),
                    type: ButtonType.backspace,
                    onPressed: () {
                      ref.read(calculatorProvider.notifier).delete();
                      return true;
                    },
                  ),
                ),
                Expanded(
                  child: AnimatedEqualsButton(
                    onEvaluate: () =>
                        ref.read(calculatorProvider.notifier).evaluate(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    WidgetRef ref,
    CalculatorState state,
    ExpandedPanel expanded,
  ) {
    switch (expanded) {
      case ExpandedPanel.trig:
        return SizedBox(
          height: 44,
          child: Row(
            children: [
              _btn(
                ref,
                state.isDegreeMode ? 'Deg' : 'Rad',
                ButtonType.scientific,
                () {
                  ref.read(calculatorProvider.notifier).toggleDegreeMode();
                  return true;
                },
                isActive: state.isDegreeMode,
              ),
              _btn(
                ref,
                state.isInvMode
                    ? (state.isHypMode ? 'asinh' : 'asin')
                    : (state.isHypMode ? 'sinh' : 'sin'),
                ButtonType.scientific,
                () => ref
                    .read(calculatorProvider.notifier)
                    .append(
                      state.isInvMode
                          ? (state.isHypMode ? 'asinh(' : 'asin(')
                          : (state.isHypMode ? 'sinh(' : 'sin('),
                    ),
              ),
              _btn(
                ref,
                state.isInvMode
                    ? (state.isHypMode ? 'acosh' : 'acos')
                    : (state.isHypMode ? 'cosh' : 'cos'),
                ButtonType.scientific,
                () => ref
                    .read(calculatorProvider.notifier)
                    .append(
                      state.isInvMode
                          ? (state.isHypMode ? 'acosh(' : 'acos(')
                          : (state.isHypMode ? 'cosh(' : 'cos('),
                    ),
              ),
              _btn(
                ref,
                state.isInvMode
                    ? (state.isHypMode ? 'atanh' : 'atan')
                    : (state.isHypMode ? 'tanh' : 'tan'),
                ButtonType.scientific,
                () => ref
                    .read(calculatorProvider.notifier)
                    .append(
                      state.isInvMode
                          ? (state.isHypMode ? 'atanh(' : 'atan(')
                          : (state.isHypMode ? 'tanh(' : 'tan('),
                    ),
              ),
              _btn(ref, 'Inv', ButtonType.scientific, () {
                ref.read(calculatorProvider.notifier).toggleInvMode();
                return true;
              }, isActive: state.isInvMode),
            ],
          ),
        );
      case ExpandedPanel.log:
        return SizedBox(
          height: 44,
          child: Row(
            children: [
              _btn(
                ref,
                'log',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).append('log('),
              ),
              _btn(
                ref,
                'ln',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).append('ln('),
              ),
              _btn(
                ref,
                'log₂',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).append('log2('),
              ),
              _btn(
                ref,
                'e',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).append('e'),
              ),
            ],
          ),
        );
      case ExpandedPanel.memory:
        return SizedBox(
          height: 44,
          child: Row(
            children: [
              _btn(ref, 'MC', ButtonType.scientific, () {
                ref.read(calculatorProvider.notifier).memoryClear();
                return true;
              }),
              _btn(
                ref,
                'MR',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).memoryRecall(),
              ),
              _btn(
                ref,
                'M+',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).memoryAdd(),
              ),
              _btn(
                ref,
                'M−',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).memorySubtract(),
              ),
              _btn(
                ref,
                'MS',
                ButtonType.scientific,
                () => ref.read(calculatorProvider.notifier).memoryStore(),
              ),
            ],
          ),
        );
      case ExpandedPanel.none:
        return const SizedBox.shrink();
    }
  }

  Widget _btn(
    WidgetRef ref,
    String text,
    ButtonType type,
    bool Function() onPressed, {
    bool isActive = false,
    String? tooltip,
  }) {
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
}

/// Dropdown chip row: [▾] [Trig ∨] [Log ∨] [Mem ∨]
class _DropdownChipRow extends StatelessWidget {
  final bool isSci;
  final ExpandedPanel expanded;
  final WidgetRef ref;

  const _DropdownChipRow({
    required this.isSci,
    required this.expanded,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _buildChip(
              context,
              label: 'Sci',
              bgColor: isSci
                  ? colorScheme.secondaryContainer
                  : colorScheme.inverseSurface,
              fgColor: isSci
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onInverseSurface,
              onTap: () =>
                  ref.read(calculatorProvider.notifier).toggleScientificMode(),
              isExpanded: isSci,
            ),
            if (isSci) ...[
              const SizedBox(width: 6),
              Expanded(
                child: _buildChip(
                  context,
                  label: 'Trig',
                  bgColor: colorScheme.tertiaryContainer,
                  fgColor: colorScheme.onTertiaryContainer,
                  onTap: () => ref
                      .read(calculatorProvider.notifier)
                      .togglePanel(ExpandedPanel.trig),
                  isExpanded: expanded == ExpandedPanel.trig,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildChip(
                  context,
                  label: 'Log',
                  bgColor: colorScheme.secondaryContainer,
                  fgColor: colorScheme.onSecondaryContainer,
                  onTap: () => ref
                      .read(calculatorProvider.notifier)
                      .togglePanel(ExpandedPanel.log),
                  isExpanded: expanded == ExpandedPanel.log,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildChip(
                  context,
                  label: 'Mem',
                  bgColor: colorScheme.primaryContainer,
                  fgColor: colorScheme.onPrimaryContainer,
                  onTap: () => ref
                      .read(calculatorProvider.notifier)
                      .togglePanel(ExpandedPanel.memory),
                  isExpanded: expanded == ExpandedPanel.memory,
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
    required bool isExpanded,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
              const SizedBox(width: 2),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isExpanded ? 0.5 : 0.0,
                child: Icon(Icons.expand_more, size: 18, color: fgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
