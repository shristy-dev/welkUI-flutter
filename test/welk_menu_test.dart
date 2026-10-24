import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

const _items = [
  WelkMenuItem(title: 'Home', route: '/'),
  WelkMenuItem(
    title: 'Heroes',
    route: '/heroes',
    children: [
      WelkMenuItem(title: 'Superman', route: '/superman'),
      WelkMenuItem(
        title: 'Batman',
        route: '/batman',
        children: [WelkMenuItem(title: 'Gotham', route: '/gotham')],
      ),
    ],
  ),
  WelkMenuItem(title: 'About', route: '/about'),
];

Widget _app(
  Widget child, {
  bool reducedMotion = false,
  TextDirection direction = TextDirection.ltr,
  double width = 320,
  double textScale = 1,
}) => MaterialApp(
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(
        disableAnimations: reducedMotion,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Directionality(
        textDirection: direction,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'standard destinations select once and parent controls selection',
    (tester) async {
      final changes = <String>[];
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          WelkMenu(items: _items, activeRoute: '/', onSelected: changes.add),
        ),
      );
      expect(find.text('Superman'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        isSemantics(isSelected: true, isButton: true, hasTapAction: true),
      );
      final target = tester.getSemantics(find.bySemanticsLabel('About')).rect;
      expect(target.height, greaterThanOrEqualTo(48));
      expect(target.width, greaterThanOrEqualTo(48));
      await tester.tap(find.text('About'));
      expect(changes, ['/about']);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        isSemantics(isSelected: true),
      );
      await tester.pumpWidget(
        _app(
          WelkMenu(
            items: _items,
            activeRoute: '/about',
            onSelected: changes.add,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('About')),
        isSemantics(isSelected: true),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'nested branches expand without selecting and close on navigation',
    (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          WelkMenu(
            items: _items,
            variant: WelkMenuVariant.nested,
            onSelected: changes.add,
          ),
        ),
      );
      await tester.tap(find.text('Heroes'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(find.text('Go to Heroes'), findsOneWidget);
      await tester.tap(find.text('Batman'));
      await tester.pumpAndSettle();
      expect(find.text('Gotham'), findsOneWidget);
      await tester.tap(find.text('Gotham'));
      await tester.pumpAndSettle();
      expect(changes, ['/gotham']);
      expect(find.text('Gotham'), findsNothing);
      expect(find.text('Go to Heroes'), findsNothing);
      await tester.tap(find.text('Heroes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to Heroes'));
      await tester.pumpAndSettle();
      expect(changes, ['/gotham', '/heroes']);
    },
  );

  testWidgets('collapsed content is not tappable, focusable, or announced', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(WelkMenu(items: _items, collapsible: true, onSelected: (_) {})),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Collapse menu')),
      isSemantics(isExpanded: true),
    );
    await tester.tap(find.bySemanticsLabel('Collapse menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(find.bySemanticsLabel('Home'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Expand menu')),
      isSemantics(isExpanded: false),
    );
    await tester.tap(find.bySemanticsLabel('Expand menu'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('null callback disables destinations', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const WelkMenu(items: _items, onSelected: null)),
    );
    await tester.tap(find.text('Home'));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      isSemantics(isEnabled: false, hasEnabledState: true, hasTapAction: false),
    );
    semantics.dispose();
  });

  testWidgets('keyboard opens a branch and Escape restores branch focus', (
    tester,
  ) async {
    final changes = <String>[];
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        WelkMenu(
          items: _items,
          variant: WelkMenuVariant.nested,
          collapsible: true,
          onSelected: changes.add,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // toggle
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Home
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Heroes
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Superman'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Go to Heroes
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Superman'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Heroes')),
      isSemantics(isFocused: true, isExpanded: false),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Expand menu')),
      isSemantics(isFocused: true),
    );
    expect(changes, isEmpty);
    semantics.dispose();
  });

  testWidgets('outside taps dismiss open branches', (tester) async {
    await tester.pumpWidget(
      _app(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelkMenu(
              items: _items,
              variant: WelkMenuVariant.nested,
              onSelected: (_) {},
            ),
            const SizedBox(height: 100),
            const SizedBox(
              key: ValueKey('outside'),
              width: 100,
              height: 48,
              child: ColoredBox(color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Heroes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('outside')));
    await tester.pumpAndSettle();
    expect(find.text('Superman'), findsNothing);
  });

  testWidgets('reduced motion switches visibility immediately', (tester) async {
    await tester.pumpWidget(
      _app(
        WelkMenu(items: _items, collapsible: true, onSelected: (_) {}),
        reducedMotion: true,
      ),
    );
    await tester.tap(find.bySemanticsLabel('Collapse menu'));
    await tester.pump();
    expect(find.text('Home'), findsNothing);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.byType(AnimatedRotation), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL, large text, narrow nested layouts, and theme overrides', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        WelkTheme(
          data: const WelkThemeData(accent: Colors.pink),
          child: WelkMenu(
            items: const [
              WelkMenuItem(
                title: 'A very long navigation branch title',
                route: '/long',
                children: [
                  WelkMenuItem(
                    title: 'Another long destination title',
                    route: '/child',
                  ),
                ],
              ),
            ],
            variant: WelkMenuVariant.nested,
            activeRoute: '/child',
            onSelected: (_) {},
          ),
        ),
        width: 200,
        direction: TextDirection.rtl,
        textScale: 2,
      ),
    );
    await tester.tap(find.text('A very long navigation branch title'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final label = tester.getRect(find.text('Another long destination title'));
    expect(label.height, greaterThan(48));
    expect(
      tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .any(
            (widget) =>
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color == Colors.pink,
          ),
      isTrue,
    );
  });
}
