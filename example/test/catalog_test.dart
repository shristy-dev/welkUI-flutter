import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';
import 'package:welkui_flutter_example/main.dart';
import 'package:welkui_flutter_example/widget_catalog.dart';

void main() {
  test('all 32 reference components have unique names and preview routes', () {
    expect(widgetCatalog, hasLength(32));
    expect(widgetCatalog.map((item) => item.name).toSet(), hasLength(32));
    expect(widgetCatalog.map((item) => item.route).toSet(), hasLength(32));
  });

  for (final item in widgetCatalog) {
    for (final darkMode in [false, true]) {
      testWidgets(
        '${item.name} has a narrow, scrollable preview (dark=$darkMode)',
        (tester) async {
          tester.view.physicalSize = const Size(320, 740);
          tester.view.devicePixelRatio = 1;
          tester.binding.platformDispatcher.defaultRouteNameTestValue =
              item.route;
          tester.binding.platformDispatcher.textScaleFactorTestValue = 1.5;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(
            tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
          );
          addTearDown(
            tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
          );
          await tester.pumpWidget(WelkExampleApp(embedMode: !darkMode));
          await tester.pumpAndSettle();
          if (darkMode) {
            await tester.tap(find.bySemanticsLabel('Switch to dark mode'));
            await tester.pumpAndSettle();
            expect(
              WelkTheme.of(tester.element(find.byType(Scaffold))).darkMode,
              isTrue,
            );
          }
          expect(find.byType(AppBar), darkMode ? findsOneWidget : findsNothing);
          expect(find.byType(item.screen.runtimeType), findsOneWidget);
          expect(tester.takeException(), isNull);
          final list = find.byType(ListView).first;
          final scrollable = tester.state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)).first,
          );
          // Visit lazily laid out content, not just the first viewport.
          for (var step = 0; step < 30; step++) {
            if (scrollable.position.pixels >=
                scrollable.position.maxScrollExtent) {
              break;
            }
            // Stay in the page gutter instead of dragging nested picker wheels.
            final bounds = tester.getRect(list);
            await tester.dragFrom(
              bounds.topLeft + Offset(8, bounds.height * 0.75),
              const Offset(0, -400),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          expect(
            scrollable.position.pixels,
            closeTo(scrollable.position.maxScrollExtent, 1),
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
