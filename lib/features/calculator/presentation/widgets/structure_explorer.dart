import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_provider.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_state.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/shared/widgets/app_dropdown_menu.dart';
import 'package:calculator_flutter_app/shared/widgets/app_button.dart';
import 'package:calculator_flutter_app/shared/widgets/app_dialog.dart';

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
              SizedBox(
                width: 140,
                height: 56,
                child: AppCalcButton(
                  text: 'Analyze',
                  type: ButtonType.equals,
                  uiStyle: uiStyle,
                  onPressed: () {
                    ref.read(modularWorkspaceProvider.notifier).analyzeStructure();
                    return true;
                  },
                  icon: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics, size: 20),
                      SizedBox(width: 8),
                      Text('Analyze', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context, uiStyle),
                tooltip: 'Supported Notation',
              )
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

  void _showInfoDialog(BuildContext context, UiStyle uiStyle) {
    showAppDialog(
      context: context,
      title: 'Supported Notation',
      icon: Icons.info_outline,
      uiStyle: uiStyle,
      primaryButtonText: 'Close',
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You can enter simple numbers, and the system will automatically convert them based on your selected type. Or, use any of the standard math notations:'),
          const SizedBox(height: 16),
          DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 60,
            columns: const [
              DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Accepted Forms', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Z₁₂')),
                DataCell(Text('Z_12, Z12, Z(12), Z/12Z')),
              ]),
              DataRow(cells: [
                DataCell(Text('U(85)')),
                DataCell(Text('U(85), Units(85), Z_85*')),
              ]),
              DataRow(cells: [
                DataCell(Text('GF(7)')),
                DataCell(Text('GF(7), GF7, F7')),
              ]),
              DataRow(cells: [
                DataCell(Text('GF(2⁸)')),
                DataCell(Text('GF(2^8), F(2^8)')),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle) {
    String currentLabel;
    switch (state.explorerType) {
      case 'ring': currentLabel = 'Z_n (Ring)'; break;
      case 'group': currentLabel = 'Z_n* (Group)'; break;
      case 'field': currentLabel = 'GF(p) (Field)'; break;
      default: currentLabel = 'Z_n (Ring)';
    }

    return AppDropdownMenu(
      label: currentLabel,
      uiStyle: uiStyle,
      isExpanded: true,
      entries: [
        AppDropdownMenuEntry(
          label: 'Z_n (Ring)',
          onPressed: () => ref.read(modularWorkspaceProvider.notifier).setExplorerType('ring'),
        ),
        AppDropdownMenuEntry(
          label: 'Z_n* (Group)',
          onPressed: () => ref.read(modularWorkspaceProvider.notifier).setExplorerType('group'),
        ),
        AppDropdownMenuEntry(
          label: 'GF(p) (Field)',
          onPressed: () => ref.read(modularWorkspaceProvider.notifier).setExplorerType('field'),
        ),
      ],
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
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: state.explorerType == 'field' ? 'Prime p' : 'n',
        ),
        onChanged: (val) {
          ref.read(modularWorkspaceProvider.notifier).setExplorerN(val);
        },
      ),
    );
  }

  Widget _buildResultArea(BuildContext context, ModularWorkspaceState state, UiStyle uiStyle, ThemeData theme) {
    if (state.explorerSuggestion != null) {
      return Center(
        child: ActionChip(
          avatar: const Icon(Icons.lightbulb_outline),
          label: Text(state.explorerSuggestion!),
          onPressed: () {
            // Extract what's between "mean " and "?"
            final sug = state.explorerSuggestion!;
            final match = RegExp(r'Did you mean (.*?)\?').firstMatch(sug);
            if (match != null) {
              final corrected = match.group(1)!;
              _nController.text = corrected;
              ref.read(modularWorkspaceProvider.notifier).setExplorerN(corrected);
              ref.read(modularWorkspaceProvider.notifier).analyzeStructure();
            }
          },
        ),
      );
    }

    if (state.explorerError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.explorerError!,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
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
            if (state.explorerInterpretedAs != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  state.explorerInterpretedAs!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
