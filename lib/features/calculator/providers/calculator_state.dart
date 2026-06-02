class CalculatorState {
  final String expression;
  final String preview;
  final String result;
  final bool isScientificMode;
  final bool isMemoryMode;
  final bool showResult;
  final bool hasMemory;
  final String? error;

  const CalculatorState({
    this.expression = '',
    this.preview = '',
    this.result = '',
    this.isScientificMode = false,
    this.isMemoryMode = false,
    this.showResult = false,
    this.hasMemory = false,
    this.error,
  });

  CalculatorState copyWith({
    String? expression,
    String? preview,
    String? result,
    bool? isScientificMode,
    bool? isMemoryMode,
    bool? showResult,
    bool? hasMemory,
    String? error,
    bool clearError = false,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      isScientificMode: isScientificMode ?? this.isScientificMode,
      isMemoryMode: isMemoryMode ?? this.isMemoryMode,
      showResult: showResult ?? this.showResult,
      hasMemory: hasMemory ?? this.hasMemory,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
