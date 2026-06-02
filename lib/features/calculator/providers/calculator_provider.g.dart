// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Calculator)
const calculatorProvider = CalculatorProvider._();

final class CalculatorProvider
    extends $NotifierProvider<Calculator, CalculatorState> {
  const CalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calculatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calculatorHash();

  @$internal
  @override
  Calculator create() => Calculator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalculatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalculatorState>(value),
    );
  }
}

String _$calculatorHash() => r'549566ee1dd01c51a662959f8f255cf947a9dc25';

abstract class _$Calculator extends $Notifier<CalculatorState> {
  CalculatorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CalculatorState, CalculatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalculatorState, CalculatorState>,
              CalculatorState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
