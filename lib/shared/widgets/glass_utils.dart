import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';

/// Lightweight Liquid Glass roles for consistent, theme-aware surfaces.
enum GlassSurfaceRole { panel, card, button, accent, primary, destructive }

class GlassStyle {
  final Color fillColor;
  final Color borderColor;
  final Color foregroundColor;
  final List<BoxShadow> shadows;

  const GlassStyle({
    required this.fillColor,
    required this.borderColor,
    required this.foregroundColor,
    this.shadows = const [],
  });
}

/// Provides a lightweight, flat-tint background for Liquid Glass mode.
/// Rendered once at the app root — no gradients, no blur, no shader passes.
class SharedGlassBackground extends StatelessWidget {
  final AppThemeMode themeMode;
  final Brightness brightness;
  final ColorScheme colorScheme;

  const SharedGlassBackground({
    super.key,
    required this.themeMode,
    required this.brightness,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;

    if (themeMode == AppThemeMode.amoled) {
      bgColor = Colors.black;
    } else if (brightness == Brightness.dark) {
      bgColor = Color.lerp(
        colorScheme.surface,
        colorScheme.primaryContainer,
        0.04,
      )!;
    } else {
      bgColor = Color.lerp(
        colorScheme.surface,
        colorScheme.primaryContainer,
        0.08,
      )!;
    }

    return ColoredBox(color: bgColor);
  }
}

GlassStyle resolveGlassStyle(
  ColorScheme colorScheme, {
  required Brightness brightness,
  GlassSurfaceRole role = GlassSurfaceRole.card,
  bool isSelected = false,
}) {
  final bool isDark = brightness == Brightness.dark;
  final Color baseSurface = isDark
      ? colorScheme.surfaceContainerHigh
      : colorScheme.surface;
  final Color raisedSurface = isDark
      ? colorScheme.surfaceContainerHighest
      : colorScheme.surfaceContainerLow;

  switch (role) {
    case GlassSurfaceRole.panel:
      return GlassStyle(
        fillColor: isDark
            ? raisedSurface.withValues(alpha: 0.66)
            : Color.lerp(
                baseSurface,
                raisedSurface,
                0.72,
              )!.withValues(alpha: 0.94),
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : colorScheme.outlineVariant.withValues(alpha: 0.22),
        foregroundColor: colorScheme.onSurface,
      );
    case GlassSurfaceRole.card:
      return GlassStyle(
        fillColor: isDark
            ? raisedSurface.withValues(alpha: isSelected ? 0.72 : 0.58)
            : Color.lerp(
                baseSurface,
                raisedSurface,
                isSelected ? 0.88 : 0.7,
              )!.withValues(alpha: isSelected ? 0.96 : 0.9),
        borderColor: isSelected
            ? colorScheme.primary.withValues(alpha: isDark ? 0.34 : 0.32)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colorScheme.outlineVariant.withValues(alpha: 0.18)),
        foregroundColor: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
        shadows: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(
                    alpha: isDark ? 0.12 : 0.1,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      );
    case GlassSurfaceRole.button:
      return GlassStyle(
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh.withValues(
                alpha: isSelected ? 0.72 : 0.56,
              )
            : Color.lerp(
                baseSurface,
                raisedSurface,
                isSelected ? 0.92 : 0.76,
              )!.withValues(alpha: isSelected ? 0.96 : 0.88),
        borderColor: isSelected
            ? colorScheme.primary.withValues(alpha: isDark ? 0.34 : 0.28)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colorScheme.outlineVariant.withValues(alpha: 0.16)),
        foregroundColor: isSelected
            ? colorScheme.primary
            : colorScheme.onSurface,
      );
    case GlassSurfaceRole.accent:
      return GlassStyle(
        fillColor: isDark
            ? colorScheme.tertiaryContainer.withValues(
                alpha: isSelected ? 0.5 : 0.34,
              )
            : Color.lerp(
                colorScheme.tertiaryContainer,
                baseSurface,
                0.18,
              )!.withValues(alpha: isSelected ? 0.94 : 0.9),
        borderColor: colorScheme.tertiary.withValues(
          alpha: isDark ? 0.32 : 0.24,
        ),
        foregroundColor: isSelected
            ? colorScheme.onTertiaryContainer
            : colorScheme.tertiary,
      );
    case GlassSurfaceRole.primary:
      return GlassStyle(
        fillColor: isDark
            ? colorScheme.primary.withValues(alpha: isSelected ? 0.34 : 0.26)
            : Color.lerp(
                colorScheme.primaryContainer,
                colorScheme.primary,
                0.18,
              )!.withValues(alpha: isSelected ? 0.98 : 0.94),
        borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.3),
        foregroundColor: isDark
            ? colorScheme.onPrimaryContainer
            : (isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer),
        shadows: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );
    case GlassSurfaceRole.destructive:
      return GlassStyle(
        fillColor: isDark
            ? colorScheme.errorContainer.withValues(alpha: 0.34)
            : Color.lerp(
                colorScheme.errorContainer,
                baseSurface,
                0.2,
              )!.withValues(alpha: 0.94),
        borderColor: colorScheme.error.withValues(alpha: isDark ? 0.24 : 0.18),
        foregroundColor: isDark
            ? colorScheme.onErrorContainer
            : colorScheme.error,
      );
  }
}

/// A unified surface widget for Material You and Liquid Glass styles.
class SharedSurface extends StatelessWidget {
  final UiStyle uiStyle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? materialColor;
  final VoidCallback? onTap;
  final Color? glassColor;
  final bool isInteractive;
  final bool isSelected;
  final GlassSurfaceRole glassRole;

  const SharedSurface({
    super.key,
    required this.uiStyle,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.materialColor,
    this.onTap,
    this.glassColor,
    this.isInteractive = false,
    this.isSelected = false,
    this.glassRole = GlassSurfaceRole.card,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (uiStyle == UiStyle.liquidGlass) {
      final style = resolveGlassStyle(
        colorScheme,
        brightness: theme.brightness,
        role: glassRole,
        isSelected: isSelected,
      );

      Widget glassLayer = DecoratedBox(
        decoration: BoxDecoration(
          color: glassColor ?? style.fillColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: style.borderColor,
            width: isSelected ? 1.2 : 0.7,
          ),
          boxShadow: style.shadows,
        ),
        child: ClipRRect(borderRadius: borderRadius, child: content),
      );

      if (onTap != null || isInteractive) {
        glassLayer = Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: glassLayer,
          ),
        );
      }

      if (margin != null) {
        return Padding(padding: margin!, child: glassLayer);
      }
      return glassLayer;
    }

    Widget materialLayer = Material(
      color: materialColor ?? colorScheme.surfaceContainerHighest,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: onTap != null || isInteractive
          ? InkWell(onTap: onTap, child: content)
          : content,
    );

    if (margin != null) {
      return Padding(padding: margin!, child: materialLayer);
    }
    return materialLayer;
  }
}
