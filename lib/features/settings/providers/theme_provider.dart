import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';

part 'theme_provider.g.dart';

enum AppThemeMode { light, dark, amoled, system }

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  AppThemeMode build() {
    _load();
    return AppThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('theme_mode') ?? 3;
    state = AppThemeMode.values[idx];
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

@riverpod
class UiStyleNotifier extends _$UiStyleNotifier {
  @override
  UiStyle build() {
    _load();
    return UiStyle.materialYou;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('ui_style') ?? 0;
    if (idx >= 0 && idx < UiStyle.values.length) {
      state = UiStyle.values[idx];
    }
  }

  Future<void> setUiStyle(UiStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ui_style', style.index);
  }
}
