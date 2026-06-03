import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/converter/providers/converter_provider.dart';
import 'package:calculator_flutter_app/features/converter/presentation/widgets/converter_keypad.dart';
import 'package:calculator_flutter_app/features/converter/presentation/widgets/unit_selector_bottom_sheet.dart';

class ConverterDetailScreen extends ConsumerWidget {
  const ConverterDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final category = state.category;

    if (category == null) return const Scaffold();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () => notifier.swapUnits(),
            tooltip: 'Swap units',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // From Unit row
                    _buildUnitRow(
                      context,
                      ref,
                      label: state.fromUnit?.name ?? 'Select unit',
                      value: state.inputValue.isEmpty ? '0' : state.inputValue,
                      symbol: state.fromUnit?.symbol ?? '',
                      isFrom: true,
                      colorScheme: colorScheme,
                    ),
                    const Divider(height: 32),
                    // To Unit row
                    _buildUnitRow(
                      context,
                      ref,
                      label: state.toUnit?.name ?? 'Select unit',
                      value: state.resultValue.isEmpty ? '0' : state.resultValue,
                      symbol: state.toUnit?.symbol ?? '',
                      isFrom: false,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),
            
            // Keypad
            const Expanded(
              flex: 70,
              child: ConverterKeypad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitRow(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String value,
    required String symbol,
    required bool isFrom,
    required ColorScheme colorScheme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            _showUnitSelector(context, ref, isFrom);
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isFrom ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: isFrom ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                        fontWeight: isFrom ? FontWeight.w500 : FontWeight.w400,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  symbol,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUnitSelector(BuildContext context, WidgetRef ref, bool isFrom) {
    final state = ref.read(converterProvider);
    final category = state.category;
    if (category == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: UnitSelectorBottomSheet(
            units: category.units,
            selectedUnit: isFrom ? state.fromUnit : state.toUnit,
            onSelect: (unit) {
              if (isFrom) {
                ref.read(converterProvider.notifier).setFromUnit(unit);
              } else {
                ref.read(converterProvider.notifier).setToUnit(unit);
              }
            },
          ),
        );
      },
    );
  }
}
