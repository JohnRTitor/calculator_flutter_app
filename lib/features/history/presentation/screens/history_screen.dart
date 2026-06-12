import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/history/presentation/providers/history_provider.dart';
import 'package:calculator_flutter_app/features/history/presentation/providers/function_history_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/function_evaluator_provider.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/shared/widgets/pill_switcher.dart';
import 'package:calculator_flutter_app/shared/widgets/app_dialog.dart';

/// A screen that displays a list of past calculations.
///
/// Allows users to view their calculation history, tap an entry to restore it to the
/// calculator display, swipe to delete individual entries, or clear the entire history.
class HistoryScreen extends ConsumerStatefulWidget {
  final bool initialIsFuncMode;

  const HistoryScreen({super.key, this.initialIsFuncMode = false});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late bool isFuncMode;

  @override
  void initState() {
    super.initState();
    isFuncMode = widget.initialIsFuncMode;
  }

  @override
  Widget build(BuildContext context) {
    final uiStyle = ref.watch(uiStyleProvider);
    final historyAsync = isFuncMode
        ? ref.watch(functionHistoryProvider)
        : ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all history',
            onPressed: () async {
              final historyList = isFuncMode
                  ? ref.read(functionHistoryProvider).value ?? []
                  : ref.read(historyProvider).value ?? [];
              if (historyList.isEmpty) return;

              final uiStyle = ref.read(uiStyleProvider);
              final confirm = await _showClearHistoryDialog(
                context,
                historyList.length,
                uiStyle,
              );
              if (confirm == true) {
                if (isFuncMode) {
                  ref.read(functionHistoryProvider.notifier).clear();
                } else {
                  ref.read(historyProvider.notifier).clear();
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: PillSwitcher(
              uiStyle: uiStyle,
              label1: 'Calculator',
              label2: 'Fn Evaluator',
              isFirstSelected: !isFuncMode,
              onChanged: (isFirst) {
                setState(() {
                  isFuncMode = !isFirst;
                });
              },
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No history yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Dismissible(
                      key: ValueKey(entry.expression + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      onDismissed: (_) {
                        if (isFuncMode) {
                          ref
                              .read(functionHistoryProvider.notifier)
                              .delete(index);
                        } else {
                          ref.read(historyProvider.notifier).delete(index);
                        }
                      },
                      child: Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (isFuncMode) {
                              ref
                                  .read(functionEvaluatorProvider.notifier)
                                  .clear();
                              ref
                                  .read(functionEvaluatorProvider.notifier)
                                  .setExpression(entry.expression);
                            } else {
                              ref.read(calculatorProvider.notifier).clear();
                              ref
                                  .read(calculatorProvider.notifier)
                                  .append(entry.result);
                            }
                            Navigator.pop(context, isFuncMode);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  entry.expression,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '= ${entry.result}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showClearHistoryDialog(
    BuildContext context,
    int count,
    UiStyle uiStyle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showAppDialog<bool>(
      context: context,
      title: 'Clear History',
      icon: Icons.delete_outline,
      uiStyle: uiStyle,
      isDestructive: true,
      primaryButtonText: 'Clear History',
      onPrimaryButtonPressed: () => Navigator.of(context).pop(true),
      secondaryButtonText: 'Cancel',
      onSecondaryButtonPressed: () => Navigator.of(context).pop(false),
      content: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'This action will permanently remove '),
            TextSpan(
              text: '$count saved calculation${count == 1 ? '' : 's'}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const TextSpan(text: ' and cannot be undone.'),
          ],
        ),
      ),
    );
  }
}
