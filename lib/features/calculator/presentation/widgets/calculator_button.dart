import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ButtonType { number, operator, action, clear, equals, scientific }

class CalculatorButton extends StatefulWidget {
  final String text;
  final bool Function()? onPressed;
  final ButtonType type;
  final Widget? icon;
  final bool isActive;

  const CalculatorButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.number,
    this.icon,
    this.isActive = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
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

    Color backgroundColor;
    Color foregroundColor;

    switch (widget.type) {
      case ButtonType.operator:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case ButtonType.action:
      case ButtonType.scientific:
        backgroundColor = colorScheme.surfaceContainerHigh;
        foregroundColor = colorScheme.onSurfaceVariant;
        break;
      case ButtonType.clear:
        backgroundColor = colorScheme.errorContainer;
        foregroundColor = colorScheme.onErrorContainer;
        break;
      case ButtonType.equals:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case ButtonType.number:
        backgroundColor = colorScheme.surfaceContainerLowest;
        foregroundColor = colorScheme.onSurface;
        break;
    }

    if (widget.isActive) {
      backgroundColor = colorScheme.tertiaryContainer;
      foregroundColor = colorScheme.onTertiaryContainer;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FilledButton(
        onPressed: widget.onPressed == null ? null : _handlePress,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero,
        ),
        child: widget.icon ??
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.type == ButtonType.scientific ? 20 : 28,
                fontWeight: widget.type == ButtonType.equals ? FontWeight.bold : FontWeight.normal,
              ),
            ),
      ),
    ).animate(controller: _controller, autoPlay: false).shakeX(hz: 4, amount: 4);
  }
}
