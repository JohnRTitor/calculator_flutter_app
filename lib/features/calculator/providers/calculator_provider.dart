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

  bool append(String text) {
    if (!_isValidAppend(text)) return false;

    if (state.showResult) {
      state = state.copyWith(tokens: [text], cursorIndex: 1, showResult: false, clearError: true, preview: '', clearExactResult: true);
    } else {
      final newTokens = List<String>.from(state.tokens);
      newTokens.insert(state.cursorIndex, text);
      state = state.copyWith(tokens: newTokens, cursorIndex: state.cursorIndex + 1, clearError: true, clearExactResult: true);
    }
    _updatePreview();
    return true;
  }

  bool _isValidAppend(String text) {
    final tokens = state.showResult ? <String>[] : state.tokens;
    final cursorIndex = state.showResult ? 0 : state.cursorIndex;

    final isOperator = ['+', '−', '×', '÷', '%', 'mod', '^', '/'].contains(text);
    final isMinus = text == '−';

    if (isOperator || text == '!') {
      if (cursorIndex == 0) {
        if (!isMinus) return false;
      }
    }

    String? prevToken;
    if (cursorIndex > 0 && tokens.isNotEmpty) {
      prevToken = tokens[cursorIndex - 1];
    }

    String? nextToken;
    if (cursorIndex < tokens.length) {
      nextToken = tokens[cursorIndex];
    }

    if (isOperator) {
      if (prevToken != null) {
        final isPrevOperator = ['+', '−', '×', '÷', '%', 'mod', '^', '/'].contains(prevToken);
        final isPrevOpenParen = prevToken.endsWith('(');

        if (isPrevOpenParen) {
          if (!isMinus) return false;
        }

        if (isPrevOperator) {
          if (!isMinus) return false;
          // Prevent multiple minus like 8 --- 4
          if (isMinus && prevToken == '−') {
            if (cursorIndex > 1) {
              final prevPrevToken = tokens[cursorIndex - 2];
              if (['+', '−', '×', '÷', '%', 'mod', '^', '/'].contains(prevPrevToken)) {
                return false;
              }
            }
          }
        }
      }

      if (nextToken != null && nextToken == ')') {
        return false;
      }
    }

    if (text == '.') {
      int dots = 0;
      for (int i = cursorIndex - 1; i >= 0; i--) {
        final t = tokens[i];
        if (t == '.') {
          dots++;
        } else if (RegExp(r'^[0-9]+$').hasMatch(t)) {
          continue;
        } else {
          break;
        }
      }
      for (int i = cursorIndex; i < tokens.length; i++) {
        final t = tokens[i];
        if (t == '.') {
          dots++;
        } else if (RegExp(r'^[0-9]+$').hasMatch(t)) {
          continue;
        } else {
          break;
        }
      }
      if (dots > 0) return false;
    }

    if (text == ')') {
      int open = 0;
      int close = 0;
      for (int i = 0; i < cursorIndex; i++) {
        if (tokens[i].endsWith('(')) open++;
        if (tokens[i] == ')') close++;
      }
      if (close >= open) return false;

      if (prevToken != null && prevToken.endsWith('(')) {
        return false;
      }

      if (prevToken != null && ['+', '−', '×', '÷', '%', 'mod', '^', '/'].contains(prevToken)) {
        return false;
      }
    }

    return true;
  }

  void delete() {
    if (state.showResult) {
      state = state.copyWith(showResult: false, clearError: true, preview: '', clearExactResult: true);
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
    state = CalculatorState(isScientificMode: state.isScientificMode, expandedPanel: state.expandedPanel, hasMemory: state.hasMemory);
  }

  void toggleScientificMode() {
    if (state.isScientificMode) {
      // Collapse any open panel when turning off scientific mode
      state = state.copyWith(isScientificMode: false, expandedPanel: ExpandedPanel.none);
    } else {
      state = state.copyWith(isScientificMode: true);
    }
  }

  void togglePanel(ExpandedPanel panel) {
    if (state.expandedPanel == panel) {
      state = state.copyWith(expandedPanel: ExpandedPanel.none);
    } else {
      state = state.copyWith(expandedPanel: panel);
    }
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
    if (state.showResult) {
      if (state.exactResult != null) {
        toggleDisplayFormat();
        return true;
      }
      return false;
    }

    if (state.expression.isEmpty) return false;
    
    final lastToken = state.tokens.last;
    if (['+', '−', '×', '÷', '%', 'mod', '^', '/'].contains(lastToken)) {
      return false;
    }
    
    try {
      final res = rust.evaluate(expression: state.expression, isDegree: state.isDegreeMode, ansValue: state.ansValue);
      state = state.copyWith(
        result: res.formatted, 
        showResult: true, 
        clearError: true, 
        ansValue: res.value,
        exactResult: res.exactFraction,
        displayAsFraction: res.exactFraction != null,
      );
      
      // Save history
      final newResult = res.exactFraction ?? res.formatted;
      final history = rust.historyGetAll();
      if (history.isEmpty || history.last.expression != state.expression || history.last.result != newResult) {
        rust.historyAdd(expression: state.expression, result: newResult);
        // Wait to get valid path and save
        final historyNotifier = ref.read(historyProvider.notifier);
        await historyNotifier.saveHistoryToFile();
        historyNotifier.refresh();
      }
      return true;
    } catch (e) {
      final cleanError = e.toString().replaceAll('AnyhowException(', '').replaceAll(RegExp(r'\)$'), '');
      state = state.copyWith(error: cleanError);
      return false;
    }
  }

  void toggleDisplayFormat() {
    if (state.exactResult != null) {
      state = state.copyWith(displayAsFraction: !state.displayAsFraction);
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
