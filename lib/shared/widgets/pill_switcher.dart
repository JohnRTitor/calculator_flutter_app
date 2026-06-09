import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/app_theme_extension.dart';

/// A generic pill switcher that acts as a two-option segmented control.
///
/// If [UiStyle.liquidGlass] is active, it renders as a frosted glass pill containing
/// two selectable chips. If [UiStyle.material] is active, it falls back to the standard
/// Material 3 [SegmentedButton].
class PillSwitcher extends StatelessWidget {
  final UiStyle uiStyle;
  final String label1;
  final String label2;
  final bool isFirstSelected;
  final ValueChanged<bool> onChanged;

  const PillSwitcher({
    super.key,
    required this.uiStyle,
    required this.label1,
    required this.label2,
    required this.isFirstSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (uiStyle != UiStyle.liquidGlass) {
      return SegmentedButton<bool>(
        segments: [
          ButtonSegment<bool>(
            value: true,
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(label1),
            ),
          ),
          ButtonSegment<bool>(
            value: false,
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(label2),
            ),
          ),
        ],
        selected: {isFirstSelected},
        onSelectionChanged: (Set<bool> newSelection) {
          onChanged(newSelection.first);
        },
      );
    }

    // Liquid Glass Mode
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
                label: label1,
                isSelected: isFirstSelected,
                onTap: () {
                  if (!isFirstSelected) {
                    onChanged(true);
                  }
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildToggleChip(
                context: context,
                label: label2,
                isSelected: !isFirstSelected,
                onTap: () {
                  if (isFirstSelected) {
                    onChanged(false);
                  }
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
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;
    final bgColor = isSelected ? themeExt.chipBackground : Colors.transparent;
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
