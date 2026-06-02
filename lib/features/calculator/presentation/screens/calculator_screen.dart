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
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
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
          IconButton(
            icon: Icon(ref.watch(calculatorProvider).isScientificMode ? Icons.science : Icons.science_outlined),
            onPressed: () {
              ref.read(calculatorProvider.notifier).toggleScientificMode();
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
