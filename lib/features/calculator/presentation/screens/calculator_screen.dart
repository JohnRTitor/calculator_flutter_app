import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/keypad.dart';
import 'package:calculator_flutter_app/features/history/presentation/screens/history_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/screens/settings_screen.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Minimal top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history, size: 22),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                      tooltip: 'History',
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 22, color: colorScheme.onSurfaceVariant),
                      tooltip: 'More options',
                      onSelected: (value) {
                        if (value == 'settings') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'settings', child: Text('Settings')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Display card
            const Expanded(flex: 25, child: DisplayPanel()),

            // Keypad
            const Expanded(flex: 75, child: Keypad()),
          ],
        ),
      ),
    );
  }
}
