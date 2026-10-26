import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

void main() {
  test('light palette preserves custom tokens exactly', () {
    const data = WelkThemeData(
      paper: Colors.orange,
      ink: Colors.purple,
      accent: Colors.cyan,
      muted: Colors.lime,
    );
    const colors = WelkColors(data, isDark: false);
    expect(colors.paper, data.paper);
    expect(colors.white, data.white);
    expect(colors.ink, data.ink);
    expect(colors.outline, data.ink);
    expect(colors.shadow, data.ink);
    expect(colors.muted, data.muted);
    expect(colors.accent, data.accent);
    expect(colors.onFill(colors.accent), data.ink);
  });

  test('dark palette separates borders, shadows, and text', () {
    const data = WelkThemeData();
    const colors = WelkColors(data, isDark: true);
    expect(colors.outline, Colors.black);
    expect(colors.shadow, const Color(0xFFBDBDBD));
    expect(colors.ink, data.darkInk);
    expect(colors.paper, data.darkPaper);
    expect(colors.white, data.darkPaper);
    expect(colors.muted, data.darkMuted);
    expect(colors.focus, data.darkFocus);
    for (final entry in [
      (colors.accent, data.accent),
      (colors.accentHover, data.accentHover),
      (colors.error, data.error),
      (colors.errorHover, data.errorHover),
      (colors.warning, data.warning),
      (colors.warningHover, data.warningHover),
      (colors.info, data.info),
      (colors.infoHover, data.infoHover),
      (colors.success, data.success),
      (colors.successHover, data.successHover),
    ]) {
      expect(entry.$1, Color.alphaBlend(const Color(0x1A000000), entry.$2));
      expect(
        entry.$1.computeLuminance(),
        lessThan(entry.$2.computeLuminance()),
      );
      final foreground = colors.onFill(entry.$1).computeLuminance();
      final background = entry.$1.computeLuminance();
      final ratio = foreground > background
          ? (foreground + 0.05) / (background + 0.05)
          : (background + 0.05) / (foreground + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });

  test('copyWith preserves and customizes the shared dark palette', () {
    const data = WelkThemeData(
      darkMode: true,
      darkMuted: Colors.blueGrey,
      darkShadow: Colors.white70,
    );
    final copy = data.copyWith(accent: Colors.red);
    expect(copy.darkMode, isTrue);
    expect(copy.darkMuted, Colors.blueGrey);
    expect(copy.darkShadow, Colors.white70);
    expect(copy.copyWith(darkMuted: Colors.grey).darkMuted, Colors.grey);
  });

  test('mid-tone fills use pure black when softer inks lack contrast', () {
    const colors = WelkColors(WelkThemeData(), isDark: true);
    const fill = Color(0xFF808080);
    expect(colors.onFill(fill), Colors.black);
    expect((fill.computeLuminance() + 0.05) / 0.05, greaterThanOrEqualTo(4.5));
  });

  testWidgets(
    'local scope overrides propagate and follow live global updates',
    (tester) async {
      final modes = <bool>[];
      Widget child({bool? override}) => Builder(
        builder: (context) => WelkTheme.scope(
          context,
          overRideDarkMode: override,
          child: Builder(
            builder: (context) {
              modes.add(WelkTheme.of(context).resolveColors(context).isDark);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      for (final global in [false, true]) {
        modes.clear();
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            home: WelkTheme(
              data: WelkThemeData(darkMode: global),
              child: Column(
                children: [
                  child(),
                  child(override: true),
                  child(override: false),
                ],
              ),
            ),
          ),
        );
        expect(modes, [global, true, false]);
      }
    },
  );
}
