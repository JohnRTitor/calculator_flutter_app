import 'package:calculator_flutter_app/generated/rust/bridge/modular_math.dart';

enum ModularMode { ring, field, crt }

class ModularWorkspaceState {
  final String expression;
  final String modulus;
  final ModularMode mode;
  final String preview;
  final String result;
  final String? details;
  final String? modulusUsed;
  final String? steps;
  final bool showResult;
  final String? error;

  // Structure Explorer Fields
  final String explorerN;
  final String explorerType; // 'ring', 'group', 'field'
  final StructureAnalysis? explorerResult;
  final String? explorerError;

  const ModularWorkspaceState({
    this.expression = '',
    this.modulus = '',
    this.mode = ModularMode.ring,
    this.preview = '',
    this.result = '',
    this.details,
    this.modulusUsed,
    this.steps,
    this.showResult = false,
    this.error,
    this.explorerN = '',
    this.explorerType = 'ring',
    this.explorerResult,
    this.explorerError,
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
    String? steps,
    bool clearSteps = false,
    bool? showResult,
    String? error,
    bool clearError = false,
    String? explorerN,
    String? explorerType,
    StructureAnalysis? explorerResult,
    bool clearExplorerResult = false,
    String? explorerError,
    bool clearExplorerError = false,
  }) {
    return ModularWorkspaceState(
      expression: expression ?? this.expression,
      modulus: modulus ?? this.modulus,
      mode: mode ?? this.mode,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      details: clearDetails ? null : (details ?? this.details),
      modulusUsed: clearModulusUsed ? null : (modulusUsed ?? this.modulusUsed),
      steps: clearSteps ? null : (steps ?? this.steps),
      showResult: showResult ?? this.showResult,
      error: clearError ? null : (error ?? this.error),
      explorerN: explorerN ?? this.explorerN,
      explorerType: explorerType ?? this.explorerType,
      explorerResult: clearExplorerResult ? null : (explorerResult ?? this.explorerResult),
      explorerError: clearExplorerError ? null : (explorerError ?? this.explorerError),
    );
  }
}
