import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/function_evaluator_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/widgets/variable_bottom_sheet.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';

import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/app/theme/app_theme_extension.dart';

class FunctionEvaluatorScreen extends ConsumerStatefulWidget {
  const FunctionEvaluatorScreen({super.key});

  @override
  ConsumerState<FunctionEvaluatorScreen> createState() => _FunctionEvaluatorScreenState();
}

class _FunctionEvaluatorScreenState extends ConsumerState<FunctionEvaluatorScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialText = ref.read(functionEvaluatorProvider).funcExpression;
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VariableBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(functionEvaluatorProvider);
    final uiStyle = ref.watch(uiStyleProvider);
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                // Function Editor
                SharedSurface(
                  uiStyle: uiStyle,
                  glassRole: GlassSurfaceRole.card,
                  frosted: true,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    minLines: 2,
                    style: theme.textTheme.headlineSmall,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'f(x, y, z) = x^2 + y^2 + z^2',
                      hintStyle: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(functionEvaluatorProvider.notifier).setExpression(val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Chips Area
                if (state.detectedVariables.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.detectedVariables.map((variable) {
                        final val = state.variables[variable] ?? 0.0;
                        final displayVal = val == val.truncateToDouble() ? val.toInt().toString() : val.toString();
                        return ActionChip(
                          label: Text('[$variable = $displayVal]'),
                          onPressed: _showBottomSheet,
                          backgroundColor: themeExt.chipBackground,
                          labelStyle: theme.textTheme.titleMedium?.copyWith(
                            color: themeExt.chipText,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                const Spacer(),

                // Result Area
                SharedSurface(
                  uiStyle: uiStyle,
                  glassRole: GlassSurfaceRole.primary,
                  materialColor: themeExt.resultCard,
                  frosted: true,
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Result',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: themeExt.resultText.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.showResult 
                            ? (state.exactResult ?? state.result)
                            : (state.preview.isEmpty ? '0' : state.preview),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: themeExt.resultText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Evaluate Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(functionEvaluatorProvider.notifier).evaluate();
                      FocusScope.of(context).unfocus();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Evaluate',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
