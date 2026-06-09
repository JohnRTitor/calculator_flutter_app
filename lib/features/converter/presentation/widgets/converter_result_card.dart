import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/glass_utils.dart';
import '../../../../app/theme/ui_style.dart';
import '../providers/converter_provider.dart';

class ConverterResultCard extends StatelessWidget {
  final ConverterResultData data;
  final UiStyle uiStyle;
  final ColorScheme colorScheme;
  final bool isActive;
  final VoidCallback? onTap;

  const ConverterResultCard({
    super.key,
    required this.data,
    required this.uiStyle,
    required this.colorScheme,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurfaceVariant;

    Widget slideFadeTransition(Widget child, Animation<double> animation) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.4),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: onTap,
        child: SharedSurface(
          uiStyle: uiStyle,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          glassRole: isActive ? GlassSurfaceRole.primary : GlassSurfaceRole.card,
          materialColor: isActive ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.title.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: secondaryTextColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18, color: secondaryTextColor),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data.primaryValue));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Copied to clipboard'),
                          backgroundColor: colorScheme.inverseSurface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    tooltip: 'Copy result',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: slideFadeTransition,
                child: Container(
                  key: ValueKey<String>('${data.primaryValue}_$isActive'),
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isActive ? '${data.primaryValue}|' : data.primaryValue,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 56, // Match 48-64sp typography
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
              if (data.secondaryText.isNotEmpty) ...[
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: slideFadeTransition,
                  child: Container(
                    key: ValueKey<String>(data.secondaryText),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.secondaryText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: secondaryTextColor,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
