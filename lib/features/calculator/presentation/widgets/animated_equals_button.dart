import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedEqualsButton extends StatefulWidget {
  final Future<bool> Function() onEvaluate;

  const AnimatedEqualsButton({super.key, required this.onEvaluate});

  @override
  State<AnimatedEqualsButton> createState() => _AnimatedEqualsButtonState();
}

class _AnimatedEqualsButtonState extends State<AnimatedEqualsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: colorScheme.primaryContainer, end: colorScheme.error), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: colorScheme.error, end: colorScheme.primaryContainer), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (_controller.isAnimating) return;
    final success = await widget.onEvaluate();
    if (!success && mounted) {
      HapticFeedback.vibrate();
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(3.0),
          child: SizedBox.expand(
            child: Tooltip(
              message: 'Calculate',
              waitDuration: const Duration(milliseconds: 400),
              child: FilledButton(
                onPressed: _handlePress,
                style: FilledButton.styleFrom(
                  backgroundColor: _controller.isAnimating
                      ? _colorAnimation.value
                      : colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '=',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ).animate(controller: _controller, autoPlay: false).shakeX(hz: 4, amount: 4);
      },
    );
  }
}
