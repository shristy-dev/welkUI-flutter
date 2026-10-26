import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'package:welkui_flutter/src/painting/welk_shape_border.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    bool? overRideDarkMode,
    WelkButtonVariant variant = WelkButtonVariant.secondary,
    WelkThemeData theme = const WelkThemeData(),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: WelkTheme(
          data: theme,
          child: Center(
            child: WelkButton(
              overRideDarkMode: overRideDarkMode,
              variant: variant,
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.check), Text('Continue')],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ShapeDecoration decoration(WidgetTester tester) {
    return tester
            .widget<Container>(
              find.descendant(
                of: find.byType(WelkButton),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container &&
                      widget.decoration is ShapeDecoration,
                ),
              ),
            )
            .decoration!
        as ShapeDecoration;
  }

  Color? foreground(WidgetTester tester) =>
      DefaultTextStyle.of(tester.element(find.text('Continue'))).style.color;

  testWidgets('light mode preserves custom Welk theme colors', (tester) async {
    const theme = WelkThemeData(paper: Colors.white, ink: Colors.indigo);
    await pumpButton(tester, theme: theme);
    expect(decoration(tester).color, theme.paper);
    expect(foreground(tester), theme.ink);
    expect(
      (decoration(tester).shape as WelkShapeBorder).strokeColor,
      theme.ink,
    );
  });

  testWidgets('secondary follows theme changes and uses gray in dark mode', (
    tester,
  ) async {
    await pumpButton(tester);
    expect(decoration(tester).color, const WelkThemeData().paper);
    await pumpButton(tester, brightness: Brightness.dark);
    expect(decoration(tester).color, const Color(0xFF303030));
    expect(foreground(tester), const Color(0xFFF5F5F5));
    expect(
      IconTheme.of(tester.element(find.byIcon(Icons.check))).color,
      foreground(tester),
    );
    final outline = (decoration(tester).shape as WelkShapeBorder).strokeColor;
    expect(outline, Colors.black);
    final shadow = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(WelkButton),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is WelkHardShadowPainter,
        ),
      ),
    );
    expect(
      (shadow.painter! as WelkHardShadowPainter).color,
      const Color(0xFFBDBDBD),
    );
    await pumpButton(tester);
    expect(decoration(tester).color, const WelkThemeData().paper);
  });

  testWidgets('explicit override works in both directions', (tester) async {
    await pumpButton(tester, overRideDarkMode: true);
    expect(decoration(tester).color, const Color(0xFF303030));
    await pumpButton(
      tester,
      brightness: Brightness.dark,
      overRideDarkMode: false,
    );
    expect(decoration(tester).color, const WelkThemeData().paper);
    expect(foreground(tester), const WelkThemeData().ink);
  });

  testWidgets('dark variants tint fills and retain contrasting foregrounds', (
    tester,
  ) async {
    const theme = WelkThemeData();
    final fills = {
      WelkButtonVariant.primary: theme.accent,
      WelkButtonVariant.error: theme.error,
      WelkButtonVariant.warning: theme.warning,
      WelkButtonVariant.info: theme.info,
      WelkButtonVariant.success: theme.success,
      WelkButtonVariant.ghost: Colors.transparent,
    };
    for (final entry in fills.entries) {
      await pumpButton(tester, overRideDarkMode: true, variant: entry.key);
      final ghost = entry.key == WelkButtonVariant.ghost;
      final expectedColor = ghost
          ? entry.value
          : Color.alphaBlend(theme.darkButtonTint, entry.value);
      expect(decoration(tester).color, expectedColor);
      if (!ghost) {
        expect(
          expectedColor.computeLuminance(),
          lessThan(entry.value.computeLuminance()),
        );
      }
      expect(
        (decoration(tester).shape as WelkShapeBorder).strokeColor,
        Colors.black,
      );
      expect(
        foreground(tester),
        ghost
            ? theme.darkInk
            : const WelkColors(theme, isDark: true).onFill(expectedColor),
      );
    }
  });

  testWidgets('dark custom variant fills receive light labels', (tester) async {
    await pumpButton(
      tester,
      overRideDarkMode: true,
      variant: WelkButtonVariant.primary,
      theme: const WelkThemeData(accent: Color(0xFF303030)),
    );
    expect(foreground(tester), const Color(0xFFF5F5F5));
  });

  testWidgets(
    'global preference overrides Flutter brightness and updates live',
    (tester) async {
      await pumpButton(tester, theme: const WelkThemeData(darkMode: true));
      expect(decoration(tester).color, const Color(0xFF303030));
      await pumpButton(
        tester,
        brightness: Brightness.dark,
        theme: const WelkThemeData(darkMode: false),
      );
      expect(decoration(tester).color, const WelkThemeData().paper);
    },
  );

  testWidgets('local preference overrides global mode in both directions', (
    tester,
  ) async {
    await pumpButton(
      tester,
      theme: const WelkThemeData(darkMode: true),
      overRideDarkMode: false,
    );
    expect(decoration(tester).color, const WelkThemeData().paper);
    await pumpButton(
      tester,
      theme: const WelkThemeData(darkMode: false),
      overRideDarkMode: true,
    );
    expect(decoration(tester).color, const Color(0xFF303030));
  });

  testWidgets(
    'dark palette tokens are customizable and copyWith retains them',
    (tester) async {
      const theme = WelkThemeData(
        darkMode: false,
        darkPaper: Colors.black,
        darkInk: Colors.white,
        darkOutline: Colors.grey,
        darkShadow: Colors.white70,
        darkButtonTint: Color(0x66000000),
        darkFocus: Colors.cyan,
      );
      final darkTheme = theme.copyWith(darkMode: true);
      await pumpButton(tester, theme: darkTheme);
      expect(decoration(tester).color, theme.darkPaper);
      expect(foreground(tester), theme.darkInk);
      expect(
        (decoration(tester).shape as WelkShapeBorder).strokeColor,
        theme.darkOutline,
      );
      expect(darkTheme.darkFocus, theme.darkFocus);
      expect(darkTheme.darkShadow, theme.darkShadow);
      expect(darkTheme.darkButtonTint, theme.darkButtonTint);
      final updated = darkTheme.copyWith(
        darkPaper: Colors.blueGrey,
        darkInk: Colors.yellow,
        darkOutline: Colors.white,
        darkShadow: Colors.white,
        darkButtonTint: Colors.transparent,
        darkFocus: Colors.green,
      );
      expect(updated.darkMode, isTrue);
      expect(updated.darkPaper, Colors.blueGrey);
      expect(updated.darkInk, Colors.yellow);
      expect(updated.darkOutline, Colors.white);
      expect(updated.darkShadow, Colors.white);
      expect(updated.darkButtonTint, Colors.transparent);
      expect(updated.darkFocus, Colors.green);
    },
  );
}
