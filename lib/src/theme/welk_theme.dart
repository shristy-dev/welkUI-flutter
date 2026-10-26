import 'package:flutter/material.dart';

/// Immutable colors and stroke settings used by the WelkUI widgets.
@immutable
class WelkThemeData {
  const WelkThemeData({
    this.darkMode,
    this.darkPaper = const Color(0xFF303030),
    this.darkMuted = const Color(0xFF424242),
    this.darkInk = const Color(0xFFF5F5F5),
    this.darkOutline = const Color(0xFF000000),
    this.darkShadow = const Color(0xFFBDBDBD),
    this.darkButtonTint = const Color(0x1A000000),
    this.darkFocus = const Color(0xFF82CAFF),
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

  /// Global dark-mode preference for WelkUI widgets.
  ///
  /// Null follows Flutter's [ThemeData.brightness]. A widget's
  /// `overRideDarkMode` takes precedence over this preference.
  final bool? darkMode;
  final Color darkPaper;
  final Color darkMuted;
  final Color darkInk;
  final Color darkOutline;
  final Color darkShadow;
  final Color darkButtonTint;
  final Color darkFocus;

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
    bool? darkMode,
    Color? darkPaper,
    Color? darkMuted,
    Color? darkInk,
    Color? darkOutline,
    Color? darkShadow,
    Color? darkButtonTint,
    Color? darkFocus,
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
      darkMode: darkMode ?? this.darkMode,
      darkPaper: darkPaper ?? this.darkPaper,
      darkMuted: darkMuted ?? this.darkMuted,
      darkInk: darkInk ?? this.darkInk,
      darkOutline: darkOutline ?? this.darkOutline,
      darkShadow: darkShadow ?? this.darkShadow,
      darkButtonTint: darkButtonTint ?? this.darkButtonTint,
      darkFocus: darkFocus ?? this.darkFocus,
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

  /// Resolves a local override, then the global preference, then Flutter's theme.
  bool resolveDarkMode(BuildContext context, {bool? overRideDarkMode}) =>
      overRideDarkMode ??
      darkMode ??
      Theme.of(context).brightness == Brightness.dark;

  /// Resolves the palette without changing the underlying design tokens.
  WelkColors resolveColors(BuildContext context, {bool? overRideDarkMode}) =>
      WelkColors(
        this,
        isDark: resolveDarkMode(context, overRideDarkMode: overRideDarkMode),
      );
}

/// Semantic colors shared by WelkUI surfaces, controls, and overlays.
@immutable
class WelkColors {
  const WelkColors(this.data, {required this.isDark});

  final WelkThemeData data;
  final bool isDark;

  Color get paper => isDark ? data.darkPaper : data.paper;
  Color get white => isDark ? data.darkPaper : data.white;
  Color get muted => isDark ? data.darkMuted : data.muted;
  Color get ink => isDark ? data.darkInk : data.ink;
  Color get outline => isDark ? data.darkOutline : data.ink;
  Color get shadow => isDark ? data.darkShadow : data.ink;
  Color get focus => isDark ? data.darkFocus : data.focus;
  Color get accent => fill(data.accent);
  Color get accentHover => fill(data.accentHover);
  Color get error => fill(data.error);
  Color get errorHover => fill(data.errorHover);
  Color get warning => fill(data.warning);
  Color get warningHover => fill(data.warningHover);
  Color get info => fill(data.info);
  Color get infoHover => fill(data.infoHover);
  Color get success => fill(data.success);
  Color get successHover => fill(data.successHover);
  String get fontFamily => data.fontFamily;
  String? get fontPackage => data.fontPackage;
  double get borderWidth => data.borderWidth;
  Offset get buttonShadowOffset => data.buttonShadowOffset;
  Offset get cardShadowOffset => data.cardShadowOffset;
  Offset get switchShadowOffset => data.switchShadowOffset;

  Color fill(Color color) =>
      isDark ? Color.alphaBlend(data.darkButtonTint, color) : color;

  /// Keeps semantic fills readable without altering light-mode custom themes.
  Color onFill(Color color) {
    if (!isDark) return data.ink;
    const dark = Color(0xFF242424);
    final background = color.computeLuminance();
    double contrast(Color foreground) {
      final luminance = foreground.computeLuminance();
      return luminance > background
          ? (luminance + 0.05) / (background + 0.05)
          : (background + 0.05) / (luminance + 0.05);
    }

    final foreground = contrast(data.darkInk) >= contrast(dark)
        ? data.darkInk
        : dark;
    if (contrast(foreground) >= 4.5) return foreground;
    // Mid-tone fills can need pure black or white to meet text contrast.
    return contrast(Colors.white) >= contrast(Colors.black)
        ? Colors.white
        : Colors.black;
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

  /// Carries a local override into composed widgets and user-supplied children.
  static Widget scope(
    BuildContext context, {
    required bool? overRideDarkMode,
    required Widget child,
  }) => overRideDarkMode == null
      ? child
      : WelkTheme(
          data: of(context).copyWith(darkMode: overRideDarkMode),
          child: child,
        );

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
