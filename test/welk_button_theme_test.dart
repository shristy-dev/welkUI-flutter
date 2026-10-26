import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'package:welkui_flutter/src/painting/welk_shape_border.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    bool? isDark,
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
              isDark: isDark,
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
    expect(outline, const Color(0xFFBDBDBD));
    final shadow = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(WelkButton),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is WelkHardShadowPainter,
        ),
      ),
    );
    expect((shadow.painter! as WelkHardShadowPainter).color, outline);
    await pumpButton(tester);
    expect(decoration(tester).color, const WelkThemeData().paper);
  });

  testWidgets('explicit override works in both directions', (tester) async {
    await pumpButton(tester, isDark: true);
    expect(decoration(tester).color, const Color(0xFF303030));
    await pumpButton(tester, brightness: Brightness.dark, isDark: false);
    expect(decoration(tester).color, const WelkThemeData().paper);
    expect(foreground(tester), const WelkThemeData().ink);
  });

  testWidgets('dark variants retain fills and contrasting foregrounds', (
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
      await pumpButton(tester, isDark: true, variant: entry.key);
      expect(decoration(tester).color, entry.value);
      expect(
        foreground(tester),
        entry.key == WelkButtonVariant.ghost
            ? const Color(0xFFF5F5F5)
            : theme.ink,
      );
    }
  });

  testWidgets('dark custom variant fills receive light labels', (tester) async {
    await pumpButton(
      tester,
      isDark: true,
      variant: WelkButtonVariant.primary,
      theme: const WelkThemeData(accent: Color(0xFF303030)),
    );
    expect(foreground(tester), const Color(0xFFF5F5F5));
  });
}
