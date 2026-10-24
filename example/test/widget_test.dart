import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';
import 'package:welkui_flutter_example/main.dart';

void main() {
  for (final embedMode in [false, true]) {
    for (final route in ['/button', '/switch', '/card', '/menu']) {
      testWidgets('deep link $route with embedMode=$embedMode', (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1;
        tester.binding.platformDispatcher.defaultRouteNameTestValue = route;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(
          tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
        );
        await tester.pumpWidget(WelkExampleApp(embedMode: embedMode));
        await tester.pumpAndSettle();
        expect(find.byType(AppBar), embedMode ? findsNothing : findsOneWidget);
        expect(
          find.byType(BackButton),
          embedMode ? findsNothing : findsOneWidget,
        );
        expect(
          find.text(
            {
              '/button': 'Button activations: 0',
              '/switch': 'Notifications: on',
              '/card': 'Card activations: 0',
              '/menu': 'Selected route: /home',
            }[route]!,
          ),
          findsOneWidget,
        );
        expect(find.byType(ListView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('embed home has no navigation away from the preview', (
    tester,
  ) async {
    await tester.pumpWidget(const WelkExampleApp(embedMode: true));
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(WelkMenu), findsNothing);
  });

  testWidgets('initial menu navigates to every widget screen and back', (
    tester,
  ) async {
    await tester.pumpWidget(const WelkExampleApp());
    expect(find.text('WelkUI Flutter'), findsOneWidget);
    for (final title in ['WelkButton', 'WelkSwitch', 'WelkCard', 'WelkMenu']) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, title), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('WelkUI Flutter'), findsOneWidget);
    }
  });

  testWidgets(
    'button route includes every variant and size with working state',
    (tester) async {
      await tester.pumpWidget(const WelkExampleApp());
      await tester.tap(find.text('WelkButton'));
      await tester.pumpAndSettle();
      for (final variant in WelkButtonVariant.values) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is WelkButton &&
                widget.variant == variant &&
                widget.onPressed != null,
          ),
          findsWidgets,
        );
      }
      for (final size in WelkButtonSize.values) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is WelkButton && widget.size == size,
          ),
          findsWidgets,
        );
      }
      await tester.tap(find.text('Primary'));
      await tester.pumpAndSettle();
      expect(find.text('Button activations: 1'), findsOneWidget);
    },
  );

  testWidgets('switch route updates its parent-owned value', (tester) async {
    await tester.pumpWidget(const WelkExampleApp());
    await tester.tap(find.text('WelkSwitch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications: off'), findsOneWidget);
    expect(find.text('Disabled on'), findsOneWidget);
    expect(find.text('Disabled off'), findsOneWidget);
  });

  testWidgets('card screen includes feedback and disabled examples', (
    tester,
  ) async {
    await tester.pumpWidget(const WelkExampleApp());
    await tester.tap(find.text('WelkCard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your workspace'));
    await tester.pumpAndSettle();
    expect(find.text('Card activations: 1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Temporarily unavailable'), 200);
    await tester.tap(find.text('Temporarily unavailable'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu screen presents all reference variants', (tester) async {
    await tester.pumpWidget(const WelkExampleApp());
    await tester.tap(find.text('WelkMenu'));
    await tester.pumpAndSettle();
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Nested'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Active route'), 200);
    expect(find.text('Collapsible'), findsOneWidget);
    expect(find.text('Active route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
