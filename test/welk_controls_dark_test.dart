import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/src/painting/welk_focus_ring.dart';
import 'package:welkui_flutter/src/painting/welk_shape_border.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

const raw = WelkThemeData();
const dark = WelkColors(raw, isDark: true);

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  WelkThemeData theme = raw,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: WelkTheme(
        data: theme,
        child: Material(
          child: Center(child: SizedBox(width: 360, child: child)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<ShapeDecoration> shapes(WidgetTester tester, Finder of) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: of, matching: find.byType(DecoratedBox)),
    )
    .map((box) => box.decoration)
    .whereType<ShapeDecoration>()
    .toList();

List<Color> fills(WidgetTester tester, Finder of) =>
    shapes(tester, of).map((d) => d.color).whereType<Color>().toList();

Set<Color> strokes(WidgetTester tester, Finder of) => shapes(tester, of)
    .map((d) => d.shape)
    .map(
      (s) => s is WelkShapeBorder
          ? s.strokeColor
          : (s as OutlinedBorder).side.color,
    )
    .toSet();

Set<Color> shadows(WidgetTester tester, Finder of) => tester
    .widgetList<CustomPaint>(
      find.descendant(of: of, matching: find.byType(CustomPaint)),
    )
    .map((p) => p.painter)
    .whereType<WelkHardShadowPainter>()
    .map((p) => p.color)
    .toSet();

Color? textColor(WidgetTester tester, Finder text) =>
    tester.renderObject<RenderParagraph>(text).text.style?.color;

Color painterColor(WidgetTester tester, Finder of, String type) =>
    (tester
                    .widgetList<CustomPaint>(
                      find.descendant(
                        of: of,
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .map((p) => p.painter)
                    .firstWhere((p) => p.runtimeType.toString() == type)
                as dynamic)
            .color
        as Color;

void main() {
  test('dark palette tints semantic fills and needs contrasting text', () {
    expect(dark.accent, isNot(raw.accent));
    expect(dark.outline, Colors.black);
    expect(dark.shadow, raw.darkShadow);
  });

  group('WelkCheckBox', () {
    Widget box({bool? override}) => WelkCheckBox(
      value: true,
      label: 'Agree',
      onChanged: (_) {},
      overRideDarkMode: override,
    );
    final of = find.byType(WelkCheckBox);

    testWidgets('light keeps raw tokens', (tester) async {
      await pump(tester, box());
      expect(fills(tester, of), [raw.accent]);
      expect(strokes(tester, of), {raw.ink});
      expect(painterColor(tester, of, '_CheckMark'), raw.ink);
      expect(textColor(tester, find.text('Agree')), raw.ink);
    });

    testWidgets('global dark tints fill with contrasting mark', (tester) async {
      await pump(tester, box(), theme: raw.copyWith(darkMode: true));
      expect(fills(tester, of), [dark.accent]);
      expect(strokes(tester, of), {Colors.black});
      expect(painterColor(tester, of, '_CheckMark'), dark.onFill(dark.accent));
      expect(textColor(tester, find.text('Agree')), raw.darkInk);
    });

    testWidgets('override wins in both directions', (tester) async {
      await pump(tester, box(override: false), brightness: Brightness.dark);
      expect(fills(tester, of), [raw.accent]);
      expect(textColor(tester, find.text('Agree')), raw.ink);
      await pump(tester, box(override: true));
      expect(fills(tester, of), [dark.accent]);
      expect(textColor(tester, find.text('Agree')), raw.darkInk);
    });
  });

  testWidgets('WelkSwitch follows Flutter brightness', (tester) async {
    final of = find.byType(WelkSwitch);
    await pump(
      tester,
      WelkSwitch(value: true, label: 'Wifi', onChanged: (_) {}),
      brightness: Brightness.dark,
    );
    expect(fills(tester, of), [dark.accent]);
    expect(strokes(tester, of), {Colors.black});
    expect(shadows(tester, of), {raw.darkShadow});
    final thumb = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: of, matching: find.byType(DecoratedBox)),
        )
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .single;
    expect(thumb.color, raw.darkPaper);
    expect((thumb.border! as Border).top.color, Colors.black);
    expect(textColor(tester, find.text('Wifi')), raw.darkInk);
  });

  testWidgets('WelkRadioGroup override propagates into radios', (tester) async {
    Widget group(bool override) => WelkRadioGroup(
      label: 'Size',
      value: 'a',
      onChanged: (_) {},
      overRideDarkMode: override,
      options: const [
        WelkRadioOption(value: 'a', label: 'A'),
        WelkRadioOption(value: 'b', label: 'B'),
      ],
    );
    await pump(tester, group(true));
    final of = find.byType(WelkRadio);
    expect(textColor(tester, find.text('Size')), raw.darkInk);
    expect(textColor(tester, find.text('B')), raw.darkInk);
    expect(fills(tester, of), containsAll([dark.accent, raw.darkPaper]));
    expect(strokes(tester, of), {Colors.black});
    final dot = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: of, matching: find.byType(DecoratedBox)),
        )
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .single;
    expect(dot.color, dark.onFill(dark.accent));

    await pump(tester, group(false), brightness: Brightness.dark);
    expect(textColor(tester, find.text('B')), raw.ink);
    expect(fills(tester, of), containsAll([raw.accent, raw.paper]));
  });

  group('WelkIconButton', () {
    testWidgets('standard dark uses tinted accent and contrasting icon', (
      tester,
    ) async {
      await pump(
        tester,
        WelkIconButton(
          icon: const Icon(Icons.add),
          label: 'Add',
          onPressed: () {},
          overRideDarkMode: true,
        ),
      );
      final of = find.byType(WelkIconButton);
      expect(fills(tester, of), [dark.accent]);
      expect(strokes(tester, of), {Colors.black});
      expect(shadows(tester, of), {raw.darkShadow});
      expect(
        IconTheme.of(tester.element(find.byIcon(Icons.add))).color,
        dark.onFill(dark.accent),
      );
    });

    testWidgets('close paints neutral paper in both modes', (tester) async {
      final of = find.byType(WelkIconButton);
      await pump(
        tester,
        WelkIconButton.close(label: 'Close', onPressed: () {}),
      );
      expect(fills(tester, of), [raw.paper]);
      expect(
        IconTheme.of(tester.element(find.byIcon(Icons.close))).color,
        raw.ink,
      );
      await pump(
        tester,
        WelkIconButton.close(
          label: 'Close',
          onPressed: () {},
          overRideDarkMode: true,
        ),
      );
      expect(fills(tester, of), [raw.darkPaper]);
      expect(strokes(tester, of), {Colors.black});
      expect(
        IconTheme.of(tester.element(find.byIcon(Icons.close))).color,
        raw.darkInk,
      );
    });
  });

  group('text inputs', () {
    testWidgets('WelkInput light and dark surfaces', (tester) async {
      final of = find.byType(WelkInput);
      Widget input(bool? override) => WelkInput(
        label: 'Name',
        value: 'Ada',
        onChanged: (_) {},
        overRideDarkMode: override,
      );
      await pump(tester, input(null));
      expect(fills(tester, of), [raw.paper]);
      expect(strokes(tester, of), {raw.ink});
      expect(shadows(tester, of), {raw.ink});
      await pump(tester, input(true));
      expect(fills(tester, of), [raw.darkPaper]);
      expect(strokes(tester, of), {Colors.black});
      expect(shadows(tester, of), {raw.darkShadow});
      expect(textColor(tester, find.text('Name')), raw.darkInk);
      expect(
        tester.widget<TextField>(find.byType(TextField)).style?.color,
        raw.darkInk,
      );
    });

    testWidgets('WelkInput dark keeps black outline with separate focus ring', (
      tester,
    ) async {
      final of = find.byType(WelkInput);
      final node = FocusNode();
      addTearDown(node.dispose);
      Widget input(bool? override) => WelkInput(
        label: 'Email',
        value: 'x',
        onChanged: (_) {},
        invalid: true,
        errorText: 'Invalid email',
        focusNode: node,
        overRideDarkMode: override,
      );
      WelkFocusRing ring() => tester.widget<WelkFocusRing>(
        find.descendant(of: of, matching: find.byType(WelkFocusRing)),
      );

      await pump(tester, input(true));
      expect(strokes(tester, of), {Colors.black});
      expect(ring().visible, isFalse);
      expect(find.text('Invalid email'), findsOneWidget);

      node.requestFocus();
      await tester.pumpAndSettle();
      expect(strokes(tester, of), {Colors.black});
      expect(ring().visible, isTrue);
      expect(ring().color, raw.darkFocus);
      expect(find.byType(WelkFocusRing), findsOneWidget);

      await pump(tester, input(false));
      expect(strokes(tester, of), {raw.errorHover});
      expect(ring().visible, isFalse);
      await pump(
        tester,
        WelkInput(
          label: 'Email',
          value: 'x',
          onChanged: (_) {},
          focusNode: node,
          overRideDarkMode: false,
        ),
      );
      node.requestFocus();
      await tester.pumpAndSettle();
      expect(strokes(tester, of), {raw.focus});
      expect(ring().visible, isFalse);
    });

    testWidgets('WelkOTPInput invalid digits contrast on tinted error', (
      tester,
    ) async {
      final of = find.byType(WelkOTPInput);
      await pump(
        tester,
        const WelkOTPInput(
          label: 'Code',
          value: '12',
          length: 4,
          invalid: true,
          overRideDarkMode: true,
        ),
      );
      expect(fills(tester, of).toSet(), {dark.error});
      expect(strokes(tester, of), {Colors.black});
      expect(shadows(tester, of), {raw.darkShadow});
      expect(textColor(tester, find.text('1')), dark.onFill(dark.error));
      expect(textColor(tester, find.text('Code')), raw.darkInk);
    });
  });

  testWidgets('WelkRangeSlider dark thumb and track', (tester) async {
    final of = find.byType(WelkRangeSlider);
    await pump(
      tester,
      WelkRangeSlider(label: 'Volume', value: 40, onChanged: (_) {}),
      theme: raw.copyWith(darkMode: true),
    );
    expect(fills(tester, of), containsAll([raw.darkPaper, dark.accent]));
    expect(strokes(tester, of), {Colors.black});
    expect(shadows(tester, of), {raw.darkShadow});
    expect(textColor(tester, find.text('Volume')), raw.darkInk);
  });

  testWidgets('WelkAttachment dark surface and action foreground', (
    tester,
  ) async {
    final of = find.byType(WelkAttachment);
    await pump(
      tester,
      WelkAttachment(
        label: const Text('Files'),
        onSelectFiles: () async => null,
        overRideDarkMode: true,
      ),
    );
    expect(fills(tester, of), containsAll([raw.darkPaper, dark.accent]));
    expect(strokes(tester, of), {Colors.black});
    expect(shadows(tester, of), {raw.darkShadow});
    expect(
      textColor(tester, find.text('Choose files')),
      dark.onFill(dark.accent),
    );
    expect(textColor(tester, find.text('Files')), raw.darkInk);
  });

  testWidgets('WelkMenu selected row contrasts in dark, not in light', (
    tester,
  ) async {
    Widget menu(bool? override) => WelkMenu(
      items: const [
        WelkMenuItem(title: 'Home', route: '/'),
        WelkMenuItem(title: 'About', route: '/about'),
      ],
      activeRoute: '/',
      onSelected: (_) {},
      collapsible: true,
      overRideDarkMode: override,
    );
    final of = find.byType(WelkMenu);
    await pump(tester, menu(null));
    expect(textColor(tester, find.text('Home')), raw.ink);
    expect(textColor(tester, find.text('About')), raw.ink);
    await pump(tester, menu(true));
    expect(textColor(tester, find.text('Home')), dark.onFill(dark.accent));
    expect(textColor(tester, find.text('About')), raw.darkInk);
    expect(fills(tester, of), [dark.accent]);
    expect(shadows(tester, of), {raw.darkShadow});
    expect(
      tester
          .widgetList<ColoredBox>(
            find.descendant(of: of, matching: find.byType(ColoredBox)),
          )
          .map((b) => b.color)
          .toSet(),
      {Colors.black},
    );
  });

  testWidgets('nested dark providers tint semantic fills only once', (
    tester,
  ) async {
    await pump(
      tester,
      Builder(
        builder: (context) => WelkTheme.scope(
          context,
          overRideDarkMode: true,
          child: WelkRadioGroup(
            label: 'Nested',
            value: 'a',
            onChanged: (_) {},
            overRideDarkMode: true,
            options: const [WelkRadioOption(value: 'a', label: 'A')],
          ),
        ),
      ),
      theme: raw.copyWith(darkMode: true),
    );
    expect(fills(tester, find.byType(WelkRadio)), [dark.accent]);
    expect(dark.accent, Color.alphaBlend(raw.darkButtonTint, raw.accent));
  });

  group('WelkDropDown popup', () {
    Widget dropDown({bool? override, String? value}) => WelkDropDown(
      label: 'Fruit',
      value: value,
      onChanged: (_) {},
      overRideDarkMode: override,
      options: const [
        WelkDropDownOption(value: 'a', label: 'Apple'),
        WelkDropDownOption(value: 'b', label: 'Banana'),
      ],
    );
    Color? popupFill(WidgetTester tester) => tester
        .widgetList<Container>(
          find.ancestor(
            of: find.text('Banana'),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<ShapeDecoration>()
        .first
        .color;
    Future<void> open(WidgetTester tester, String text) async {
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    testWidgets('inherits local Flutter brightness when darkMode is null', (
      tester,
    ) async {
      await pump(
        tester,
        Builder(
          builder: (context) => Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: dropDown(),
          ),
        ),
      );
      final of = find.byType(WelkDropDown);
      expect(fills(tester, of), [raw.darkPaper]);
      await open(tester, 'Select an option');
      final popup = tester.element(find.text('Banana'));
      expect(WelkTheme.of(popup).darkMode, isNull);
      expect(WelkTheme.of(popup).resolveDarkMode(popup), isTrue);
      expect(popupFill(tester), raw.darkPaper);
      expect(textColor(tester, find.text('Banana')), raw.darkInk);
    });

    testWidgets('open popup follows live global mode above Navigator', (
      tester,
    ) async {
      final global = ValueNotifier<bool?>(false);
      addTearDown(global.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ValueListenableBuilder<bool?>(
            valueListenable: global,
            builder: (context, mode, _) => WelkTheme(
              data: raw.copyWith(darkMode: mode),
              child: child!,
            ),
          ),
          home: Material(
            child: Center(
              child: SizedBox(width: 360, child: dropDown(value: 'a')),
            ),
          ),
        ),
      );
      await open(tester, 'Apple');
      expect(popupFill(tester), raw.paper);
      expect(textColor(tester, find.text('Banana')), raw.ink);

      global.value = true;
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget, reason: 'popup stays open');
      expect(popupFill(tester), raw.darkPaper);
      expect(textColor(tester, find.text('Banana')), raw.darkInk);
      final optionFill = tester
          .widgetList<Ink>(find.byType(Ink))
          .map((ink) => (ink.decoration as BoxDecoration?)?.color)
          .first;
      expect(optionFill, Color.alphaBlend(raw.darkButtonTint, raw.accentHover));

      global.value = false;
      await tester.pumpAndSettle();
      expect(popupFill(tester), raw.paper);
    });

    testWidgets('explicit override pins popup against live global mode', (
      tester,
    ) async {
      final global = ValueNotifier<bool?>(true);
      addTearDown(global.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ValueListenableBuilder<bool?>(
            valueListenable: global,
            builder: (context, mode, _) => WelkTheme(
              data: raw.copyWith(darkMode: mode),
              child: child!,
            ),
          ),
          home: Material(
            child: Center(
              child: SizedBox(
                width: 360,
                child: dropDown(override: false, value: 'a'),
              ),
            ),
          ),
        ),
      );
      await open(tester, 'Apple');
      expect(popupFill(tester), raw.paper);
      global.value = false;
      await tester.pumpAndSettle();
      global.value = true;
      await tester.pumpAndSettle();
      expect(popupFill(tester), raw.paper);
      expect(textColor(tester, find.text('Banana')), raw.ink);
    });

    testWidgets('override true opens a dark popup in a light app', (
      tester,
    ) async {
      await pump(tester, dropDown(override: true, value: 'a'));
      await open(tester, 'Apple');
      expect(popupFill(tester), raw.darkPaper);
      final optionFill = tester
          .widgetList<Ink>(find.byType(Ink))
          .map((ink) => (ink.decoration as BoxDecoration?)?.color)
          .first;
      expect(optionFill, dark.accentHover);
      final apple = find.text('Apple').last;
      final fill = dark.accentHover; // Selected option is also active.
      expect(textColor(tester, apple), dark.onFill(fill));
      expect(textColor(tester, find.text('Banana')), raw.darkInk);
    });

    testWidgets('override false opens a light popup in a dark theme', (
      tester,
    ) async {
      await pump(
        tester,
        dropDown(override: false),
        brightness: Brightness.dark,
        theme: raw.copyWith(darkMode: true),
      );
      expect(fills(tester, find.byType(WelkDropDown)), [raw.paper]);
      await open(tester, 'Select an option');
      expect(popupFill(tester), raw.paper);
      expect(textColor(tester, find.text('Banana')), raw.ink);
    });
  });
}
