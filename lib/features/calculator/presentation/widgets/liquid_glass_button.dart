import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/calculator_button.dart';

/// A Liquid Glass variant of the calculator button.
///
/// Uses [GlassButton] from liquid_glass_widgets for translucent,
/// shader-based glass effects with dynamic lighting.
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
    setState(() => _scale = 0.94);
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
    final colorScheme = Theme.of(context).colorScheme;
    final (fgColor, fontSize, fontWeight) = _getGlassStyle(colorScheme);

    final label = widget.icon ?? Text(
      widget.text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fgColor,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SizedBox.expand(
          child: GestureDetector(
            onTapDown: (_) => _handlePressDown(),
            onTapUp: (_) => _handlePressUp(),
            onTapCancel: () => _handlePressUp(),
            child: GlassContainer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 28),
              useOwnLayer: true,
              settings: _getGlassSettings(colorScheme),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed == null ? null : _handlePress,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(child: label),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LiquidGlassSettings _getGlassSettings(ColorScheme cs) {
    Color tintColor;
    double thickness;
    
    if (widget.isActive) {
      tintColor = cs.tertiaryContainer.withValues(alpha: 0.15);
      thickness = 20;
    } else {
      switch (widget.type) {
        case ButtonType.number:
          tintColor = cs.surfaceContainerLow.withValues(alpha: 0.08);
          thickness = 10;
        case ButtonType.operator:
          tintColor = cs.primary.withValues(alpha: 0.15);
          thickness = 15;
        case ButtonType.action:
        case ButtonType.scientific:
          tintColor = cs.surfaceContainerHigh.withValues(alpha: 0.1);
          thickness = 12;
        case ButtonType.clear:
          tintColor = cs.errorContainer.withValues(alpha: 0.15);
          thickness = 15;
        case ButtonType.backspace:
          tintColor = cs.tertiaryContainer.withValues(alpha: 0.1);
          thickness = 15;
        case ButtonType.equals:
          tintColor = cs.primary.withValues(alpha: 0.2);
          thickness = 20;
      }
    }
    
    return LiquidGlassSettings(
      thickness: thickness,
      glassColor: tintColor,
    );
  }

  (Color fg, double fontSize, FontWeight fontWeight) _getGlassStyle(
    ColorScheme cs,
  ) {
    if (widget.isActive) {
      return (cs.onTertiaryContainer, 18.0, FontWeight.w600);
    }

    switch (widget.type) {
      case ButtonType.number:
        return (cs.onSurface, 26.0, FontWeight.w500);
      case ButtonType.operator:
        return (cs.primary, 24.0, FontWeight.w600);
      case ButtonType.action:
      case ButtonType.scientific:
        return (cs.onSurfaceVariant, 20.0, FontWeight.w500);
      case ButtonType.clear:
        return (cs.error, 20.0, FontWeight.w700);
      case ButtonType.backspace:
        return (cs.onTertiaryContainer, 20.0, FontWeight.w500);
      case ButtonType.equals:
        return (cs.primary, 30.0, FontWeight.bold);
    }
  }
}
