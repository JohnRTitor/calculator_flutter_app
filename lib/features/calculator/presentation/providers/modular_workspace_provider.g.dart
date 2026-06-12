// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modular_workspace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ModularWorkspace)
final modularWorkspaceProvider = ModularWorkspaceProvider._();

final class ModularWorkspaceProvider
    extends $NotifierProvider<ModularWorkspace, ModularWorkspaceState> {
  ModularWorkspaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modularWorkspaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modularWorkspaceHash();

  @$internal
  @override
  ModularWorkspace create() => ModularWorkspace();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModularWorkspaceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModularWorkspaceState>(value),
    );
  }
}

String _$modularWorkspaceHash() => r'f5a6bfc956d00190a57da6570ce6cdabffddc09e';

abstract class _$ModularWorkspace extends $Notifier<ModularWorkspaceState> {
  ModularWorkspaceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ModularWorkspaceState, ModularWorkspaceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ModularWorkspaceState, ModularWorkspaceState>,
              ModularWorkspaceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
