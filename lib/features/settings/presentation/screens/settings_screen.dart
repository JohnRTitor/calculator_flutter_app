import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/core/theme/glass_utils.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _themeLabels = {
    AppThemeMode.system: ('System', Icons.brightness_auto),
    AppThemeMode.light: ('Light', Icons.light_mode),
    AppThemeMode.dark: ('Dark', Icons.dark_mode),
    AppThemeMode.amoled: ('AMOLED', Icons.contrast),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final uiStyle = ref.watch(uiStyleProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // ── Theme Section ──
        _SectionHeader(
          label: 'Theme',
          colorScheme: colorScheme,
          textTheme: theme.textTheme,
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: AppThemeMode.values.map((mode) {
            final (label, icon) = _themeLabels[mode]!;
            final isSelected = themeMode == mode;
            return _ThemeCard(
              label: label,
              icon: icon,
              isSelected: isSelected,
              uiStyle: uiStyle,
              colorScheme: colorScheme,
              onTap: () =>
                  ref.read(themeModeProvider.notifier).setThemeMode(mode),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // ── Visual Style Section ──
        _SectionHeader(
          label: 'Visual Style',
          colorScheme: colorScheme,
          textTheme: theme.textTheme,
        ),
        const SizedBox(height: 8),
        _VisualStyleSelector(
          uiStyle: uiStyle,
          colorScheme: colorScheme,
          theme: theme,
          onStyleChanged: (style) =>
              ref.read(uiStyleProvider.notifier).setUiStyle(style),
        ),

        const SizedBox(height: 28),

        // ── About Section ──
        _SectionHeader(
          label: 'About',
          colorScheme: colorScheme,
          textTheme: theme.textTheme,
        ),
        const SizedBox(height: 8),
        _buildAboutCard(theme, colorScheme, uiStyle),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: body,
    );
  }

  Widget _buildAboutCard(
    ThemeData theme,
    ColorScheme colorScheme,
    UiStyle uiStyle,
  ) {
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculator',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Flutter + Rust Native Calculator.\nBuilt for performance and elegance.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );

    if (uiStyle == UiStyle.liquidGlass) {
      return SharedSurface(
        uiStyle: uiStyle,
        glassRole: GlassSurfaceRole.panel,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: content,
    );
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionHeader({
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Theme Card ──
class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final UiStyle uiStyle;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.uiStyle,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (uiStyle == UiStyle.liquidGlass) {
      return _buildGlassCard(context);
    }
    return _buildMaterialCard();
  }

  Widget _buildMaterialCard() {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.97,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.97,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: SharedSurface(
        uiStyle: uiStyle,
        isInteractive: true,
        isSelected: isSelected,
        glassRole: isSelected
            ? GlassSurfaceRole.primary
            : GlassSurfaceRole.card,
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Widget _buildCardContent([BuildContext? context]) {
    final bool useLightSelectedText =
        context != null &&
        uiStyle == UiStyle.liquidGlass &&
        Theme.of(context).brightness == Brightness.light;
    final selectedColor = useLightSelectedText
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Visual Style Selector ──
class _VisualStyleSelector extends StatelessWidget {
  final UiStyle uiStyle;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final ValueChanged<UiStyle> onStyleChanged;

  const _VisualStyleSelector({
    required this.uiStyle,
    required this.colorScheme,
    required this.theme,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StyleOptionCard(
            label: 'Material You',
            icon: Icons.palette_outlined,
            description: 'Dynamic color',
            isSelected: uiStyle == UiStyle.materialYou,
            uiStyle: uiStyle,
            colorScheme: colorScheme,
            onTap: () => onStyleChanged(UiStyle.materialYou),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StyleOptionCard(
            label: 'Liquid Glass',
            icon: Icons.blur_on,
            description: 'Translucent glass',
            isSelected: uiStyle == UiStyle.liquidGlass,
            uiStyle: uiStyle,
            colorScheme: colorScheme,
            onTap: () => onStyleChanged(UiStyle.liquidGlass),
          ),
        ),
      ],
    );
  }
}

// ── Style Option Card ──
class _StyleOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final UiStyle uiStyle;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _StyleOptionCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.uiStyle,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (uiStyle == UiStyle.liquidGlass) {
      return _buildGlassVariant(context);
    }
    return _buildMaterialVariant();
  }

  Widget _buildMaterialVariant() {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.97,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassVariant(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.97,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: SharedSurface(
        uiStyle: uiStyle,
        isInteractive: true,
        isSelected: isSelected,
        glassRole: isSelected
            ? GlassSurfaceRole.primary
            : GlassSurfaceRole.card,
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent([BuildContext? context]) {
    final bool useLightSelectedText =
        context != null &&
        uiStyle == UiStyle.liquidGlass &&
        Theme.of(context).brightness == Brightness.light;
    final selectedColor = useLightSelectedText
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: (isSelected ? selectedColor : colorScheme.onSurfaceVariant)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
