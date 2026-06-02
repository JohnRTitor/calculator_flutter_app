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
      state = state.copyWith(expression: state.result + text, showResult: false, error: null, preview: '');
    } else {
      state = state.copyWith(expression: state.expression + text, error: null);
    }
    _updatePreview();
  }

  void delete() {
    if (state.showResult) {
      state = state.copyWith(showResult: false, error: null, preview: '');
      return;
    }
    if (state.expression.isNotEmpty) {
      state = state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
        error: null,
      );
      _updatePreview();
    }
  }

  void clear() {
    state = CalculatorState(isScientificMode: state.isScientificMode, hasMemory: state.hasMemory);
  }

  void toggleScientificMode() {
    state = state.copyWith(isScientificMode: !state.isScientificMode);
  }

  void _updatePreview() {
    if (state.expression.isEmpty) {
      state = state.copyWith(preview: '');
      return;
    }
    try {
      final res = rust.evaluate(expression: state.expression);
      state = state.copyWith(preview: res.formatted, error: null);
    } catch (e) {
      state = state.copyWith(preview: '', error: e.toString());
    }
  }

  Future<void> evaluate() async {
    if (state.expression.isEmpty) return;
    try {
      final res = rust.evaluate(expression: state.expression);
      state = state.copyWith(result: res.formatted, showResult: true, error: null);
      
      // Save history
      rust.historyAdd(expression: state.expression, result: res.formatted);
      // Wait to get valid path and save
      final historyNotifier = ref.read(historyProvider.notifier);
      await historyNotifier.saveHistoryToFile();
      historyNotifier.refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  // Memory Operations
  void memoryStore() {
    if (state.showResult && state.result.isNotEmpty) {
      final val = double.tryParse(state.result);
      if (val != null) {
        rust.memoryStore(value: val);
        state = state.copyWith(hasMemory: true);
      }
    }
  }
  
  void memoryRecall() {
    final val = rust.memoryRecall();
    if (val != null) {
      append(rust.formatResult(value: val, maxPrecision: 10));
    }
  }
  
  void memoryAdd() {
    if (state.showResult && state.result.isNotEmpty) {
      final val = double.tryParse(state.result);
      if (val != null) {
        rust.memoryAdd(value: val);
        state = state.copyWith(hasMemory: true);
      }
    }
  }
  
  void memorySubtract() {
    if (state.showResult && state.result.isNotEmpty) {
      final val = double.tryParse(state.result);
      if (val != null) {
        rust.memorySubtract(value: val);
        state = state.copyWith(hasMemory: true);
      }
    }
  }
  
  void memoryClear() {
    rust.memoryClear();
    state = state.copyWith(hasMemory: false);
  }
}
