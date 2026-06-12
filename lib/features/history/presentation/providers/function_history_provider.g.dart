// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FunctionHistory)
final functionHistoryProvider = FunctionHistoryProvider._();

final class FunctionHistoryProvider
    extends $AsyncNotifierProvider<FunctionHistory, List<HistoryEntry>> {
  FunctionHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'functionHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$functionHistoryHash();

  @$internal
  @override
  FunctionHistory create() => FunctionHistory();
}

String _$functionHistoryHash() => r'4076850c7bc02fde5ae991f86817277f178738e5';

abstract class _$FunctionHistory extends $AsyncNotifier<List<HistoryEntry>> {
  FutureOr<List<HistoryEntry>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<HistoryEntry>>, List<HistoryEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<HistoryEntry>>, List<HistoryEntry>>,
              AsyncValue<List<HistoryEntry>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
