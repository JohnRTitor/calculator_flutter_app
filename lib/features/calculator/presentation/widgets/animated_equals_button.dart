import 'package:flutter/material.dart';

class AnimatedEqualsButton extends StatefulWidget {
  final Future<bool> Function() onEvaluate;

  const AnimatedEqualsButton({super.key, required this.onEvaluate});

  @override
  State<AnimatedEqualsButton> createState() => _AnimatedEqualsButtonState();
}

class _AnimatedEqualsButtonState extends State<AnimatedEqualsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: colorScheme.primary, end: colorScheme.error), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: colorScheme.error, end: colorScheme.primary), weight: 1),
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
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Tooltip(
                message: 'Calculate',
                waitDuration: const Duration(milliseconds: 400),
                child: FilledButton(
                  onPressed: _handlePress,
                  style: FilledButton.styleFrom(
                    backgroundColor: _controller.isAnimating ? _colorAnimation.value : Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    '=',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
