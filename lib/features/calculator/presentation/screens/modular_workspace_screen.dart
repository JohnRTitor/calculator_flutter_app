import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_state.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';

class ModularWorkspaceScreen extends ConsumerStatefulWidget {
  const ModularWorkspaceScreen({super.key});

  @override
  ConsumerState<ModularWorkspaceScreen> createState() => _ModularWorkspaceScreenState();
}

class _ModularWorkspaceScreenState extends ConsumerState<ModularWorkspaceScreen> {
  late TextEditingController _exprController;
  late TextEditingController _modController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(modularWorkspaceProvider);
    _exprController = TextEditingController(text: state.expression);
    _modController = TextEditingController(text: state.modulus);
  }

  @override
  void dispose() {
    _exprController.dispose();
    _modController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modularWorkspaceProvider);
    final uiStyle = ref.watch(uiStyleProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                // Config Row (Mode & Modulus)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildModeSelector(context, state, uiStyle),
                    ),
                    if (state.mode != ModularMode.crt) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildModulusInput(context, state, uiStyle),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                
                // Expression Editor
                Expanded(
                  child: _buildExpressionEditor(context, state, uiStyle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle) {
    final theme = Theme.of(context);
    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ModularMode>(
          value: state.mode,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surfaceContainerHighest,
          items: const [
            DropdownMenuItem(value: ModularMode.ring, child: Text('Z/nZ (Ring)')),
            DropdownMenuItem(value: ModularMode.field, child: Text('GF(p) (Field)')),
            DropdownMenuItem(value: ModularMode.crt, child: Text('CRT Solver')),
          ],
          onChanged: (mode) {
            if (mode != null) {
              ref.read(modularWorkspaceProvider.notifier).setMode(mode);
            }
          },
        ),
      ),
    );
  }

  Widget _buildModulusInput(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle) {
    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _modController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: state.mode == ModularMode.field ? 'Prime p' : 'Modulus n',
          prefixText: 'mod ',
        ),
        onChanged: (val) {
          ref.read(modularWorkspaceProvider.notifier).updateModulus(val);
        },
      ),
    );
  }

  Widget _buildExpressionEditor(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle) {
    final theme = Theme.of(context);
    
    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _exprController,
              maxLines: null,
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: state.mode == ModularMode.crt 
                    ? 'crt(rem1 mod mod1, rem2 mod mod2)' 
                    : 'e.g. powmod(2, 10, 100) or 5 + 7',
                hintStyle: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              onChanged: (val) {
                ref.read(modularWorkspaceProvider.notifier).updateExpression(val);
              },
            ),
          ),
          const SizedBox(height: 8),
          
          // Result/Preview Area
          if (state.error != null)
            Text(
              state.error!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
            )
          else if (state.showResult)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '= ${state.result}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.details != null)
                  Text(
                    state.details!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            )
          else if (state.preview.isNotEmpty)
            Text(
              '= ${state.preview}',
              textAlign: TextAlign.right,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: FilledButton.icon(
              onPressed: () {
                ref.read(modularWorkspaceProvider.notifier).evaluate();
                // update text field to result if needed or keep it?
                // we'll keep the expression
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Evaluate'),
            ),
          ),
        ],
      ),
    );
  }
}
