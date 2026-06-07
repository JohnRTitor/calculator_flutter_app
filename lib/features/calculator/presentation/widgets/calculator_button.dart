import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ButtonType {
  number,
  operator,
  action,
  clear,
  equals,
  scientific,
  backspace,
}

class CalculatorButton extends StatefulWidget {
  final String text;
  final bool Function()? onPressed;
  final ButtonType type;
  final Widget? icon;
  final bool isActive;
  final int flex;

  const CalculatorButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.number,
    this.icon,
    this.isActive = false,
    this.flex = 1,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePressDown() {
    setState(() => _scale = 0.94);
  }

  void _handlePressUp() {
    setState(() => _scale = 1.0);
  }

  void _handlePress() {
    if (widget.onPressed == null) return;
    if (_shakeController.isAnimating) return;

    final success = widget.onPressed!();
    if (!success && mounted) {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (backgroundColor, foregroundColor, fontSize, fontWeight) = _getStyle(
      colorScheme,
    );

    final child =
        widget.icon ??
        Text(
          widget.text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
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
            child: FilledButton(
              onPressed: widget.onPressed == null ? null : _handlePress,
              style: FilledButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ).animate(controller: _shakeController, autoPlay: false)
        .shakeX(hz: 4, amount: 4);
  }

  (Color bg, Color fg, double fontSize, FontWeight fontWeight) _getStyle(
    ColorScheme cs,
  ) {
    if (widget.isActive) {
      return (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        18.0,
        FontWeight.w600,
      );
    }

    switch (widget.type) {
      case ButtonType.number:
        return (cs.surfaceContainerLow, cs.onSurface, 26.0, FontWeight.w500);
      case ButtonType.operator:
        return (cs.primary, cs.onPrimary, 24.0, FontWeight.w600);
      case ButtonType.action:
        return (
          cs.surfaceContainerHigh,
          cs.onSurfaceVariant,
          20.0,
          FontWeight.w500,
        );
      case ButtonType.scientific:
        return (
          cs.surfaceContainerHigh,
          cs.onSurfaceVariant,
          20.0,
          FontWeight.w500,
        );
      case ButtonType.clear:
        return (cs.errorContainer, cs.onErrorContainer, 20.0, FontWeight.w700);
      case ButtonType.backspace:
        return (
          cs.tertiaryContainer,
          cs.onTertiaryContainer,
          20.0,
          FontWeight.w500,
        );
      case ButtonType.equals:
        return (cs.primary, cs.onPrimary, 30.0, FontWeight.bold);
    }
  }
}
