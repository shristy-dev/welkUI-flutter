import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

const _icons = [Icons.home, Icons.search, Icons.add, Icons.mail, Icons.person];
const _labels = ['Home', 'Search', 'Create', 'Inbox', 'Profile'];

List<WelkBottomNavItem> _barItems([int count = 5]) => [
  for (var i = 0; i < count; i++)
    WelkBottomNavItem(icon: Icon(_icons[i]), label: _labels[i]),
];

class _CounterPage extends StatefulWidget {
  const _CounterPage(this.name);

  final String name;

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      children: [
        TextButton(
          onPressed: () => setState(() => _count++),
          child: Text('${widget.name} count $_count'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text('${widget.name} details')),
              ),
            ),
          ),
          child: Text('Open ${widget.name} details'),
        ),
        for (var i = 0; i < 60; i++)
          SizedBox(height: 60, child: Text('${widget.name} row $i')),
      ],
    ),
  );
}

List<WelkBottomNavItem> _pageItems() => [
  for (var i = 0; i < 5; i++)
    WelkBottomNavItem(
      icon: Icon(_icons[i]),
      label: _labels[i],
      builder: (_) => _CounterPage(_labels[i]),
    ),
];

Widget _shell({
  WelkBottomNavVisibility visibility = WelkBottomNavVisibility.sticky,
  WelkBottomNavMode mode = WelkBottomNavMode.defaultMode,
  ValueChanged<int>? onIndexChanged,
  int initialIndex = 0,
}) => MaterialApp(
  home: WelkBottomNavScaffold(
    items: _pageItems(),
    initialIndex: initialIndex,
    visibility: visibility,
    mode: mode,
    onIndexChanged: onIndexChanged,
  ),
);

WelkBottomNavScaffoldState _state(WidgetTester tester) =>
    tester.state(find.byType(WelkBottomNavScaffold));

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(WelkBottomNavBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final layout in WelkBottomNavLayout.values) {
    for (final mode in WelkBottomNavMode.values) {
      for (final dark in [false, true]) {
        testWidgets('${layout.name} ${mode.name} dark=$dark renders and taps', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          var index = 0;
          await tester.pumpWidget(
            WelkTheme(
              data: WelkThemeData(darkMode: dark),
              child: MaterialApp(
                home: StatefulBuilder(
                  builder: (context, setState) => Scaffold(
                    extendBody: true,
                    bottomNavigationBar: WelkBottomNavBar(
                      items: _barItems(),
                      currentIndex: index,
                      layout: layout,
                      mode: mode,
                      onTap: (value) => setState(() => index = value),
                    ),
                  ),
                ),
              ),
            ),
          );
          for (final target in [2, 4, 0]) {
            await tester.tap(find.text(_labels[target]));
            await tester.pumpAndSettle();
            expect(index, target);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('even item counts and large text render without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final layout in WelkBottomNavLayout.values) {
      for (final count in [2, 4]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: WelkBottomNavBar(
                items: _barItems(count),
                currentIndex: count - 1,
                layout: layout,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('items expose selected button semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: WelkBottomNavBar(
            items: _barItems(3),
            currentIndex: 1,
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Search')),
      isSemantics(
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
        label: 'Search',
        hint: 'Tab 2 of 3',
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Create')),
      isSemantics(isButton: true, isSelected: false, hint: 'Tab 3 of 3'),
    );
    handle.dispose();
  });

  testWidgets('scaffold switches pages and preserves their state', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(_shell(onIndexChanged: changes.add));
    await tester.tap(find.text('Home count 0'));
    await tester.pump();
    expect(find.text('Home count 1'), findsOneWidget);

    await _tapTab(tester, 'Search');
    expect(find.text('Search count 0'), findsOneWidget);
    expect(find.text('Home count 1'), findsNothing);

    await _tapTab(tester, 'Home');
    expect(find.text('Home count 1'), findsOneWidget);
    expect(changes, [1, 0]);
    expect(_state(tester).currentIndex, 0);
  });

  testWidgets('bar hides on subpages and returns on the tab root', (
    tester,
  ) async {
    await tester.pumpWidget(_shell());
    await tester.tap(find.text('Open Home details'));
    await tester.pumpAndSettle();
    expect(find.text('Home details'), findsOneWidget);
    expect(_state(tester).isBarVisible, isFalse);
    expect(
      tester.getTopLeft(find.byType(WelkBottomNavBar)).dy,
      greaterThanOrEqualTo(600),
    );

    // System back pops the nested navigator, not the app.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home details'), findsNothing);
    expect(_state(tester).isBarVisible, isTrue);
    expect(_state(tester).currentIndex, 0);
    expect(tester.getBottomLeft(find.byType(WelkBottomNavBar)).dy, 600);
  });

  testWidgets('reselecting a tab pops it to its root page', (tester) async {
    await tester.pumpWidget(_shell());
    await tester.tap(find.text('Open Home details'));
    await tester.pumpAndSettle();
    _state(tester).select(0);
    await tester.pumpAndSettle();
    expect(find.text('Home details'), findsNothing);
    expect(_state(tester).isBarVisible, isTrue);
  });

  testWidgets('alwaysVisible keeps the bar on subpages', (tester) async {
    await tester.pumpWidget(
      _shell(visibility: WelkBottomNavVisibility.alwaysVisible),
    );
    await tester.tap(find.text('Open Home details'));
    await tester.pumpAndSettle();
    expect(_state(tester).isBarVisible, isTrue);
  });

  testWidgets('hideOnScrollDown hides on scroll down and shows on scroll up', (
    tester,
  ) async {
    await tester.pumpWidget(
      _shell(visibility: WelkBottomNavVisibility.hideOnScrollDown),
    );
    await tester.drag(find.text('Home row 3'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(_state(tester).isBarVisible, isFalse);
    await tester.drag(find.text('Home row 8'), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(_state(tester).isBarVisible, isTrue);
  });

  testWidgets('sticky keeps the bar while scrolling', (tester) async {
    await tester.pumpWidget(_shell());
    await tester.drag(find.text('Home row 3'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(_state(tester).isBarVisible, isTrue);
  });

  testWidgets('floating mode extends pages behind the bar', (tester) async {
    await tester.pumpWidget(_shell(mode: WelkBottomNavMode.floating));
    final page = tester.element(find.byType(_CounterPage));
    expect(MediaQuery.paddingOf(page).bottom, greaterThan(64));
    expect(tester.getSize(find.byType(_CounterPage)).height, 600);
  });

  testWidgets('initialIndex and programmatic selection', (tester) async {
    await tester.pumpWidget(_shell(initialIndex: 3));
    expect(find.text('Inbox count 0'), findsOneWidget);
    _state(tester).select(4);
    await tester.pumpAndSettle();
    expect(find.text('Profile count 0'), findsOneWidget);
  });
}
