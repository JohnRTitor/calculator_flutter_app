import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/converter/presentation/providers/converter_provider.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/features/converter/presentation/widgets/converter_keypad.dart';
import 'package:calculator_flutter_app/features/converter/presentation/widgets/unit_selector_bottom_sheet.dart';

/// The detail screen for a specific converter category.
///
/// Displays the active "from" and "to" units, the calculated result, and provides
/// the keypad for numeric input. Also allows users to swap units or select new ones.
class ConverterDetailScreen extends ConsumerWidget {
  const ConverterDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final category = state.category;

    if (category == null) return const Scaffold();

    final uiStyle = ref.watch(uiStyleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    Widget body = SafeArea(
      child: Column(
        children: [
          // Display Area
          Expanded(
            flex: 35,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    uiStyle: uiStyle,
                  ),
                  const SizedBox(height: 16),
                  // To Unit row
                  _buildUnitRow(
                    context,
                    ref,
                    label: state.toUnit?.name ?? 'Select unit',
                    value: state.resultValue.isEmpty ? '0' : state.resultValue,
                    symbol: state.toUnit?.symbol ?? '',
                    isFrom: false,
                    colorScheme: colorScheme,
                    uiStyle: uiStyle,
                  ),
                ],
              ),
            ),
          ),

          // Keypad
          const Expanded(flex: 65, child: ConverterKeypad()),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          if (category.id == 'currency')
            IconButton(
              icon: state.isLoadingRates
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: state.isLoadingRates
                  ? null
                  : () => notifier.refreshCurrencyRates(),
              tooltip: 'Refresh rates',
            ),
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: () => notifier.swapUnits(),
            tooltip: 'Swap units',
          ),
        ],
      ),
      body: body,
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
    required UiStyle uiStyle,
  }) {
    final isGlass = uiStyle == UiStyle.liquidGlass;
    final isLightGlass =
        isGlass && Theme.of(context).brightness == Brightness.light;
    final primaryTextColor = isLightGlass
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;
    final valueColor = isFrom && isGlass
        ? primaryTextColor
        : colorScheme.onSurface;
    final secondaryTextColor = isFrom && isGlass
        ? primaryTextColor.withValues(alpha: 0.72)
        : colorScheme.onSurfaceVariant;

    return SharedSurface(
      uiStyle: uiStyle,
      padding: const EdgeInsets.all(16.0),
      glassRole: isFrom ? GlassSurfaceRole.primary : GlassSurfaceRole.panel,
      materialColor: isFrom
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              _showUnitSelector(context, ref, isFrom);
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: secondaryTextColor),
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: valueColor,
                      fontWeight: isFrom ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    symbol,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
