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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.onPressed == null) return;
    if (_controller.isAnimating) return;

    final success = widget.onPressed!();
    if (!success && mounted) {
      HapticFeedback.vibrate();
      _controller.forward(from: 0.0);
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
          child: SizedBox.expand(
            child: FilledButton(
              onPressed: widget.onPressed == null ? null : _handlePress,
              style: FilledButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: child,
            ),
          ),
        )
        .animate(controller: _controller, autoPlay: false)
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
        // Subtle tinted surface — like the reference pinkish/lavender numbers
        return (cs.surfaceContainerLow, cs.onSurface, 26.0, FontWeight.w500);
      case ButtonType.operator:
        // Bold accent — blue column in reference
        return (cs.primary, cs.onPrimary, 24.0, FontWeight.w600);
      case ButtonType.action:
        // Grey surface buttons — ( ) % mod
        return (
          cs.surfaceContainerHigh,
          cs.onSurfaceVariant,
          20.0,
          FontWeight.w500,
        );
      case ButtonType.scientific:
        // Scientific utility row — subtle grey
        return (
          cs.surfaceContainerHigh,
          cs.onSurfaceVariant,
          20.0,
          FontWeight.w500,
        );
      case ButtonType.clear:
        // AC — red/error
        return (cs.errorContainer, cs.onErrorContainer, 20.0, FontWeight.w700);
      case ButtonType.backspace:
        // ⌫ — warm accent (orange-ish via tertiary)
        return (
          cs.tertiaryContainer,
          cs.onTertiaryContainer,
          20.0,
          FontWeight.w500,
        );
      case ButtonType.equals:
        // Full-width primary
        return (cs.primary, cs.onPrimary, 30.0, FontWeight.bold);
    }
  }
}
