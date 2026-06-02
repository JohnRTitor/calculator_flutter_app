import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/history/providers/history_provider.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => ref.read(historyProvider.notifier).clear(),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('No history yet'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Dismissible(
                key: ValueKey(entry.expression + index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: theme.colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: theme.colorScheme.onError),
                ),
                onDismissed: (_) {
                  ref.read(historyProvider.notifier).delete(index);
                },
                child: ListTile(
                  title: Text(entry.expression, style: theme.textTheme.titleMedium),
                  subtitle: Text('= ${entry.result}', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                  onTap: () {
                    ref.read(calculatorProvider.notifier).clear();
                    ref.read(calculatorProvider.notifier).append(entry.result);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
