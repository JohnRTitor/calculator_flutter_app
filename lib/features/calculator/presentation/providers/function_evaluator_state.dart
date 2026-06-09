class FunctionEvaluatorState {
  final String funcExpression;
  final String preview;
  final String result;
  final Map<String, double> variables;
  final List<String> detectedVariables;
  final bool showResult;
  final String? exactResult;
  final String? error;
  final bool isDegreeMode;
  final double ansValue;
  final bool displayAsFraction;

  String get evaluatedExpression {
    if (funcExpression.contains('=')) {
      final parts = funcExpression.split('=');
      if (parts.length > 1) {
        return parts.sublist(1).join('=').trim();
      }
    }
    return funcExpression;
  }

  const FunctionEvaluatorState({
    this.funcExpression = '',
    this.preview = '',
    this.result = '',
    this.variables = const {},
    this.detectedVariables = const [],
    this.showResult = false,
    this.exactResult,
    this.error,
    this.isDegreeMode = true,
    this.ansValue = 0.0,
    this.displayAsFraction = true,
  });

  FunctionEvaluatorState copyWith({
    String? funcExpression,
    String? preview,
    String? result,
    Map<String, double>? variables,
    List<String>? detectedVariables,
    bool? showResult,
    String? exactResult,
    bool clearExactResult = false,
    String? error,
    bool clearError = false,
    bool? isDegreeMode,
    double? ansValue,
    bool? displayAsFraction,
  }) {
    return FunctionEvaluatorState(
      funcExpression: funcExpression ?? this.funcExpression,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      variables: variables ?? this.variables,
      detectedVariables: detectedVariables ?? this.detectedVariables,
      showResult: showResult ?? this.showResult,
      exactResult: clearExactResult ? null : (exactResult ?? this.exactResult),
      error: clearError ? null : (error ?? this.error),
      isDegreeMode: isDegreeMode ?? this.isDegreeMode,
      ansValue: ansValue ?? this.ansValue,
      displayAsFraction: displayAsFraction ?? this.displayAsFraction,
    );
  }
}
