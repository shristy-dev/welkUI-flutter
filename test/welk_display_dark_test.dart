import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:welkui_flutter/src/painting/welk_shape_border.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

const _data = WelkThemeData();
const _dark = WelkColors(_data, isDark: true);
const _tint = Color(0x1A000000);

Widget _host(
  Widget child, {
  WelkThemeData theme = _data,
  Brightness brightness = Brightness.light,
}) => WelkTheme(
  data: theme,
  child: MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: Center(child: SingleChildScrollView(child: child)),
    ),
  ),
);

Iterable<ShapeDecoration> _shapes(WidgetTester tester, Finder within) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: within, matching: find.byType(DecoratedBox)),
    )
    .map((box) => box.decoration)
    .whereType<ShapeDecoration>();

Iterable<WelkHardShadowPainter> _shadows(WidgetTester tester, Finder within) =>
    tester
        .widgetList<CustomPaint>(
          find.descendant(of: within, matching: find.byType(CustomPaint)),
        )
        .map((paint) => paint.painter)
        .whereType<WelkHardShadowPainter>();

Color? _strokeOf(ShapeDecoration decoration) => switch (decoration.shape) {
  final WelkShapeBorder shape => shape.strokeColor,
  final CircleBorder shape => shape.side.color,
  _ => null,
};

Color? _textColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

double _contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
}

void main() {
  test('every public constructor accepts overRideDarkMode', () {
    final image = MemoryImage(Uint8List(0));
    final widgets = <Object?>[
      const WelkAccordion(
        title: Text('t'),
        overRideDarkMode: true,
        child: SizedBox(),
      ).overRideDarkMode,
      const WelkAvatar(alt: 'a', overRideDarkMode: true).overRideDarkMode,
      const WelkBadge(
        overRideDarkMode: true,
        child: Text('b'),
      ).overRideDarkMode,
      const WelkBreadCrumbs(items: [], overRideDarkMode: true).overRideDarkMode,
      const WelkCard(
        title: 't',
        subtitle: 's',
        overRideDarkMode: true,
      ).overRideDarkMode,
      const WelkDivider(overRideDarkMode: true).overRideDarkMode,
      const WelkImage.asset('a', overRideDarkMode: true).overRideDarkMode,
      const WelkImage.network(
        'https://x.y',
        overRideDarkMode: true,
      ).overRideDarkMode,
      const WelkQRCode(
        url: 'https://x.y',
        overRideDarkMode: true,
      ).overRideDarkMode,
      WelkSticker(
        image: image,
        alt: 'a',
        overRideDarkMode: true,
      ).overRideDarkMode,
      WelkStickerCard(
        title: 't',
        subtitle: 's',
        sticker: image,
        overRideDarkMode: true,
      ).overRideDarkMode,
      const WelkTabs(
        label: 'l',
        items: [],
        overRideDarkMode: true,
      ).overRideDarkMode,
    ];
    expect(widgets, everyElement(isTrue));
    expect(const WelkCard(title: 't', subtitle: 's').overRideDarkMode, isNull);
  });

  testWidgets(
    'badge tints semantic fills and separates text, outline, shadow',
    (tester) async {
      for (final entry in {
        WelkBadgeVariant.defaultStyle: _data.accent,
        WelkBadgeVariant.info: _data.info,
        WelkBadgeVariant.success: _data.success,
        WelkBadgeVariant.warning: _data.warning,
        WelkBadgeVariant.error: _data.error,
      }.entries) {
        await tester.pumpWidget(
          _host(
            WelkBadge(
              variant: entry.key,
              overRideDarkMode: true,
              child: const Text('New'),
            ),
          ),
        );
        final badge = find.byType(WelkBadge);
        final fill = _shapes(tester, badge).single;
        final tinted = Color.alphaBlend(_tint, entry.value);
        expect(fill.color, tinted);
        expect(_strokeOf(fill), Colors.black);
        expect(_shadows(tester, badge).single.color, _data.darkShadow);
        final text = _textColor(tester, 'New')!;
        expect(text, _dark.onFill(tinted));
        expect(text, isNot(_data.darkShadow));
        expect(_contrast(text, tinted), greaterThanOrEqualTo(4.5));
      }

      await tester.pumpWidget(_host(const WelkBadge(child: Text('New'))));
      final light = _shapes(tester, find.byType(WelkBadge)).single;
      expect(light.color, _data.accent);
      expect(_strokeOf(light), _data.ink);
      expect(_shadows(tester, find.byType(WelkBadge)).single.color, _data.ink);
      expect(_textColor(tester, 'New'), _data.ink);
    },
  );

  testWidgets('card inherits global, Flutter, and local dark preferences', (
    tester,
  ) async {
    Future<void> expectCard({
      required bool dark,
      WelkThemeData theme = _data,
      Brightness brightness = Brightness.light,
      bool? override,
    }) async {
      await tester.pumpWidget(
        _host(
          WelkCard(title: 'Title', subtitle: 'Sub', overRideDarkMode: override),
          theme: theme,
          brightness: brightness,
        ),
      );
      // MaterialApp animates theme brightness changes.
      await tester.pumpAndSettle();
      final card = find.byType(WelkCard);
      final surface = _shapes(tester, card).single;
      expect(surface.color, dark ? _data.darkPaper : _data.paper);
      expect(_strokeOf(surface), dark ? Colors.black : _data.ink);
      expect(
        _shadows(tester, card).single.color,
        dark ? _data.darkShadow : _data.ink,
      );
      expect(_textColor(tester, 'Title'), dark ? _data.darkInk : _data.ink);
    }

    await expectCard(dark: false);
    await expectCard(dark: true, brightness: Brightness.dark);
    await expectCard(dark: true, theme: const WelkThemeData(darkMode: true));
    await expectCard(
      dark: false,
      theme: const WelkThemeData(darkMode: false),
      brightness: Brightness.dark,
    );
    await expectCard(
      dark: false,
      theme: const WelkThemeData(darkMode: true),
      override: false,
    );
    await expectCard(dark: true, override: true);
  });

  testWidgets('accordion override propagates to nested widgets and icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const WelkAccordion(
          title: Text('Header'),
          initiallyExpanded: true,
          overRideDarkMode: true,
          child: Column(
            children: [
              Text('Body'),
              Icon(Icons.star),
              WelkBadge(child: Text('Nested')),
              WelkBadge(overRideDarkMode: false, child: Text('Light')),
            ],
          ),
        ),
      ),
    );
    final accordion = find.byType(WelkAccordion);
    final colors = _shapes(tester, accordion).map((s) => s.color).toList();
    expect(colors, contains(_data.darkPaper));
    expect(colors, contains(_dark.accent));
    expect(
      _shapes(tester, accordion).take(3).map(_strokeOf),
      everyElement(Colors.black),
    );
    expect(_shadows(tester, accordion).first.color, _data.darkShadow);
    expect(_textColor(tester, 'Header'), _dark.onFill(_dark.accent));
    expect(_textColor(tester, 'Body'), _data.darkInk);
    expect(
      tester
          .widget<RichText>(
            find.descendant(
              of: find.byType(Icon),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style
          ?.color,
      _data.darkInk,
    );
    final nested = _shapes(
      tester,
      find.ancestor(of: find.text('Nested'), matching: find.byType(WelkBadge)),
    ).single;
    expect(nested.color, _dark.accent);
    final light = _shapes(
      tester,
      find.ancestor(of: find.text('Light'), matching: find.byType(WelkBadge)),
    ).single;
    expect(light.color, _data.accent);
    expect(_textColor(tester, 'Light'), _data.ink);
  });

  testWidgets('tabs use dark neutrals and readable selected labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const WelkTabs(
          label: 'Tabs',
          variant: WelkTabsVariant.withBg,
          overRideDarkMode: true,
          items: [
            WelkTabItem(label: Text('One'), value: '1', content: Text('P1')),
            WelkTabItem(label: Text('Two'), value: '2', content: Text('P2')),
          ],
        ),
      ),
    );
    final tabs = find.byType(WelkTabs);
    final colors = _shapes(tester, tabs).map((s) => s.color).toList();
    expect(
      colors,
      containsAll([_data.darkMuted, _data.darkPaper, _dark.accent]),
    );
    expect(_shadows(tester, tabs).single.color, _data.darkShadow);
    expect(_textColor(tester, 'One'), _dark.onFill(_dark.accent));
    expect(_textColor(tester, 'Two'), _dark.onFill(_data.darkMuted));
    expect(
      _contrast(_textColor(tester, 'Two')!, _data.darkMuted),
      greaterThanOrEqualTo(4.5),
    );
    expect(_textColor(tester, 'P1'), _data.darkInk);
  });

  testWidgets('breadcrumbs pass overrides to every crumb', (tester) async {
    await tester.pumpWidget(
      _host(
        WelkBreadCrumbs(
          overRideDarkMode: true,
          items: [
            WelkBreadCrumbItem(label: const Text('Home'), onPressed: () {}),
            const WelkBreadCrumbItem(label: Text('Here')),
          ],
        ),
      ),
    );
    final crumbs = find.byType(WelkBreadCrumbs);
    final colors = _shapes(tester, crumbs).map((s) => s.color).toList();
    expect(colors, [_data.darkPaper, _dark.accent]);
    expect(_shadows(tester, crumbs).single.color, _data.darkShadow);
    expect(_textColor(tester, 'Home'), _data.darkInk);
    expect(_textColor(tester, 'Here'), _dark.onFill(_dark.accent));
  });

  testWidgets('breadcrumb separators follow global dark tokens', (
    tester,
  ) async {
    Color? iconColor(Finder icon) => tester
        .widget<RichText>(
          find.descendant(of: icon, matching: find.byType(RichText)),
        )
        .text
        .style
        ?.color;
    Widget crumbs({Widget separator = const Text('/')}) => WelkBreadCrumbs(
      separator: separator,
      items: const [
        WelkBreadCrumbItem(label: Text('A')),
        WelkBreadCrumbItem(label: Text('B')),
      ],
    );
    const dark = WelkThemeData(darkMode: true);

    // Material stays light, so only WelkUI can supply the dark foreground.
    await tester.pumpWidget(_host(crumbs(), theme: dark));
    expect(_textColor(tester, '/'), _data.darkInk);

    await tester.pumpWidget(
      _host(crumbs(separator: const Icon(Icons.chevron_right)), theme: dark),
    );
    expect(iconColor(find.byIcon(Icons.chevron_right)), _data.darkInk);

    await tester.pumpWidget(
      _host(
        crumbs(
          separator: const Icon(Icons.chevron_right, color: Colors.orange),
        ),
        theme: dark,
      ),
    );
    expect(iconColor(find.byIcon(Icons.chevron_right)), Colors.orange);

    await tester.pumpWidget(
      _host(
        crumbs(
          separator: const Text('>', style: TextStyle(color: Colors.pink)),
        ),
        theme: dark,
      ),
    );
    expect(_textColor(tester, '>'), Colors.pink);

    // Light mode keeps the ambient Material foregrounds exactly.
    await tester.pumpWidget(_host(crumbs()));
    final lightText = _textColor(tester, '/');
    expect(lightText, isNot(_data.darkInk));
    expect(
      lightText,
      tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.byType(WelkBreadCrumbs),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style
          .color,
    );
    await tester.pumpWidget(
      _host(crumbs(separator: const Icon(Icons.chevron_right))),
    );
    final context = tester.element(find.byIcon(Icons.chevron_right));
    expect(
      iconColor(find.byIcon(Icons.chevron_right)),
      IconTheme.of(context).color,
    );
    expect(IconTheme.of(context).color, isNot(_data.darkInk));
  });

  testWidgets('avatar, divider, and image follow the dark palette', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const WelkTheme(
          data: WelkThemeData(darkMode: true),
          child: Column(
            children: [
              WelkAvatar(alt: 'Icon', icon: Icon(Icons.person)),
              WelkAvatar(
                alt: 'Custom',
                color: Colors.pink,
                icon: Icon(Icons.face),
              ),
              SizedBox(width: 100, child: WelkDivider()),
              SizedBox(width: 100, child: WelkDivider(color: Colors.red)),
              SizedBox(
                width: 120,
                child: WelkImage.asset(
                  'assets/fallbacks/comic_bg_01.jpg',
                  package: 'welkui_flutter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final avatars = find.byType(WelkAvatar);
    final plain = _shapes(tester, avatars.first).single;
    expect(plain.color, _data.darkPaper);
    expect(_strokeOf(plain), Colors.black);
    expect(_shadows(tester, avatars.first).single.color, _data.darkShadow);
    Color? iconColor(IconData icon) => tester
        .widget<RichText>(
          find.descendant(
            of: find.byIcon(icon),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style
        ?.color;
    expect(iconColor(Icons.person), _dark.onFill(_data.darkPaper));
    // Custom colors are honored exactly, with a contrasting icon.
    expect(_shapes(tester, avatars.last).single.color, Colors.pink);
    expect(iconColor(Icons.face), _dark.onFill(Colors.pink));

    final dividers = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(WelkDivider),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((paint) => paint.painter! as dynamic)
        .map((painter) => painter.color as Color)
        .toList();
    expect(dividers, [Colors.black, Colors.red]);

    final image = find.byType(WelkImage);
    expect(_shadows(tester, image).single.color, _data.darkShadow);
    expect(_shapes(tester, image).map(_strokeOf), everyElement(Colors.black));
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(of: image, matching: find.byType(ColoredBox)),
          )
          .color,
      _data.darkPaper,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sticker card and its sticker honor a local override', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 420,
          child: WelkStickerCard(
            title: 'Sticker',
            subtitle: 'Card',
            sticker: MemoryImage(Uint8List.fromList([1, 2, 3])),
            overRideDarkMode: true,
          ),
        ),
      ),
    );
    final card = find.byType(WelkStickerCard);
    expect(
      tester.widget<WelkSticker>(find.byType(WelkSticker)).overRideDarkMode,
      isTrue,
    );
    final surface = _shapes(tester, card).single;
    expect(surface.color, _data.darkPaper);
    expect(_strokeOf(surface), Colors.black);
    expect(_shadows(tester, card).single.color, _data.darkShadow);
    expect(_textColor(tester, 'Sticker'), _data.darkInk);
  });

  testWidgets('failed sticker uses dark paper, black border, light text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        WelkSticker(
          image: MemoryImage(Uint8List.fromList([1, 2, 3])),
          alt: 'Broken',
          overRideDarkMode: true,
        ),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    final box = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(WelkSticker),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .single;
    expect(box.color, _data.darkPaper);
    expect((box.border! as Border).top.color, Colors.black);
    expect(_textColor(tester, 'Unable to load sticker'), _data.darkInk);
  });

  group('QR code', () {
    const url = 'https://ui.welkdock.com/flutter';
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter.runtimeType.toString() == '_QRCodePainter',
    );

    Future<void> expectScannable(WidgetTester tester, GlobalKey key) async {
      final code = QrImage(QrCode(payload: QrPayload.fromString(url)));
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final box = tester.renderObject<RenderBox>(finder);
      final (bytes, width) = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        final width = image.width;
        image.dispose();
        return (data!, width);
      }))!;
      final origin = boundary.localToGlobal(Offset.zero);
      final count = code.moduleCount;
      final module = box.size.shortestSide / (count + 8);
      Color pixel(double col, double row) {
        final point =
            box.localToGlobal(
              Offset((col + .5) * module, (row + .5) * module),
            ) -
            origin;
        final i = (point.dy.round() * width + point.dx.round()) * 4;
        return Color.fromARGB(
          255,
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      // The quiet zone stays white and every module keeps the raw dark ink.
      for (var i = 0; i < count + 8; i++) {
        expect(pixel(i.toDouble(), 1), Colors.white);
        expect(pixel(1, i.toDouble()), Colors.white);
      }
      for (var row = 0; row < count; row++) {
        for (var col = 0; col < count; col++) {
          final color = pixel(col + 4.0, row + 4.0);
          expect(
            color.computeLuminance(),
            code.isDark(row, col) ? lessThan(.05) : greaterThan(.9),
            reason: 'module $row,$col',
          );
        }
      }
    }

    for (final dark in [false, true]) {
      testWidgets('modules stay scannable (dark=$dark)', (tester) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          _host(
            RepaintBoundary(
              key: key,
              child: WelkQRCode(url: url, overRideDarkMode: dark),
            ),
          ),
        );
        await expectScannable(tester, key);
      });
    }

    testWidgets('outer surfaces darken while the code backing stays light', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const WelkQRCode(
            url: url,
            variant: WelkQRCodeVariant.card,
            title: 'Scan me',
            overRideDarkMode: true,
          ),
        ),
      );
      final qr = find.byType(WelkQRCode);
      final shapes = _shapes(tester, qr).toList();
      expect(shapes.map((s) => s.color), [_data.darkPaper, _data.paper]);
      expect(shapes.map(_strokeOf), everyElement(Colors.black));
      expect(
        _shadows(tester, qr).map((s) => s.color),
        everyElement(_data.darkShadow),
      );
      expect(_textColor(tester, 'Scan me'), _data.darkInk);

      await tester.pumpWidget(
        _host(
          const WelkQRCode(
            url: url,
            variant: WelkQRCodeVariant.card,
            title: 'Scan me',
            cardColor: Color(0xFFFFDA57),
            overRideDarkMode: true,
          ),
        ),
      );
      expect(_shapes(tester, qr).first.color, const Color(0xFFFFDA57));
      expect(
        _textColor(tester, 'Scan me'),
        _dark.onFill(const Color(0xFFFFDA57)),
      );
    });

    testWidgets('light mode keeps the original surfaces', (tester) async {
      await tester.pumpWidget(_host(const WelkQRCode(url: url)));
      final shape = _shapes(tester, find.byType(WelkQRCode)).single;
      expect(shape.color, _data.paper);
      expect(_strokeOf(shape), _data.ink);
    });

    testWidgets('validation errors stay readable on dark paper', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const WelkQRCode(url: 'nope', overRideDarkMode: true)),
      );
      expect(
        _shapes(tester, find.byType(WelkQRCode)).single.color,
        _data.darkPaper,
      );
      expect(
        _textColor(
          tester,
          'Enter a valid URL beginning with http:// or https://.',
        ),
        _data.darkInk,
      );
    });
  });
}
