import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';

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
    final colorOption = ref.watch(appColorProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final isDynamicColorSupported = lightDynamic != null;

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

        // ── Colors Section ──
        _SectionHeader(
          label: 'Colors',
          colorScheme: colorScheme,
          textTheme: theme.textTheme,
        ),
        const SizedBox(height: 8),
        _ColorsSelector(
          uiStyle: uiStyle,
          colorScheme: colorScheme,
          theme: theme,
          selectedOption: colorOption,
          isDynamicColorSupported: isDynamicColorSupported,
          onColorOptionChanged: (option) =>
              ref.read(appColorProvider.notifier).setAppColorOption(option),
        ),

        const SizedBox(height: 28),

        // ── Style Section ──
        _SectionHeader(
          label: 'Visual Style',
          colorScheme: colorScheme,
          textTheme: theme.textTheme,
        ),
        const SizedBox(height: 8),
        _StyleSelector(
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
      },
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

// ── Colors Selector ──
class _ColorsSelector extends StatelessWidget {
  final UiStyle uiStyle;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppColorOption selectedOption;
  final bool isDynamicColorSupported;
  final ValueChanged<AppColorOption> onColorOptionChanged;

  const _ColorsSelector({
    required this.uiStyle,
    required this.colorScheme,
    required this.theme,
    required this.selectedOption,
    required this.isDynamicColorSupported,
    required this.onColorOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StyleOptionCard(
                label: 'Default',
                icon: Icons.format_color_fill,
                description: 'Green aesthetic',
                isSelected: selectedOption == AppColorOption.defaultColor,
                uiStyle: uiStyle,
                colorScheme: colorScheme,
                onTap: () => onColorOptionChanged(AppColorOption.defaultColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StyleOptionCard(
                label: 'Material You',
                icon: Icons.auto_awesome,
                description: isDynamicColorSupported ? 'Dynamic color' : 'Not available',
                isSelected: selectedOption == AppColorOption.materialYou,
                uiStyle: uiStyle,
                colorScheme: colorScheme,
                isDisabled: !isDynamicColorSupported,
                onTap: isDynamicColorSupported
                    ? () => onColorOptionChanged(AppColorOption.materialYou)
                    : () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Other Colors',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ColorSwatch(
                color: Colors.blue,
                isSelected: selectedOption == AppColorOption.blue,
                onTap: () => onColorOptionChanged(AppColorOption.blue),
              ),
              const SizedBox(width: 12),
              _ColorSwatch(
                color: Colors.purple,
                isSelected: selectedOption == AppColorOption.purple,
                onTap: () => onColorOptionChanged(AppColorOption.purple),
              ),
              const SizedBox(width: 12),
              _ColorSwatch(
                color: Colors.orange,
                isSelected: selectedOption == AppColorOption.orange,
                onTap: () => onColorOptionChanged(AppColorOption.orange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Color Swatch ──
class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              )
            : null,
      ),
    );
  }
}

// ── Style Selector ──
class _StyleSelector extends StatelessWidget {
  final UiStyle uiStyle;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final ValueChanged<UiStyle> onStyleChanged;

  const _StyleSelector({
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
            label: 'Material',
            icon: Icons.layers_outlined,
            description: 'Standard design',
            isSelected: uiStyle == UiStyle.material,
            uiStyle: uiStyle,
            colorScheme: colorScheme,
            onTap: () => onStyleChanged(UiStyle.material),
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
  final bool isDisabled;
  final VoidCallback onTap;

  const _StyleOptionCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.uiStyle,
    required this.colorScheme,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card;
    if (uiStyle == UiStyle.liquidGlass) {
      card = _buildGlassVariant(context);
    } else {
      card = _buildMaterialVariant();
    }

    if (isDisabled) {
      return Opacity(
        opacity: 0.5,
        child: card,
      );
    }
    return card;
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
