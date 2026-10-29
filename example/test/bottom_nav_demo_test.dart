import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';
import 'package:welkui_flutter_example/main.dart';

void main() {
  testWidgets('bottom nav demo launches, keeps state, hides on subpages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/bottom-nav';
    addTearDown(tester.view.reset);
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await tester.pumpWidget(const WelkExampleApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Launch demo app'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Launch demo app'));
    await tester.pumpAndSettle();

    WelkBottomNavScaffoldState shell() =>
        tester.state(find.byType(WelkBottomNavScaffold));
    Finder tab(String label) => find.descendant(
      of: find.byType(WelkBottomNavBar),
      matching: find.text(label),
    );

    await tester.tap(find.text('Tapped 0 times'));
    await tester.pump();
    await tester.tap(tab('Create'));
    await tester.pumpAndSettle();
    expect(find.text('0 stickers created'), findsOneWidget);
    await tester.tap(tab('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tapped 1 times'), findsOneWidget);

    await tester.tap(find.text('Story #1'));
    await tester.pumpAndSettle();
    expect(find.text('Story #1 details'), findsOneWidget);
    expect(shell().isBarVisible, isFalse);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(shell().isBarVisible, isTrue);
    expect(shell().currentIndex, 0);
    expect(tester.takeException(), isNull);
  });
}
