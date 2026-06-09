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

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: SharedSurface(
                uiStyle: uiStyle,
                glassRole: GlassSurfaceRole.panel,
                frosted: true,
                borderRadius: BorderRadius.circular(32),
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: SizedBox(
                  width:
                      400, // Slightly increase width while constrained by insetPadding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(
                            alpha: 0.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'Clear History',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'This action will permanently remove ',
                            ),
                            TextSpan(
                              text:
                                  '$count saved calculation${count == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const TextSpan(text: ' and cannot be undone.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              minimumSize: const Size(0, 48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: const Icon(Icons.delete_forever, size: 20),
                            label: const Text(
                              'Clear History',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
