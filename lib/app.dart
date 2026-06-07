import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:calculator_flutter_app/core/theme/app_theme.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';

import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';
import 'package:calculator_flutter_app/features/home/presentation/screens/main_screen.dart';

class CalculatorApp extends ConsumerWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider); 
    final uiStyle = ref.watch(uiStyleProvider);
    
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
        final materialApp = MaterialApp(
          title: 'Calculator',
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: themeMode == AppThemeMode.amoled 
            ? AppTheme.amoledTheme(darkDynamic) 
            : AppTheme.darkTheme(darkDynamic), 
          themeMode: flutterThemeMode,
          home: const MainScreen(),
        );

        // Conditionally wrap with LiquidGlassWidgets for glass mode
        if (uiStyle == UiStyle.liquidGlass) {
          return LiquidGlassWidgets.wrap(
            adaptiveQuality: true,
            theme: GlassThemeData(
              light: GlassThemeVariant(
                settings: GlassThemeSettings(thickness: 30, blur: 8),
                quality: GlassQuality.standard,
              ),
              dark: GlassThemeVariant(
                settings: GlassThemeSettings(thickness: 35, blur: 10),
                quality: GlassQuality.standard,
              ),
            ),
            child: materialApp,
          );
        }

        return materialApp;
      },
    );
  }
}
