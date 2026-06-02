import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/display_panel.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/keypad.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/history/presentation/screens/history_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/screens/settings_screen.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSci = ref.watch(calculatorProvider).isScientificMode;
    final isMem = ref.watch(calculatorProvider).isMemoryMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TextButton.icon(
              onPressed: () {
                ref.read(calculatorProvider.notifier).toggleScientificMode();
              },
              icon: Icon(isSci ? Icons.science : Icons.science_outlined, size: 18),
              label: Text(isSci ? 'Scientific' : 'Standard'),
              style: TextButton.styleFrom(
                foregroundColor: isSci ? colorScheme.onSecondaryContainer : colorScheme.primary,
                backgroundColor: isSci ? colorScheme.secondaryContainer : Colors.transparent,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                ref.read(calculatorProvider.notifier).toggleMemoryMode();
              },
              icon: Icon(isMem ? Icons.memory : Icons.memory_outlined, size: 18),
              label: const Text('Memory'),
              style: TextButton.styleFrom(
                foregroundColor: isMem ? colorScheme.onSecondaryContainer : colorScheme.primary,
                backgroundColor: isMem ? colorScheme.secondaryContainer : Colors.transparent,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(flex: 35, child: DisplayPanel()),
          Expanded(flex: 65, child: Keypad()),
        ],
      ),
    );
  }
}
