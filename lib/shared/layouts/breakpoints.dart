import 'package:flutter/material.dart';

/// Standard screen size classifications for responsive behavior.
enum ScreenSize { compact, medium, expanded }

/// Shared metrics for layout spacing, sizing, and typography across the app.
class LayoutMetrics {
  final double buttonHeight;
  final double spacing;
  final double cardPadding;
  final double borderRadius;

  const LayoutMetrics({
    this.buttonHeight = 56.0,
    this.spacing = 16.0,
    this.cardPadding = 24.0,
    this.borderRadius = 24.0,
  });

  /// Standard default layout metrics
  static const standard = LayoutMetrics();

  /// Compact metrics for short/constrained screens
  static const compact = LayoutMetrics(
    buttonHeight: 48.0,
    spacing: 12.0,
    cardPadding: 16.0,
    borderRadius: 20.0,
  );
}

/// A set of standardised layout breakpoints and utility extensions
/// for responsive design across the app.
class AppBreakpoints {
  /// Maximum height for a screen to be considered "short".
  /// Used to determine if we need to switch from Expanded flex layouts
  /// to scrollable layouts to prevent UI compression (e.g., in split-screen or landscape).
  static const double shortScreenMaxHeight = 650.0;

  /// Maximum width for a screen to be considered "compact" (mobile portrait).
  static const double compactMaxWidth = 600.0;

  /// Minimum width for a screen to be considered "expanded" (desktop/tablet landscape).
  static const double expandedMinWidth = 840.0;
}

extension BoxConstraintsResponsiveX on BoxConstraints {
  /// Returns true if the available vertical space is less than [AppBreakpoints.shortScreenMaxHeight].
  /// This typically happens in landscape mode on phones or in split-screen mode.
  bool get isShortScreen => maxHeight < AppBreakpoints.shortScreenMaxHeight;

  /// Returns true if the available horizontal space is less than [AppBreakpoints.compactMaxWidth].
  bool get isCompactWidth => maxWidth < AppBreakpoints.compactMaxWidth;

  /// Returns true if the available horizontal space is greater than or equal to [AppBreakpoints.expandedMinWidth].
  bool get isExpandedWidth => maxWidth >= AppBreakpoints.expandedMinWidth;
}

extension BuildContextResponsiveX on BuildContext {
  /// Returns the screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Returns true if the screen height is less than [AppBreakpoints.shortScreenMaxHeight].
  bool get isShortScreen =>
      screenSize.height < AppBreakpoints.shortScreenMaxHeight;

  /// Returns true if the screen width is less than [AppBreakpoints.compactMaxWidth].
  bool get isCompactWidth => screenSize.width < AppBreakpoints.compactMaxWidth;

  /// Returns the standard screen size classification (compact, medium, expanded).
  ScreenSize get screenSizeClassification {
    final width = screenSize.width;
    if (width < AppBreakpoints.compactMaxWidth) {
      return ScreenSize.compact;
    } else if (width >= AppBreakpoints.expandedMinWidth) {
      return ScreenSize.expanded;
    } else {
      return ScreenSize.medium;
    }
  }
}
