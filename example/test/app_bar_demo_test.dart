import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';
import 'package:welkui_flutter_example/main.dart';

void main() {
  testWidgets('app bar demo launches with chosen floating and pinned options', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/app-bar';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await tester.pumpWidget(const WelkExampleApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Floating card'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Floating card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Floating card'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pinned while scrolling'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pinned while scrolling'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Launch app bar demo'));
    await tester.tap(find.text('Launch app bar demo'));
    await tester.pumpAndSettle();

    final sliver = tester.widget<WelkSliverAppBar>(
      find.byType(WelkSliverAppBar),
    );
    expect(sliver.pinned, isFalse);
    expect(sliver.appBar.floating, isFalse);
    expect(sliver.appBar.title, 'WelkUI');
    final logo = tester.widget<Image>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Image && widget.semanticLabel == 'WelkUI logo',
          )
          .last,
    );
    expect(
      logo.image,
      const AssetImage(
        'assets/images/welkui-logo.png',
        package: 'welkui_flutter',
      ),
    );
    await tester.tap(find.byTooltip('Show message'));
    await tester.pumpAndSettle();
    expect(find.text('Ready for adventure!'), findsOneWidget);
    await tester.drag(find.text('Panel 2'), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('WelkUI').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
