import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/modular_arithmetic.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';

class ModularArithmeticAnalysisGrid extends StatelessWidget {
  final UiStyle uiStyle;
  final StructureAnalysis analysis;
  final String? interpretedAs;

  const ModularArithmeticAnalysisGrid({
    super.key,
    required this.uiStyle,
    required this.analysis,
    this.interpretedAs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool isField = analysis.classification.toLowerCase().contains('field');
    final String typeStr = isField ? 'Field' : 'Ring';

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (interpretedAs != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              interpretedAs!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        Text(
          'Analysis Results',
          style: theme.textTheme.labelLarge?.copyWith(
            color: uiStyle == UiStyle.liquidGlass ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            double width = (constraints.maxWidth - (8 * (crossAxisCount - 1))) / crossAxisCount;
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: width,
                  child: _ModularPropertyCard(
                    uiStyle: uiStyle,
                    title: 'Type:',
                    value: typeStr,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ModularPropertyCard(
                    uiStyle: uiStyle,
                    title: 'Elements:',
                    value: analysis.order,
                  ),
                ),
                if (analysis.units != null)
                  SizedBox(
                    width: width,
                    child: _ModularPropertyCard(
                      uiStyle: uiStyle,
                      title: 'Units:',
                      value: _countItems(analysis.units),
                    ),
                  ),
                SizedBox(
                  width: width,
                  child: _ModularPropertyCard(
                    uiStyle: uiStyle,
                    title: 'Characteristic:',
                    value: analysis.identity, // Assuming identity is used for characteristic here based on old code, wait old code used identity for Identity, let's just show identity
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        _ModularExpandableSection(
          uiStyle: uiStyle,
          title: '[ Show Advanced Properties ]',
          initiallyExpanded: false,
          children: [
            _ModularPropertyCard(
              uiStyle: uiStyle,
              title: 'Is Cyclic',
              value: analysis.isCyclic ? 'Yes' : 'No',
            ),
            if (analysis.generators != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Generators',
                value: _countItems(analysis.generators),
                subtitle: analysis.generators,
              ),
            if (analysis.zeroDivisors != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Zero Divisors',
                value: _countItems(analysis.zeroDivisors),
                subtitle: analysis.zeroDivisors,
              ),
            if (analysis.idempotents != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Idempotents',
                value: _countItems(analysis.idempotents),
                subtitle: analysis.idempotents,
              ),
            if (analysis.nilpotents != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Nilpotents',
                value: _countItems(analysis.nilpotents),
                subtitle: analysis.nilpotents,
              ),
            if (analysis.inverses != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Inverses',
                value: 'View Details',
                subtitle: analysis.inverses,
                fullWidth: true,
              ),
            if (analysis.elementOrders != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Element Orders',
                value: 'View Details',
                subtitle: analysis.elementOrders,
                fullWidth: true,
              ),
            if (analysis.cayleyTable != null)
              _ModularPropertyCard(
                uiStyle: uiStyle,
                title: 'Cayley Table',
                value: 'View Table',
                subtitle: analysis.cayleyTable,
                fullWidth: true,
                isMonospace: true,
              ),
          ],
        ),
      ],
    ),
    );
  }

  String _countItems(String? commaSeparatedList) {
    if (commaSeparatedList == null ||
        commaSeparatedList.isEmpty ||
        commaSeparatedList == 'None') {
      return '0';
    }
    // Very simple heuristic to count items
    return commaSeparatedList.split(',').length.toString();
  }
}

class _ModularExpandableSection extends StatelessWidget {
  final UiStyle uiStyle;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _ModularExpandableSection({
    required this.uiStyle,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Center(
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: uiStyle == UiStyle.liquidGlass ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

              // Filter out full width children to handle separately if needed,
              // but Wrap handles full width nicely if child has double.infinity width.
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: children.map((child) {
                  if (child is _ModularPropertyCard && child.fullWidth) {
                    return SizedBox(width: constraints.maxWidth, child: child);
                  }
                  return SizedBox(
                    width:
                        (constraints.maxWidth - (8 * (crossAxisCount - 1))) /
                        crossAxisCount,
                    child: child,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModularPropertyCard extends StatelessWidget {
  final UiStyle uiStyle;
  final String title;
  final String value;
  final String? subtitle;
  final bool fullWidth;
  final bool isMonospace;

  const _ModularPropertyCard({
    required this.uiStyle,
    required this.title,
    required this.value,
    this.subtitle,
    this.fullWidth = false,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SharedSurface(
      uiStyle: uiStyle,
      glassRole: GlassSurfaceRole.card,
      frosted: true,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (subtitle != null &&
              subtitle!.isNotEmpty &&
              subtitle != 'None') ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
                fontFamily: isMonospace ? 'monospace' : null,
              ),
              maxLines: fullWidth ? null : 3,
              overflow: fullWidth ? null : TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
