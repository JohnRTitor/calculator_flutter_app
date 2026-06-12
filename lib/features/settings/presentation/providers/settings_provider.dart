import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

/// A Riverpod Notifier that manages and persists the Educational Mode setting.
@riverpod
class EducationalModeNotifier extends _$EducationalModeNotifier {
  @override
  bool build() {
    _load();
    return false; // Default to false
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('educational_mode') ?? false;
    state = isEnabled;
  }

  /// Updates the educational mode setting and persists it to SharedPreferences.
  Future<void> setEducationalMode(bool isEnabled) async {
    state = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('educational_mode', isEnabled);
  }
  
  /// Toggles the educational mode.
  Future<void> toggle() async {
    await setEducationalMode(!state);
  }
}
