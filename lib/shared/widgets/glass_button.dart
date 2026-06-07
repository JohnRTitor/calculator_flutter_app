import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A lightweight Liquid Glass variant of the calculator button.
///
/// Provides animated scale feedback and haptic feedback on error. It utilizes
/// `SharedSurface` under the hood to ensure consistency with the Liquid Glass design system.
class LiquidGlassCalcButton extends StatefulWidget {
  final String text;
  final bool Function()? onPressed;
  final ButtonType type;
  final Widget? icon;
  final bool isActive;

  const LiquidGlassCalcButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.number,
    this.icon,
    this.isActive = false,
  });

  @override
  State<LiquidGlassCalcButton> createState() => _LiquidGlassCalcButtonState();
}

class _LiquidGlassCalcButtonState extends State<LiquidGlassCalcButton> {
  double _scale = 1.0;

  void _handlePressDown() {
    setState(() => _scale = 0.97);
  }

  void _handlePressUp() {
    setState(() => _scale = 1.0);
  }

  void _handlePress() {
    if (widget.onPressed == null) return;
    final success = widget.onPressed!();
    if (!success && mounted) {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = _resolveButtonStyle(colorScheme, theme.brightness);

    final label = IconTheme(
      data: IconThemeData(color: style.foregroundColor),
      child:
          widget.icon ??
          Text(
            widget.text,
            style: TextStyle(
              fontSize: style.fontSize,
              fontWeight: style.fontWeight,
              color: style.foregroundColor,
            ),
          ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: SizedBox.expand(
          child: GestureDetector(
            onTapDown: (_) => _handlePressDown(),
            onTapUp: (_) => _handlePressUp(),
            onTapCancel: _handlePressUp,
            child: SharedSurface(
              uiStyle: UiStyle.liquidGlass,
              onTap: widget.onPressed == null ? null : _handlePress,
              isInteractive: true,
              isSelected: widget.isActive,
              glassRole: style.role,
              frosted:
                  style.role == GlassSurfaceRole.primary ||
                  style.role == GlassSurfaceRole.destructive ||
                  widget.isActive,
              borderRadius: BorderRadius.circular(28),
              child: Center(child: label),
            ),
          ),
        ),
      ),
    );
  }

  _GlassButtonStyle _resolveButtonStyle(ColorScheme cs, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    if (widget.isActive) {
      return _GlassButtonStyle(
        role: GlassSurfaceRole.primary,
        foregroundColor: cs.onPrimaryContainer,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );
    }

    switch (widget.type) {
      case ButtonType.number:
        return _GlassButtonStyle(
          role: GlassSurfaceRole.button,
          foregroundColor: cs.onSurface,
          fontSize: 26,
          fontWeight: FontWeight.w500,
        );
      case ButtonType.operator:
        return _GlassButtonStyle(
          role: GlassSurfaceRole.primary,
          foregroundColor: cs.onPrimaryContainer,
          fontSize: widget.text == 'mod' ? 18 : 24,
          fontWeight: FontWeight.w700,
        );
      case ButtonType.action:
      case ButtonType.scientific:
        return _GlassButtonStyle(
          role: GlassSurfaceRole.accent,
          foregroundColor: widget.isActive
              ? cs.onTertiaryContainer
              : (isDark ? cs.onTertiaryContainer : cs.tertiary),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        );
      case ButtonType.clear:
        return _GlassButtonStyle(
          role: GlassSurfaceRole.destructive,
          foregroundColor: cs.onErrorContainer,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        );
      case ButtonType.backspace:
        return _GlassButtonStyle(
          role: GlassSurfaceRole.accent,
          foregroundColor: isDark ? cs.onTertiaryContainer : cs.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        );
      case ButtonType.equals:
        return _GlassButtonStyle(
          role: GlassSurfaceRole.primary,
          foregroundColor: cs.onPrimaryContainer,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        );
    }
  }
}

class _GlassButtonStyle {
  final GlassSurfaceRole role;
  final Color foregroundColor;
  final double fontSize;
  final FontWeight fontWeight;

  const _GlassButtonStyle({
    required this.role,
    required this.foregroundColor,
    required this.fontSize,
    required this.fontWeight,
  });
}
