// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, AppThemeMode> {
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'938d904dceccbb32d5c157f7957b6b37378ab732';

abstract class _$ThemeModeNotifier extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(UiStyleNotifier)
final uiStyleProvider = UiStyleNotifierProvider._();

final class UiStyleNotifierProvider
    extends $NotifierProvider<UiStyleNotifier, UiStyle> {
  UiStyleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uiStyleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uiStyleNotifierHash();

  @$internal
  @override
  UiStyleNotifier create() => UiStyleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UiStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UiStyle>(value),
    );
  }
}

String _$uiStyleNotifierHash() => r'ff00d79686925f720b2157b8e57f3413402d27d5';

abstract class _$UiStyleNotifier extends $Notifier<UiStyle> {
  UiStyle build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UiStyle, UiStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UiStyle, UiStyle>,
              UiStyle,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
