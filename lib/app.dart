import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:calculator_flutter_app/core/theme/app_theme.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';

import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';
import 'package:calculator_flutter_app/features/home/presentation/screens/main_screen.dart';
import 'package:calculator_flutter_app/core/theme/glass_utils.dart';

class CalculatorApp extends ConsumerWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final uiStyle = ref.watch(uiStyleProvider);
    final colorOption = ref.watch(appColorProvider);

    ThemeMode flutterThemeMode;
    switch (themeMode) {
      case AppThemeMode.light:
        flutterThemeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        flutterThemeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        flutterThemeMode = ThemeMode.system;
        break;
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightTheme = AppTheme.lightTheme(lightDynamic, uiStyle, colorOption);
        final darkTheme = themeMode == AppThemeMode.amoled
            ? AppTheme.amoledTheme(darkDynamic, uiStyle, colorOption)
            : AppTheme.darkTheme(darkDynamic, uiStyle, colorOption);

        final materialApp = MaterialApp(
          title: 'Calculator',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: flutterThemeMode,
          home: const MainScreen(),
          builder: (context, child) {
            if (uiStyle == UiStyle.liquidGlass) {
              // Resolve active theme manually because Theme.of(context) in builder
              // can return the default fallback dark theme.
              final isDark =
                  flutterThemeMode == ThemeMode.dark ||
                  (flutterThemeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);

              final activeTheme = isDark ? darkTheme : lightTheme;

              // Global stable background rendered once behind the navigator.
              // Every screen has transparent scaffold, so this shows through.
              return Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: SharedGlassBackground(
                        themeMode: themeMode,
                        brightness: activeTheme.brightness,
                        colorScheme: activeTheme.colorScheme,
                      ),
                    ),
                  ),
                  child ?? const SizedBox.shrink(),
                ],
              );
            }
            return child!;
          },
        );

        return materialApp;
      },
    );
  }
}
