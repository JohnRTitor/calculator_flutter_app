import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/token_text_field.dart';

class DisplayPanel extends ConsumerWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression input
          const Expanded(child: Align(alignment: Alignment.bottomRight, child: TokenTextField())),
          const SizedBox(height: 8),
          
          // Error or Preview
          if (state.error != null)
            Text(
              state.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else if (!state.showResult && state.preview.isNotEmpty)
            Text(
              '= ${state.preview}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ),

          // Main Result
          if (state.showResult)
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: state.result));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Result copied'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  state.displayAsFraction && state.exactResult != null
                      ? state.exactResult!
                      : (state.result.isEmpty ? '0' : state.result),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: 48,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}
