import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_state.dart';
import 'package:calculator_flutter_app/src/rust/api/calculator.dart' as rust;
import 'package:calculator_flutter_app/features/history/providers/history_provider.dart';

part 'calculator_provider.g.dart';

@riverpod
class Calculator extends _$Calculator {
  @override
  CalculatorState build() {
    _initMemoryState();
    return const CalculatorState();
  }

  Future<void> _initMemoryState() async {
    final mem = rust.memoryRecall();
    if (mem != null) {
      state = state.copyWith(hasMemory: true);
    }
  }

  void append(String text) {
    if (state.showResult) {
      state = state.copyWith(tokens: [text], cursorIndex: 1, showResult: false, clearError: true, preview: '');
    } else {
      final newTokens = List<String>.from(state.tokens);
      newTokens.insert(state.cursorIndex, text);
      state = state.copyWith(tokens: newTokens, cursorIndex: state.cursorIndex + 1, clearError: true);
    }
    _updatePreview();
  }

  void delete() {
    if (state.showResult) {
      state = state.copyWith(showResult: false, clearError: true, preview: '');
      return;
    }
    if (state.tokens.isNotEmpty && state.cursorIndex > 0) {
      final newTokens = List<String>.from(state.tokens);
      newTokens.removeAt(state.cursorIndex - 1);
      state = state.copyWith(
        tokens: newTokens,
        cursorIndex: state.cursorIndex - 1,
        clearError: true,
      );
      _updatePreview();
    }
  }

  void setCursor(int index) {
    if (index >= 0 && index <= state.tokens.length) {
      state = state.copyWith(cursorIndex: index);
    }
  }

  void clear() {
    state = CalculatorState(isScientificMode: state.isScientificMode, isMemoryMode: state.isMemoryMode, hasMemory: state.hasMemory);
  }

  void toggleScientificMode() {
    state = state.copyWith(isScientificMode: !state.isScientificMode);
  }

  void toggleMemoryMode() {
    state = state.copyWith(isMemoryMode: !state.isMemoryMode);
  }

  void toggleDegreeMode() {
    state = state.copyWith(isDegreeMode: !state.isDegreeMode);
  }

  void toggleInvMode() {
    state = state.copyWith(isInvMode: !state.isInvMode);
  }

  void toggleHypMode() {
    state = state.copyWith(isHypMode: !state.isHypMode);
  }

  void _updatePreview() {
    if (state.expression.isEmpty) {
      state = state.copyWith(preview: '');
      return;
    }
    try {
      final res = rust.evaluate(expression: state.expression, isDegree: state.isDegreeMode, ansValue: state.ansValue);
      state = state.copyWith(preview: res.formatted, clearError: true);
    } catch (e) {
      state = state.copyWith(preview: '', clearError: true);
    }
  }

  Future<bool> evaluate() async {
    if (state.expression.isEmpty) return false;
    try {
      final res = rust.evaluate(expression: state.expression, isDegree: state.isDegreeMode, ansValue: state.ansValue);
      state = state.copyWith(result: res.formatted, showResult: true, clearError: true, ansValue: res.value);
      
      // Save history
      rust.historyAdd(expression: state.expression, result: res.formatted);
      // Wait to get valid path and save
      final historyNotifier = ref.read(historyProvider.notifier);
      await historyNotifier.saveHistoryToFile();
      historyNotifier.refresh();
      return true;
    } catch (e) {
      final cleanError = e.toString().replaceAll('AnyhowException(', '').replaceAll(RegExp(r'\)$'), '');
      state = state.copyWith(error: cleanError);
      return false;
    }
  }
  
  double? _getCurrentValue() {
    if (state.expression.isEmpty) return null;
    try {
      return rust.evaluate(expression: state.expression, isDegree: state.isDegreeMode, ansValue: state.ansValue).value;
    } catch (_) {
      return null;
    }
  }

  // Memory Operations
  bool memoryStore() {
    final val = _getCurrentValue();
    if (val != null) {
      rust.memoryStore(value: val);
      state = state.copyWith(hasMemory: true);
      return true;
    }
    return false;
  }
  
  bool memoryRecall() {
    final val = rust.memoryRecall();
    if (val != null) {
      append(rust.formatResult(value: val, maxPrecision: 10));
      return true;
    }
    return false;
  }
  
  bool memoryAdd() {
    final val = _getCurrentValue();
    if (val != null) {
      rust.memoryAdd(value: val);
      state = state.copyWith(hasMemory: true);
      return true;
    }
    return false;
  }
  
  bool memorySubtract() {
    final val = _getCurrentValue();
    if (val != null) {
      rust.memorySubtract(value: val);
      state = state.copyWith(hasMemory: true);
      return true;
    }
    return false;
  }
  
  void memoryClear() {
    rust.memoryClear();
    state = state.copyWith(hasMemory: false);
  }
}
