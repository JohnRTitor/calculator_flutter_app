// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A Riverpod Notifier that manages the history of calculations.
///
/// Interacts with the Rust backend to load, save, clear, and delete history entries.

@ProviderFor(History)
final historyProvider = HistoryProvider._();

/// A Riverpod Notifier that manages the history of calculations.
///
/// Interacts with the Rust backend to load, save, clear, and delete history entries.
final class HistoryProvider
    extends $AsyncNotifierProvider<History, List<HistoryEntry>> {
  /// A Riverpod Notifier that manages the history of calculations.
  ///
  /// Interacts with the Rust backend to load, save, clear, and delete history entries.
  HistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  History create() => History();
}

String _$historyHash() => r'3a9e40b51ccc249ce26aaf1e9191ea977b2e5551';

/// A Riverpod Notifier that manages the history of calculations.
///
/// Interacts with the Rust backend to load, save, clear, and delete history entries.

abstract class _$History extends $AsyncNotifier<List<HistoryEntry>> {
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
