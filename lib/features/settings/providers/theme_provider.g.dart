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

@ProviderFor(AppColorNotifier)
final appColorProvider = AppColorNotifierProvider._();

final class AppColorNotifierProvider
    extends $NotifierProvider<AppColorNotifier, AppColorOption> {
  AppColorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appColorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appColorNotifierHash();

  @$internal
  @override
  AppColorNotifier create() => AppColorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppColorOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppColorOption>(value),
    );
  }
}

String _$appColorNotifierHash() => r'ee6b5d65ce26cdf843c201e9c946d647c6f2606d';

abstract class _$AppColorNotifier extends $Notifier<AppColorOption> {
  AppColorOption build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppColorOption, AppColorOption>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppColorOption, AppColorOption>,
              AppColorOption,
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

String _$uiStyleNotifierHash() => r'd2641d05ef44d02d63a4857e6ece7bdf18331138';

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
