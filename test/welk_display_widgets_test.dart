import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/src/widgets/welk_accordion.dart';
import 'package:welkui_flutter/src/widgets/welk_avatar.dart';
import 'package:welkui_flutter/src/widgets/welk_badge.dart';
import 'package:welkui_flutter/src/widgets/welk_bread_crumbs.dart';
import 'package:welkui_flutter/src/widgets/welk_divider.dart';
import 'package:welkui_flutter/src/widgets/welk_sticker.dart';
import 'package:welkui_flutter/src/widgets/welk_sticker_card.dart';
import 'package:welkui_flutter/src/widgets/welk_tabs.dart';

// Exercise the example routes with the same package-root test runner.
// ignore: avoid_relative_lib_imports
import '../example/lib/screens/display_widgets_screen.dart';

Widget host(
  Widget child, {
  double width = 400,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(scale),
      disableAnimations: true,
    ),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

const items = [
  WelkTabItem(
    label: Text('First'),
    value: 'first',
    content: Text('First panel'),
  ),
  WelkTabItem(
    label: Text('Disabled'),
    value: 'disabled',
    disabled: true,
    content: Text('Disabled panel'),
  ),
  WelkTabItem(label: Text('Last'), value: 'last', content: Text('Last panel')),
];

Future<Uint8List> pictureBytes() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawCircle(const Offset(8, 8), 6, Paint()..color = Colors.blue);
  final picture = recorder.endRecording();
  final image = await picture.toImage(16, 16);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  testWidgets('cached sticker notifications can rebuild their ancestor', (
    tester,
  ) async {
    final bytes = await tester.runAsync(pictureBytes);
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes!);
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    });
    addTearDown(image!.dispose);
    final good = _ImmediateImageProvider(image);
    final bad = _ImmediateImageProvider(null);
    var loads = 0;
    var errors = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Text('Loaded $loads, errors $errors'),
              WelkSticker(
                image: good,
                alt: 'Cached',
                onLoad: () => setState(() => loads++),
              ),
              WelkSticker(
                image: bad,
                alt: 'Cached failure',
                onError: (_) => setState(() => errors++),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(loads, 1);
    expect(errors, 1);
    expect(find.text('Loaded 1, errors 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing only a sticker fallback retains the primary image', (
    tester,
  ) async {
    final bytes = await tester.runAsync(pictureBytes);
    final good = MemoryImage(bytes!);
    final bad = MemoryImage(Uint8List.fromList([1, 2, 3]));
    var loads = 0;
    Widget sticker(ImageProvider? fallback) => host(
      WelkSticker(
        image: good,
        fallbackImage: fallback,
        alt: 'Primary',
        onLoad: () => loads++,
      ),
    );
    await tester.pumpWidget(sticker(null));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(loads, 1);
    final painted = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(WelkSticker),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((paint) => paint.painter)
        .where((painter) => painter != null)
        .last;
    await tester.pumpWidget(sticker(bad));
    await tester.pumpAndSettle();
    final repainted = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(WelkSticker),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((paint) => paint.painter)
        .where((painter) => painter != null)
        .last;
    expect(repainted!.shouldRepaint(painted!), isFalse);
    expect(loads, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sticker drops queued callbacks for replaced or disposed requests',
    (tester) async {
      final bytes = await tester.runAsync(pictureBytes);
      final image = await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(bytes!);
        final frame = await codec.getNextFrame();
        codec.dispose();
        return frame.image;
      });
      addTearDown(image!.dispose);
      final first = _ManualImageProvider();
      final second = _ManualImageProvider();
      var oldLoads = 0;
      var currentLoads = 0;
      await tester.pumpWidget(
        host(WelkSticker(image: first, alt: 'First', onLoad: () => oldLoads++)),
      );
      first.completer.publish(image);
      await tester.pumpWidget(
        host(
          WelkSticker(
            image: second,
            alt: 'Second',
            onLoad: () => currentLoads++,
          ),
        ),
      );
      expect(oldLoads, 0);
      expect(currentLoads, 0);
      second.completer.publish(image);
      await tester.pumpAndSettle();
      expect(currentLoads, 1);
      second.completer.publish(image);
      await tester.pumpWidget(host(const SizedBox.shrink()));
      await tester.pump();
      expect(currentLoads, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'hidden tab and accordion content cannot retain or request focus',
    (tester) async {
      final tabFocus = FocusNode();
      final accordionFocus = FocusNode();
      addTearDown(tabFocus.dispose);
      addTearDown(accordionFocus.dispose);
      late StateSetter rebuild;
      var selected = 'first';
      var expanded = true;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Column(
                children: [
                  WelkTabs(
                    label: 'Focus',
                    value: selected,
                    items: [
                      WelkTabItem(
                        label: const Text('First'),
                        value: 'first',
                        content: Focus(
                          focusNode: tabFocus,
                          child: const Text('Focusable'),
                        ),
                      ),
                      items.last,
                    ],
                  ),
                  WelkAccordion(
                    title: const Text('Disclosure'),
                    expanded: expanded,
                    child: Focus(
                      focusNode: accordionFocus,
                      child: const Text('Disclosure focus'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
      tabFocus.requestFocus();
      await tester.pump();
      expect(tabFocus.hasFocus, isTrue);
      rebuild(() => selected = 'last');
      await tester.pumpAndSettle();
      expect(tabFocus.hasFocus, isFalse);
      tabFocus.requestFocus();
      await tester.pump();
      expect(tabFocus.hasFocus, isFalse);
      accordionFocus.requestFocus();
      await tester.pump();
      expect(accordionFocus.hasFocus, isTrue);
      rebuild(() => expanded = false);
      await tester.pumpAndSettle();
      expect(accordionFocus.hasFocus, isFalse);
      accordionFocus.requestFocus();
      await tester.pump();
      expect(accordionFocus.hasFocus, isFalse);
    },
  );

  testWidgets(
    'wide horizontal accordion preserves body state and header focus',
    (tester) async {
      final header = FocusNode();
      addTearDown(header.dispose);
      await tester.pumpWidget(
        host(
          WelkAccordion(
            title: const Text('Horizontal'),
            initiallyExpanded: true,
            variant: WelkAccordionVariant.horizontal,
            focusNode: header,
            child: const _CounterPanel(),
          ),
          width: 700,
        ),
      );
      await tester.tap(find.text('Count: 0'));
      await tester.pump();
      header.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsNothing);
      expect(header.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);
      expect(header.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tab panel state follows its value through reorder and insertion',
    (tester) async {
      late StateSetter rebuild;
      var reordered = false;
      const counter = WelkTabItem(
        label: Text('Counter'),
        value: 'counter',
        content: _CounterPanel(),
      );
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return WelkTabs(
                label: 'Reorder',
                value: 'counter',
                items: reordered
                    ? [items.first, items.last, counter]
                    : [counter, items.last],
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Count: 0'));
      await tester.pump();
      rebuild(() => reordered = true);
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);
      rebuild(() => reordered = false);
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('badge variants, sizes, package font and semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Wrap(
          children: [
            for (final variant in WelkBadgeVariant.values)
              WelkBadge(variant: variant, child: Text(variant.name)),
            for (final size in WelkBadgeSize.values)
              WelkBadge(
                size: size,
                semanticLabel: '12 unread',
                child: const Text('12'),
              ),
          ],
        ),
      ),
    );
    expect(find.byType(WelkBadge), findsNWidgets(8));
    expect(find.bySemanticsLabel('12 unread'), findsNWidgets(3));
    final text = tester.widget<Text>(find.text('info'));
    expect(text.style, isNull);
    final style = DefaultTextStyle.of(tester.element(find.text('info'))).style;
    expect(style.fontFamily, 'packages/welkui_flutter/ShortStack');
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('avatar custom icon, sizes and accessible label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const Wrap(
          children: [
            WelkAvatar(
              alt: 'Small hero',
              size: WelkAvatarSize.small,
              icon: Text('A'),
            ),
            WelkAvatar(
              alt: 'Large hero',
              size: WelkAvatarSize.large,
              icon: Text('B'),
            ),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(WelkAvatar).first), const Size(32, 32));
    expect(tester.getSize(find.byType(WelkAvatar).last), const Size(64, 64));
    expect(find.bySemanticsLabel('Small hero'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('breadcrumbs callbacks, current page and empty trail', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        WelkBreadCrumbs(
          items: [
            WelkBreadCrumbItem(
              label: const Text('Home'),
              onPressed: () => taps++,
            ),
            WelkBreadCrumbItem(
              label: const Text('Locked'),
              onPressed: () => taps++,
              enabled: false,
            ),
            const WelkBreadCrumbItem(label: Text('Current')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Home'));
    await tester.tap(find.text('Locked'));
    expect(taps, 1);
    final gesture = find
        .ancestor(of: find.text('Home'), matching: find.byType(GestureDetector))
        .first;
    expect(tester.getSize(gesture).height, greaterThanOrEqualTo(48));
    await tester.pumpWidget(host(const WelkBreadCrumbs(items: [])));
    expect(tester.takeException(), isNull);
  });

  testWidgets('accordion toggles, keyboard, outside tap and disabled', (
    tester,
  ) async {
    final changes = <bool>[];
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      host(
        Column(
          children: [
            WelkAccordion(
              title: const Text('Question'),
              focusNode: node,
              closeOnOutsideClick: true,
              onChanged: changes.add,
              child: const Text('Answer'),
            ),
            const SizedBox(height: 30),
            const Text('Outside'),
          ],
        ),
      ),
    );
    expect(find.text('Answer'), findsNothing);
    await tester.tap(find.text('Question'));
    await tester.pumpAndSettle();
    expect(find.text('Answer'), findsOneWidget);
    await tester.tap(find.text('Outside'));
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes.last, true);
    await tester.pumpWidget(
      host(
        WelkAccordion(
          title: const Text('Disabled'),
          enabled: false,
          onChanged: changes.add,
          child: const Text('Hidden'),
        ),
      ),
    );
    await tester.tap(find.text('Disabled'));
    expect(changes.length, 3);
  });

  testWidgets('controlled accordion respects owner and nested independence', (
    tester,
  ) async {
    var requested = false;
    await tester.pumpWidget(
      host(
        WelkAccordion(
          title: const Text('Controlled'),
          expanded: false,
          onChanged: (value) => requested = value,
          child: const Text('Body'),
        ),
      ),
    );
    await tester.tap(find.text('Controlled'));
    await tester.pump();
    expect(requested, isTrue);
    expect(find.text('Body'), findsNothing);
    await tester.pumpWidget(
      host(
        const WelkAccordion(
          title: Text('Parent'),
          initiallyExpanded: true,
          child: WelkAccordion(
            title: Text('Child'),
            variant: WelkAccordionVariant.nested,
            child: Text('Nested body'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Child'));
    await tester.pumpAndSettle();
    expect(find.text('Nested body'), findsOneWidget);
  });

  testWidgets('tabs skip disabled and wrap keyboard navigation', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      host(
        WelkTabs(label: 'Mission', items: items, onValueChange: changes.add),
      ),
    );
    expect(find.text('First panel'), findsOneWidget);
    await tester.tap(find.text('Disabled'));
    expect(changes, isEmpty);
    await tester.tap(find.text('Last'));
    await tester.pump();
    expect(changes, ['last']);
    expect(find.text('Last panel'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(changes.last, 'first');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(changes.last, 'last');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(changes.last, 'first');
  });

  testWidgets('tabs controlled invalid values, empty and all-disabled', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      host(
        WelkTabs(
          label: 'Mission',
          items: items,
          value: 'unknown',
          onValueChange: changes.add,
        ),
      ),
    );
    expect(find.text('First panel'), findsOneWidget);
    await tester.tap(find.text('Last'));
    await tester.pump();
    expect(changes, ['last']);
    expect(find.text('First panel'), findsOneWidget);
    await tester.pumpWidget(host(const WelkTabs(label: 'Empty', items: [])));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        const WelkTabs(
          label: 'Unavailable',
          items: [
            WelkTabItem(
              label: Text('Locked'),
              value: 'locked',
              disabled: true,
              content: Text('No panel'),
            ),
          ],
        ),
      ),
    );
    expect(find.text('No panel'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs vertical keys, RTL direction and retained panel state', (
    tester,
  ) async {
    final changes = <String>[];
    final panelItems = [
      const WelkTabItem(
        label: Text('Counter'),
        value: 'counter',
        content: _CounterPanel(),
      ),
      items.last,
    ];
    await tester.pumpWidget(
      host(
        WelkTabs(
          label: 'State',
          items: panelItems,
          onValueChange: changes.add,
          orientation: Axis.vertical,
        ),
        width: 600,
      ),
    );
    await tester.tap(find.text('Count: 0'));
    await tester.pump();
    await tester.tap(find.text('Counter'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(changes.last, 'last');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);
    await tester.pumpWidget(
      host(
        WelkTabs(label: 'RTL', items: items, onValueChange: changes.add),
        direction: TextDirection.rtl,
      ),
    );
    await tester.tap(find.text('First'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(changes.last, 'last');
  });

  testWidgets('divider variants and argument validation', (tester) async {
    expect(() => WelkDivider(thickness: 0), throwsAssertionError);
    expect(() => WelkDivider(thickness: double.nan), throwsAssertionError);
    await tester.pumpWidget(
      host(
        Column(
          children: [
            for (final variant in WelkDividerVariant.values)
              WelkDivider(variant: variant),
            const WelkDivider(
              orientation: Axis.vertical,
              length: 80,
              thickness: 4,
            ),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(WelkDivider).last), const Size(4, 80));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sticker fallback loads, errors stop, and primary updates', (
    tester,
  ) async {
    final bytes = await tester.runAsync(pictureBytes);
    final good = MemoryImage(bytes!);
    final bad = MemoryImage(Uint8List.fromList([1, 2, 3]));
    var loads = 0;
    var errors = 0;
    await tester.pumpWidget(
      host(
        WelkSticker(
          image: bad,
          fallbackImage: good,
          alt: 'Fallback art',
          onLoad: () => loads++,
          onError: (_) => errors++,
        ),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(loads, greaterThanOrEqualTo(1));
    expect(errors, 1);
    expect(find.text('Unable to load sticker'), findsNothing);
    await tester.pumpWidget(
      host(
        WelkSticker(image: bad, alt: 'Broken art', onError: (_) => errors++),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to load sticker'), findsOneWidget);
    await tester.pumpWidget(host(WelkSticker(image: good, alt: 'New art')));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load sticker'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sticker card activation and disabled behavior', (tester) async {
    final bytes = await tester.runAsync(pictureBytes);
    final image = MemoryImage(bytes!);
    var taps = 0;
    await tester.pumpWidget(
      host(
        Column(
          children: [
            WelkStickerCard(
              title: 'Launch',
              subtitle: 'Mission',
              sticker: image,
              onPressed: () => taps++,
            ),
            WelkStickerCard(
              title: 'Locked',
              subtitle: 'Mission',
              sticker: image,
              enabled: false,
              onPressed: () => taps++,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Launch'));
    await tester.tap(find.text('Locked'));
    expect(taps, 1);
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow RTL and large text remain overflow-free', (tester) async {
    final bytes = await tester.runAsync(pictureBytes);
    for (final width in [180.0, 400.0, 700.0]) {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              const WelkBadge(child: Text('A very long wrapping badge label')),
              WelkBreadCrumbs(
                items: [
                  WelkBreadCrumbItem(
                    label: const Text('Home'),
                    onPressed: () {},
                  ),
                  const WelkBreadCrumbItem(
                    label: Text('Long wrapping current page'),
                  ),
                ],
              ),
              for (final variant in WelkAccordionVariant.values)
                WelkAccordion(
                  title: const Text('Long question title'),
                  variant: variant,
                  initiallyExpanded: true,
                  child: const Text('A long answer that should wrap.'),
                ),
              for (final axis in Axis.values)
                WelkTabs(
                  label: 'Information',
                  items: items,
                  orientation: axis,
                  variant: WelkTabsVariant.withBg,
                ),
              WelkStickerCard(
                title: 'Long mission title',
                subtitle: 'A description that wraps on small screens.',
                sticker: MemoryImage(bytes!),
                onPressed: () {},
              ),
            ],
          ),
          width: width,
          scale: 2.5,
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('all eight individual mobile demos render without overflow', (
    tester,
  ) async {
    for (final screen in const [
      AvatarScreen(),
      BadgeScreen(),
      BreadCrumbsScreen(),
      DividerScreen(),
      StickerScreen(),
      StickerCardScreen(),
      AccordionScreen(),
      TabsScreen(),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 320, child: screen),
          ),
        ),
      );
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
      final list = find.byType(ListView);
      final scrollable = find
          .descendant(of: list, matching: find.byType(Scrollable))
          .first;
      final position = tester.state<ScrollableState>(scrollable).position;
      while (position.pixels < position.maxScrollExtent) {
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} after scrolling',
        );
      }
    }
  });
}

class _CounterPanel extends StatefulWidget {
  const _CounterPanel();
  @override
  State<_CounterPanel> createState() => _CounterPanelState();
}

class _CounterPanelState extends State<_CounterPanel> {
  int count = 0;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => count++),
    child: Text('Count: $count'),
  );
}

class _ImmediateImageProvider extends ImageProvider<_ImmediateImageProvider> {
  const _ImmediateImageProvider(this.image);
  final ui.Image? image;

  @override
  Future<_ImmediateImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _ImmediateImageProvider key,
    ImageDecoderCallback decode,
  ) => _ImmediateImageCompleter(image);
}

class _ImmediateImageCompleter extends ImageStreamCompleter {
  _ImmediateImageCompleter(ui.Image? image) : _error = image == null {
    if (image != null) setImage(ImageInfo(image: image.clone()));
  }

  final bool _error;

  @override
  void addListener(ImageStreamListener listener) {
    if (_error) {
      listener.onError!(StateError('Cached failure'), StackTrace.current);
    } else {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(ImageStreamListener listener) {
    if (!_error) super.removeListener(listener);
  }
}

class _ManualImageProvider extends ImageProvider<_ManualImageProvider> {
  final completer = _ManualImageCompleter();

  @override
  Future<_ManualImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _ManualImageProvider key,
    ImageDecoderCallback decode,
  ) => completer;
}

class _ManualImageCompleter extends ImageStreamCompleter {
  void publish(ui.Image image) => setImage(ImageInfo(image: image.clone()));
}
