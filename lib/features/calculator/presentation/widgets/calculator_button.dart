import 'package:flutter/material.dart';

enum ButtonType { number, operator, action, clear, equals, scientific }

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final Widget? icon;
  final bool isActive;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.number,
    this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color foregroundColor;

    switch (type) {
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
      default:
        backgroundColor = colorScheme.surfaceContainerLowest;
        foregroundColor = colorScheme.onSurface;
        break;
    }

    if (isActive) {
      backgroundColor = colorScheme.tertiaryContainer;
      foregroundColor = colorScheme.onTertiaryContainer;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero,
        ),
        child: icon ??
            Text(
              text,
              style: TextStyle(
                fontSize: type == ButtonType.scientific ? 20 : 28,
                fontWeight: type == ButtonType.equals ? FontWeight.bold : FontWeight.normal,
              ),
            ),
      ),
    );
  }
}
