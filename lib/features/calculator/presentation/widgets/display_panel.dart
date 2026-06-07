import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/token_text_field.dart';
import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';

class DisplayPanel extends ConsumerWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final uiStyle = ref.watch(uiStyleProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expression input
        const Align(alignment: Alignment.bottomRight, child: TokenTextField()),
        const SizedBox(height: 8),
        
        // Error or Preview
        if (state.error != null)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              state.error!,
              key: ValueKey('error_${state.error}'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else if (!state.showResult && state.preview.isNotEmpty)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '= ${state.preview}',
              key: ValueKey('preview_${state.preview}'),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  state.displayAsFraction && state.exactResult != null
                      ? state.exactResult!
                      : (state.result.isEmpty ? '0' : state.result),
                  key: ValueKey('result_${state.result}_${state.exactResult}'),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: 48,
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );

    if (uiStyle == UiStyle.liquidGlass) {
      return RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: GlassCard(
            shape: const LiquidRoundedSuperellipse(borderRadius: 24),
            useOwnLayer: true,
            settings: LiquidGlassSettings(
              thickness: 15,
              glassColor: colorScheme.surfaceContainerLowest.withValues(alpha: 0.08),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: content,
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: content,
      ),
    );
  }
}
