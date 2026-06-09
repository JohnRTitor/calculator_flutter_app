import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';

class AppDropdownMenuEntry {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const AppDropdownMenuEntry({
    required this.label,
    required this.onPressed,
    this.icon,
  });
}

class AppDropdownMenu extends StatelessWidget {
  final IconData icon;
  final UiStyle uiStyle;
  final List<AppDropdownMenuEntry> entries;
  final String? tooltip;

  const AppDropdownMenu({
    super.key,
    required this.icon,
    required this.uiStyle,
    required this.entries,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isGlass = uiStyle == UiStyle.liquidGlass;

    final glassCard = resolveGlassStyle(
      colorScheme,
      brightness: theme.brightness,
      role: GlassSurfaceRole.card,
    );

    List<Widget> buildMenuItems() {
      return entries.map((entry) {
        return MenuItemButton(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            minimumSize: WidgetStatePropertyAll(Size(180, 48)),
          ),
          onPressed: entry.onPressed,
          leadingIcon: entry.icon != null ? Icon(entry.icon, size: 20) : null,
          child: Text(
            entry.label,
            style: isGlass ? TextStyle(color: colorScheme.onSurface) : null,
          ),
        );
      }).toList();
    }

    if (isGlass) {
      return SharedSurface(
        uiStyle: uiStyle,
        glassRole: GlassSurfaceRole.button,
        frosted: true,
        borderRadius: BorderRadius.circular(24),
        child: MenuAnchor(
          style: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            elevation: WidgetStatePropertyAll(0),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
          ),
          builder: (context, controller, child) {
            return IconButton(
              tooltip: tooltip,
              icon: Icon(
                icon,
                size: 22,
                color: glassCard.foregroundColor,
              ),
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
          menuChildren: [
            SharedSurface(
              uiStyle: uiStyle,
              glassRole: GlassSurfaceRole.panel,
              frosted: true,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildMenuItems(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
      ),
      builder: (context, controller, child) {
        return IconButton(
          tooltip: tooltip,
          icon: Icon(
            icon,
            size: 22,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: buildMenuItems(),
    );
  }
}
