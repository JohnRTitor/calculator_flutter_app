import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_state.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';

class StructureExplorer extends ConsumerStatefulWidget {
  const StructureExplorer({super.key});

  @override
  ConsumerState<StructureExplorer> createState() => _StructureExplorerState();
}

class _StructureExplorerState extends ConsumerState<StructureExplorer> {
  late TextEditingController _nController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(modularWorkspaceProvider);
    _nController = TextEditingController(text: state.explorerN);
  }

  @override
  void dispose() {
    _nController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modularWorkspaceProvider);
    final uiStyle = ref.watch(uiStyleProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTypeSelector(context, state, uiStyle),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _buildNInput(context, state, uiStyle),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {
                  ref.read(modularWorkspaceProvider.notifier).analyzeStructure();
                },
                icon: const Icon(Icons.analytics),
                label: const Text('Analyze'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildResultArea(context, state, uiStyle, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle) {
    final theme = Theme.of(context);
    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.explorerType,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surfaceContainerHighest,
          items: const [
            DropdownMenuItem(value: 'ring', child: Text('Z_n (Ring)')),
            DropdownMenuItem(value: 'group', child: Text('Z_n* (Group)')),
            DropdownMenuItem(value: 'field', child: Text('GF(p) (Field)')),
          ],
          onChanged: (type) {
            if (type != null) {
              ref.read(modularWorkspaceProvider.notifier).setExplorerType(type);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNInput(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle) {
    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _nController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: state.explorerType == 'field' ? 'Prime p' : 'n',
          prefixText: state.explorerType == 'field' ? 'GF(' : (state.explorerType == 'group' ? 'U(' : 'Z_'),
          suffixText: ')',
        ),
        onChanged: (val) {
          ref.read(modularWorkspaceProvider.notifier).setExplorerN(val);
        },
      ),
    );
  }

  Widget _buildResultArea(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle, ThemeData theme) {
    if (state.explorerError != null) {
      return Center(
        child: Text(
          state.explorerError!,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    final res = state.explorerResult;
    if (res == null) {
      return Center(
        child: Text(
          'Enter a modulus and tap Analyze to explore its algebraic structure.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              res.label,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              res.classification,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),
            _buildInfoRow('Order', res.order, theme),
            _buildInfoRow('Identity', res.identity, theme),
            _buildInfoRow('Is Cyclic', res.isCyclic ? 'Yes' : 'No', theme),
            if (res.generators != null) _buildInfoRow('Generators', res.generators!, theme),
            if (res.units != null) _buildInfoRow('Units', res.units!, theme),
            if (res.zeroDivisors != null) _buildInfoRow('Zero Divisors', res.zeroDivisors!, theme),
            if (res.idempotents != null) _buildInfoRow('Idempotents', res.idempotents!, theme),
            if (res.nilpotents != null) _buildInfoRow('Nilpotents', res.nilpotents!, theme),
            if (res.inverses != null) _buildInfoRow('Inverses', res.inverses!, theme),
            if (res.elementOrders != null) _buildInfoRow('Element Orders', res.elementOrders!, theme),
            if (res.cayleyTable != null) ...[
              const SizedBox(height: 16),
              Text(
                'Cayley Table',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    res.cayleyTable!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
