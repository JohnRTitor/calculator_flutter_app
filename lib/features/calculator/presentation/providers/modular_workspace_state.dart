enum ModularMode { ring, field, crt }

class ModularWorkspaceState {
  final String expression;
  final String modulus;
  final ModularMode mode;
  final String preview;
  final String result;
  final String? details;
  final String? modulusUsed;
  final bool showResult;
  final String? error;

  const ModularWorkspaceState({
    this.expression = '',
    this.modulus = '',
    this.mode = ModularMode.ring,
    this.preview = '',
    this.result = '',
    this.details,
    this.modulusUsed,
    this.showResult = false,
    this.error,
  });

  ModularWorkspaceState copyWith({
    String? expression,
    String? modulus,
    ModularMode? mode,
    String? preview,
    String? result,
    String? details,
    bool clearDetails = false,
    String? modulusUsed,
    bool clearModulusUsed = false,
    bool? showResult,
    String? error,
    bool clearError = false,
  }) {
    return ModularWorkspaceState(
      expression: expression ?? this.expression,
      modulus: modulus ?? this.modulus,
      mode: mode ?? this.mode,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      details: clearDetails ? null : (details ?? this.details),
      modulusUsed: clearModulusUsed ? null : (modulusUsed ?? this.modulusUsed),
      showResult: showResult ?? this.showResult,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
