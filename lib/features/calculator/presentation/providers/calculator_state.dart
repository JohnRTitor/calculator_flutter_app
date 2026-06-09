/// Represents the currently expanded secondary panel in the calculator keypad.
enum ExpandedPanel { none, trig, log, memory }

/// Holds the complete state of the calculator, including the expression,
/// modes, and calculation results.
class CalculatorState {
  /// The list of tokens forming the current mathematical expression.
  final List<String> tokens;

  /// The current index of the cursor within the tokens list.
  final int cursorIndex;

  /// A real-time preview of the calculation result.
  final String preview;

  /// The final computed result to be displayed.
  final String result;

  /// Whether the calculator is currently in scientific mode.
  final bool isScientificMode;

  /// Which secondary panel (e.g., trig, log, memory) is currently expanded.
  final ExpandedPanel expandedPanel;

  /// Whether trigonometric functions should use degrees (true) or radians (false).
  final bool isDegreeMode;

  /// Whether the inverse mode for trigonometric functions is active.
  final bool isInvMode;

  /// Whether the hyperbolic mode for trigonometric functions is active.
  final bool isHypMode;

  /// The value stored from the previous answer (`Ans` token).
  final double ansValue;

  /// Whether the UI should highlight the final result instead of the expression.
  final bool showResult;

  /// Indicates if there is a value currently stored in memory.
  final bool hasMemory;

  /// Holds an error message if the calculation failed.
  final String? error;

  /// An optional exact string representation of the result (e.g., "1/3", "2π").
  final String? exactResult;

  /// Whether the user prefers the exact fractional representation over decimals.
  final bool displayAsFraction;

  /// Whether the calculator is currently in Function Mode.
  // Removed isFuncMode, funcExpression, variables, detectedVariables

  /// Returns true if the memory panel is currently expanded.
  bool get isMemoryMode => expandedPanel == ExpandedPanel.memory;

  String get expression => tokens.join('');

  const CalculatorState({
    this.tokens = const [],
    this.cursorIndex = 0,
    this.preview = '',
    this.result = '',
    this.isScientificMode = false,
    this.expandedPanel = ExpandedPanel.none,
    this.isDegreeMode = true,
    this.isInvMode = false,
    this.isHypMode = false,
    this.ansValue = 0.0,
    this.showResult = false,
    this.hasMemory = false,
    this.error,
    this.exactResult,
    this.displayAsFraction = true,
  });

  CalculatorState copyWith({
    List<String>? tokens,
    int? cursorIndex,
    String? preview,
    String? result,
    bool? isScientificMode,
    ExpandedPanel? expandedPanel,
    bool? isDegreeMode,
    bool? isInvMode,
    bool? isHypMode,
    double? ansValue,
    bool? showResult,
    bool? hasMemory,
    String? error,
    bool clearError = false,
    String? exactResult,
    bool? displayAsFraction,
    bool clearExactResult = false,
  }) {
    return CalculatorState(
      tokens: tokens ?? this.tokens,
      cursorIndex: cursorIndex ?? this.cursorIndex,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      isScientificMode: isScientificMode ?? this.isScientificMode,
      expandedPanel: expandedPanel ?? this.expandedPanel,
      isDegreeMode: isDegreeMode ?? this.isDegreeMode,
      isInvMode: isInvMode ?? this.isInvMode,
      isHypMode: isHypMode ?? this.isHypMode,
      ansValue: ansValue ?? this.ansValue,
      showResult: showResult ?? this.showResult,
      hasMemory: hasMemory ?? this.hasMemory,
      error: clearError ? null : (error ?? this.error),
      exactResult: clearExactResult ? null : (exactResult ?? this.exactResult),
      displayAsFraction: displayAsFraction ?? this.displayAsFraction,
    );
  }
}
