import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:calculator_flutter_app/core/theme/app_theme.dart';

import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';
import 'package:calculator_flutter_app/features/home/presentation/screens/main_screen.dart';

class CalculatorApp extends ConsumerWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider); 
    
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
        return MaterialApp(
          title: 'Calculator',
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: themeMode == AppThemeMode.amoled 
            ? AppTheme.amoledTheme(darkDynamic) 
            : AppTheme.darkTheme(darkDynamic), 
          themeMode: flutterThemeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
