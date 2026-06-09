// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_evaluator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FunctionEvaluator)
final functionEvaluatorProvider = FunctionEvaluatorProvider._();

final class FunctionEvaluatorProvider
    extends $NotifierProvider<FunctionEvaluator, FunctionEvaluatorState> {
  FunctionEvaluatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'functionEvaluatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$functionEvaluatorHash();

  @$internal
  @override
  FunctionEvaluator create() => FunctionEvaluator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FunctionEvaluatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FunctionEvaluatorState>(value),
    );
  }
}

String _$functionEvaluatorHash() => r'5977889ee30d680b94e7394707d9393dead7cb6e';

abstract class _$FunctionEvaluator extends $Notifier<FunctionEvaluatorState> {
  FunctionEvaluatorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<FunctionEvaluatorState, FunctionEvaluatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FunctionEvaluatorState, FunctionEvaluatorState>,
              FunctionEvaluatorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
