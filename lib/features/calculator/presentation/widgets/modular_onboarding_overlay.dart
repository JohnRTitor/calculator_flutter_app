import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModularOnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ModularOnboardingOverlay({super.key, required this.onComplete});

  /// Checks SharedPreferences and shows the onboarding if it hasn't been shown yet.
  static Future<void> checkAndShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('has_shown_modular_onboarding') ?? false;

    if (!hasShown && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ModularOnboardingOverlay(
          onComplete: () async {
            await prefs.setBool('has_shown_modular_onboarding', true);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  /// Forces showing the onboarding, e.g., from a settings menu.
  static void forceShow(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ModularOnboardingOverlay(
        onComplete: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  State<ModularOnboardingOverlay> createState() => _ModularOnboardingOverlayState();
}

class _ModularOnboardingOverlayState extends State<ModularOnboardingOverlay> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Welcome to the Abstract Algebra Workstation',
      'desc': 'A powerful tool for modular arithmetic, number theory, and finite fields.',
      'icon': Icons.calculate_outlined,
    },
    {
      'title': 'Dual Tabs',
      'desc': 'Use the Evaluator tab for arithmetic and equations (e.g., powmod, crt). Use the Structure Explorer tab to analyze rings and groups.',
      'icon': Icons.tab,
    },
    {
      'title': 'Educational Mode',
      'desc': 'Turn on Educational Mode in Settings to see step-by-step proofs for operations like Extended GCD and Discrete Logarithm.',
      'icon': Icons.school_outlined,
    },
    {
      'title': 'Need Help?',
      'desc': 'Tap the (?) icon in the top right at any time to see the list of supported operations and examples.',
      'icon': Icons.help_outline,
    },
  ];

  void _next() {
    if (_currentIndex < _steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_currentIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              step['icon'] as IconData,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              step['title'] as String,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              step['desc'] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _steps.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _next,
                  child: Text(_currentIndex == _steps.length - 1 ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
