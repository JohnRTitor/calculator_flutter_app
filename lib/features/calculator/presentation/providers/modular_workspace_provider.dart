import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/providers/modular_workspace_state.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/modular_math.dart' as rust;
import 'package:calculator_flutter_app/features/history/presentation/providers/history_provider.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/settings_provider.dart';

part 'modular_workspace_provider.g.dart';

@riverpod
class ModularWorkspace extends _$ModularWorkspace {
  @override
  ModularWorkspaceState build() {
    return const ModularWorkspaceState();
  }

  void updateExpression(String expr) {
    state = state.copyWith(
      expression: expr,
      clearError: true,
    );
    _updatePreview();
  }

  void updateModulus(String modulus) {
    state = state.copyWith(
      modulus: modulus,
      clearError: true,
    );
    _updatePreview();
  }

  void setMode(ModularMode mode) {
    state = state.copyWith(mode: mode, clearError: true);
    _updatePreview();
  }

  void append(String text) {
    if (state.showResult) {
      state = state.copyWith(
        expression: text,
        showResult: false,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        expression: state.expression + text,
        clearError: true,
      );
    }
    _updatePreview();
  }

  void delete() {
    if (state.showResult) {
      state = state.copyWith(
        expression: '',
        showResult: false,
        preview: '',
        clearError: true,
      );
    } else if (state.expression.isNotEmpty) {
      state = state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
        clearError: true,
      );
      _updatePreview();
    }
  }

  void clear() {
    state = const ModularWorkspaceState();
  }

  void _updatePreview() {
    if (state.expression.trim().isEmpty) {
      state = state.copyWith(preview: '');
      return;
    }

    try {
      final res = rust.modularEvaluate(
        expression: state.expression,
        contextModulus: state.modulus.isEmpty ? null : state.modulus,
        mode: state.mode.name,
        showSteps: false, // Don't compute steps for preview
      );
      state = state.copyWith(preview: res.value);
    } catch (e) {
      state = state.copyWith(preview: '');
    }
  }

  void evaluate() {
    if (state.expression.trim().isEmpty) return;

    try {
      final showSteps = ref.read(educationalModeProvider);
      
      final res = rust.modularEvaluate(
        expression: state.expression,
        contextModulus: state.modulus.isEmpty ? null : state.modulus,
        mode: state.mode.name,
        showSteps: showSteps,
      );
      
      final historyExpr = _formatHistoryExpression();
      
      rust.modularHistoryAdd(
        expression: historyExpr,
        result: res.value,
      );
      
      ref.invalidate(historyProvider);

      state = state.copyWith(
        result: res.value,
        details: res.details,
        modulusUsed: res.modulusUsed,
        steps: res.steps,
        showResult: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('AnyhowException(', '').replaceAll(')', ''),
      );
    }
  }

  String _formatHistoryExpression() {
    if (state.modulus.isNotEmpty) {
      return '${state.expression} (mod ${state.modulus})';
    }
    return state.expression;
  }

  void setExplorerN(String n) {
    state = state.copyWith(explorerN: n, clearExplorerError: true);
  }

  void setExplorerType(String type) {
    state = state.copyWith(explorerType: type, clearExplorerError: true);
  }

  void analyzeStructure() {
    if (state.explorerN.trim().isEmpty) return;
    
    try {
      final res = rust.analyzeStructure(
        structureType: state.explorerType,
        n: state.explorerN,
      );
      
      // Also add to rich history
      rust.modularHistoryAdd(
        expression: 'analyze(Z_${state.explorerN}${state.explorerType == "group" ? "*" : ""})',
        result: res.classification,
      );
      ref.invalidate(historyProvider);
      
      state = state.copyWith(
        explorerResult: res,
        clearExplorerError: true,
      );
    } catch (e) {
      state = state.copyWith(
        explorerError: e.toString().replaceAll('AnyhowException(', '').replaceAll(')', ''),
      );
    }
  }
}
