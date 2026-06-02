class CalculatorState {
  final String expression;
  final String preview;
  final String result;
  final bool isScientificMode;
  final bool showResult;
  final bool hasMemory;
  final String? error;

  const CalculatorState({
    this.expression = '',
    this.preview = '',
    this.result = '',
    this.isScientificMode = false,
    this.showResult = false,
    this.hasMemory = false,
    this.error,
  });

  CalculatorState copyWith({
    String? expression,
    String? preview,
    String? result,
    bool? isScientificMode,
    bool? showResult,
    bool? hasMemory,
    String? error,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      isScientificMode: isScientificMode ?? this.isScientificMode,
      showResult: showResult ?? this.showResult,
      hasMemory: hasMemory ?? this.hasMemory,
      error: error ?? this.error,
    );
  }
}
