import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';

/// Provides the unified background gradient for the Liquid Glass mode.
/// This background should be shared across the main screen and pushed screens.
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
    final List<Color> gradientColors;

    if (themeMode == AppThemeMode.amoled) {
      // AMOLED: pure black with very subtle accent hints
      gradientColors = [
        Colors.black,
        colorScheme.primaryContainer.withValues(alpha: 0.06),
        Colors.black,
      ];
    } else if (brightness == Brightness.dark) {
      // Dark: deep dark with subtle color accents
      gradientColors = [
        colorScheme.surface,
        colorScheme.primaryContainer.withValues(alpha: 0.15),
        colorScheme.tertiaryContainer.withValues(alpha: 0.08),
        colorScheme.surface,
      ];
    } else {
      // Light: soft gradient with pastel tints
      gradientColors = [
        colorScheme.surface,
        colorScheme.primaryContainer.withValues(alpha: 0.3),
        colorScheme.tertiaryContainer.withValues(alpha: 0.2),
        colorScheme.surface,
      ];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
    );
  }
}

/// A unified surface container that automatically renders as a GlassCard
/// in Liquid Glass mode, and a Material Card/Container in Material You mode.
class SharedSurface extends StatelessWidget {
  final UiStyle uiStyle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? materialColor;
  final VoidCallback? onTap;
  
  // Glass specific
  final double glassThickness;
  final Color? glassColor;
  final bool isInteractive;

  const SharedSurface({
    super.key,
    required this.uiStyle,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.materialColor,
    this.onTap,
    this.glassThickness = 15,
    this.glassColor,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (uiStyle == UiStyle.liquidGlass) {
      Widget glassLayer = GlassContainer(
        shape: LiquidRoundedSuperellipse(
          borderRadius: borderRadius.resolve(Directionality.of(context)).topLeft.x,
        ),
        useOwnLayer: true,
        settings: LiquidGlassSettings(
          thickness: glassThickness,
          glassColor: glassColor ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        ),
        child: content,
      );

      if (onTap != null) {
        glassLayer = Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: glassLayer,
          ),
        );
        if (isInteractive) {
           // Basic scale animation wrapper could be added here if needed,
           // but keeping it lightweight.
        }
      }
      
      if (margin != null) {
        return Padding(padding: margin!, child: glassLayer);
      }
      return glassLayer;
    }

    // Material Mode
    Widget materialLayer = Material(
      color: materialColor ?? colorScheme.surfaceContainerHighest,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: content,
            )
          : content,
    );

    if (margin != null) {
      return Padding(padding: margin!, child: materialLayer);
    }
    return materialLayer;
  }
}
