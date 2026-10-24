import 'package:flutter/material.dart';

/// Immutable colors and stroke settings used by the WelkUI widgets.
@immutable
class WelkThemeData {
  const WelkThemeData({
    this.paper = const Color(0xFFFFFDF5),
    this.white = const Color(0xFFFFFFFF),
    this.ink = const Color(0xFF242424),
    this.accent = const Color(0xFFFFDA57),
    this.accentHover = const Color(0xFFF3C83D),
    this.error = const Color(0xFFFF8A80),
    this.errorHover = const Color(0xFFF27066),
    this.warning = const Color(0xFFFFB366),
    this.warningHover = const Color(0xFFFF9933),
    this.info = const Color(0xFF82CAFF),
    this.infoHover = const Color(0xFF5BB5F5),
    this.success = const Color(0xFF8DDD9B),
    this.successHover = const Color(0xFF69C97B),
    this.focus = const Color(0xFF3057C4),
    this.muted = const Color(0xFFEFEDE5),
    this.fontFamily = 'ShortStack',
    this.fontPackage = 'welkui_flutter',
    this.borderWidth = 2,
    this.buttonShadowOffset = const Offset(3, 3),
    this.cardShadowOffset = const Offset(3, 3),
    this.switchShadowOffset = const Offset(2, 2),
  });

  final Color paper;
  final Color white;
  final Color ink;
  final Color accent;
  final Color accentHover;
  final Color error;
  final Color errorHover;
  final Color warning;
  final Color warningHover;
  final Color info;
  final Color infoHover;
  final Color success;
  final Color successHover;
  final Color focus;
  final Color muted;
  final String fontFamily;
  final String? fontPackage;
  final double borderWidth;
  final Offset buttonShadowOffset;
  final Offset cardShadowOffset;
  final Offset switchShadowOffset;

  /// Returns a copy with selected design values replaced.
  WelkThemeData copyWith({
    Color? paper,
    Color? white,
    Color? ink,
    Color? accent,
    Color? accentHover,
    Color? error,
    Color? errorHover,
    Color? warning,
    Color? warningHover,
    Color? info,
    Color? infoHover,
    Color? success,
    Color? successHover,
    Color? focus,
    Color? muted,
    String? fontFamily,
    String? fontPackage,
    double? borderWidth,
    Offset? buttonShadowOffset,
    Offset? cardShadowOffset,
    Offset? switchShadowOffset,
  }) {
    return WelkThemeData(
      paper: paper ?? this.paper,
      white: white ?? this.white,
      ink: ink ?? this.ink,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      error: error ?? this.error,
      errorHover: errorHover ?? this.errorHover,
      warning: warning ?? this.warning,
      warningHover: warningHover ?? this.warningHover,
      info: info ?? this.info,
      infoHover: infoHover ?? this.infoHover,
      success: success ?? this.success,
      successHover: successHover ?? this.successHover,
      focus: focus ?? this.focus,
      muted: muted ?? this.muted,
      fontFamily: fontFamily ?? this.fontFamily,
      fontPackage: fontPackage ?? this.fontPackage,
      borderWidth: borderWidth ?? this.borderWidth,
      buttonShadowOffset: buttonShadowOffset ?? this.buttonShadowOffset,
      cardShadowOffset: cardShadowOffset ?? this.cardShadowOffset,
      switchShadowOffset: switchShadowOffset ?? this.switchShadowOffset,
    );
  }
}

/// Provides WelkUI design tokens to the widgets below it in the tree.
class WelkTheme extends InheritedTheme {
  const WelkTheme({super.key, required this.data, required super.child});

  final WelkThemeData data;

  static WelkThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WelkTheme>()?.data ??
        const WelkThemeData();
  }

  @override
  bool updateShouldNotify(WelkTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return WelkTheme(data: data, child: child);
  }
}

/// True when the platform or app requests animations to be disabled.
bool welkAnimationsDisabled(BuildContext context) {
  return MediaQuery.disableAnimationsOf(context);
}
