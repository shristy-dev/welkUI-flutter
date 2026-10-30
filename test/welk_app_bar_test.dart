import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

void main() {
  for (final layout in WelkAppBarLayout.values) {
    for (final floating in [false, true]) {
      for (final dark in [false, true]) {
        testWidgets('$layout floating=$floating dark=$dark narrow branding', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 740);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          var taps = 0;
          await tester.pumpWidget(
            WelkTheme(
              data: WelkThemeData(darkMode: dark),
              child: MaterialApp(
                home: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: Scaffold(
                    appBar: WelkAppBar(
                      title: 'A very long comic adventure title',
                      layout: layout,
                      floating: floating,
                      logo: const Icon(Icons.bolt),
                      logoPosition: WelkAppBarLogoPosition.center,
                      leading: const BackButton(),
                      actions: [
                        for (var i = 0; i < 3; i++)
                          IconButton(
                            tooltip: 'Action $i',
                            onPressed: () => taps++,
                            icon: const Icon(Icons.star),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Action 2'));
          expect(taps, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('custom title and centered branding in RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: const WelkAppBar(
              titleWidget: Text('Custom'),
              logo: Icon(Icons.bolt),
              logoPosition: WelkAppBarLogoPosition.center,
              floating: true,
            ),
          ),
        ),
      ),
    );
    final titleRect = tester.getRect(find.text('Custom'));
    final logoRect = tester.getRect(find.byIcon(Icons.bolt));
    expect(logoRect.left, greaterThan(titleRect.right));
    expect((logoRect.right + titleRect.left) / 2, closeTo(400, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('preferred height and top safe area are reserved once', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.reset);
    const appBar = WelkAppBar(title: 'Safe', floating: true);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: appBar, body: Text('Body')),
      ),
    );
    expect(appBar.preferredSize.height, 88);
    expect(tester.getTopLeft(find.text('Body')).dy, 112);
  });

  for (final pinned in [false, true]) {
    testWidgets('sliver pinned=$pinned', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                WelkSliverAppBar(
                  pinned: pinned,
                  appBar: const WelkAppBar(
                    title: 'Scroll header',
                    floating: true,
                  ),
                ),
                SliverList.builder(
                  itemCount: 60,
                  itemBuilder: (_, i) =>
                      SizedBox(height: 60, child: Text('Row $i')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.drag(find.text('Row 3'), const Offset(0, -400));
      await tester.pumpAndSettle();
      if (pinned) {
        expect(
          tester.getRect(find.text('Scroll header')).bottom,
          greaterThan(0),
        );
      } else {
        expect(find.text('Scroll header').hitTestable(), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('automatic back button pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(appBar: WelkAppBar(title: 'Details')),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
  });
}
