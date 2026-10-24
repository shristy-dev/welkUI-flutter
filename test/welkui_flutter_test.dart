import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

void main() {
  group('WelkButton', () {
    testWidgets('activates and restores its pressed state after release', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkButton(
            size: WelkButtonSize.small,
            onPressed: () => activations++,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final button = find.byType(WelkButton);
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(_buttonSurface()).height, lessThan(48));

      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump();
      expect(
        tester.widget<TweenAnimationBuilder<Offset>>(_buttonShadow()).tween.end,
        const Offset(1, 1),
      );
      expect(
        tester
            .widget<AnimatedContainer>(_buttonMotion())
            .transform!
            .getTranslation()
            .x,
        2,
      );
      await gesture.up();
      await tester.pump();
      expect(activations, 1);
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester.widget<TweenAnimationBuilder<Offset>>(_buttonShadow()).tween.end,
        const Offset(3, 3),
      );
      expect(
        tester
            .widget<AnimatedContainer>(_buttonMotion())
            .transform!
            .getTranslation()
            .x,
        0,
      );
    });

    testWidgets('quick tap visibly presses before returning to rest', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkButton(
            onPressed: () => activations++,
            child: const Text('Quick tap'),
          ),
        ),
      );
      final restingPosition = tester.getTopLeft(_buttonSurface());
      await tester.tap(find.byType(WelkButton));
      expect(activations, 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final pressedPosition = tester.getTopLeft(_buttonSurface());
      expect(pressedPosition.dx - restingPosition.dx, closeTo(2, 0.01));
      expect(pressedPosition.dy - restingPosition.dy, closeTo(2, 0.01));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(_buttonSurface()), restingPosition);
      expect(activations, 1);
    });

    testWidgets(
      'disabling or removing a pressed button cancels its animation',
      (tester) async {
        await tester.pumpWidget(
          _app(WelkButton(onPressed: () {}, child: const Text('Tap'))),
        );
        await tester.tap(find.byType(WelkButton));
        await tester.pump();
        await tester.pumpWidget(_app(const WelkButton(child: Text('Tap'))));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AnimatedContainer>(_buttonMotion())
              .transform!
              .getTranslation()
              .x,
          0,
        );
        await tester.pumpWidget(
          _app(WelkButton(onPressed: () {}, child: const Text('Tap'))),
        );
        await tester.tap(find.byType(WelkButton));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 240));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('null callback disables callback and pressed interaction', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const WelkButton(onPressed: null, child: Text('Disabled'))),
      );
      await tester.tap(find.byType(WelkButton));
      await tester.pump();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.55);
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes one labelled button semantics action', (tester) async {
      final semantics = tester.ensureSemantics();
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkButton(
            onPressed: () => activations++,
            child: const Text('Accessible action'),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Accessible action'), findsOneWidget);
      final node = tester.getSemantics(
        find.bySemanticsLabel('Accessible action'),
      );
      expect(
        node,
        isSemantics(
          label: 'Accessible action',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('cancel restores resting appearance without activation', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkButton(
            onPressed: () => activations++,
            child: const Text('Cancel'),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(WelkButton)),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pump();
      expect(activations, 0);
      expect(
        tester
            .widget<AnimatedContainer>(_buttonMotion())
            .transform!
            .getTranslation()
            .x,
        0,
      );
    });

    testWidgets('applies theme colors and reduced motion', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: WelkTheme(
            data: const WelkThemeData().copyWith(accent: Colors.pink),
            child: const MaterialApp(
              home: Scaffold(body: WelkButton(child: Text('Themed'))),
            ),
          ),
        ),
      );
      final visual = tester.widget<Container>(_buttonSurface());
      expect((visual.decoration! as ShapeDecoration).color, Colors.pink);
      expect(
        tester.widget<AnimatedContainer>(_buttonMotion()).duration,
        Duration.zero,
      );
      expect(
        tester.widget<TweenAnimationBuilder<Offset>>(_buttonShadow()).duration,
        Duration.zero,
      );
    });

    testWidgets('reduced motion returns immediately after a quick tap', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _app(
            WelkButton(
              onPressed: () => activations++,
              child: const Text('No animation'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WelkButton));
      await tester.pump();
      expect(activations, 1);
      expect(
        tester
            .widget<AnimatedContainer>(_buttonMotion())
            .transform!
            .getTranslation()
            .x,
        0,
      );
      expect(
        tester.widget<TweenAnimationBuilder<Offset>>(_buttonShadow()).tween.end,
        const Offset(3, 3),
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('keyboard focus reveals the ring and activates once', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkButton(
            onPressed: () => activations++,
            child: const Text('Keyboard action'),
          ),
        ),
      );
      final paintCountBeforeFocus = find.byType(CustomPaint).evaluate().length;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        find.byType(CustomPaint).evaluate().length,
        greaterThan(paintCountBeforeFocus),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activations, 1);
      await tester.pumpAndSettle();
    });
  });

  group('WelkSwitch', () {
    testWidgets(
      'thumb is centered and contained in both directions and states',
      (tester) async {
        for (final direction in TextDirection.values) {
          for (final value in [false, true]) {
            await tester.pumpWidget(
              _app(
                WelkSwitch(value: value, label: 'Centered', onChanged: (_) {}),
                textDirection: direction,
              ),
            );
            await tester.pumpAndSettle();
            final track = tester.getRect(
              find.descendant(
                of: find.byType(WelkSwitch),
                matching: find.byType(AnimatedContainer),
              ),
            );
            final thumb = tester.getRect(
              find.descendant(
                of: find.byType(WelkSwitch),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is DecoratedBox &&
                      widget.decoration is BoxDecoration,
                ),
              ),
            );
            expect(track.size, const Size(52, 28));
            expect(thumb.size, const Size(20, 20));
            expect(thumb.center.dy, track.center.dy);
            expect(thumb.left, greaterThanOrEqualTo(track.left + 2));
            expect(thumb.right, lessThanOrEqualTo(track.right - 2));
            final onRight = value != (direction == TextDirection.rtl);
            expect(thumb.left - track.left, onRight ? 28 : 4);
          }
        }
      },
    );

    testWidgets('is controlled and a label tap calls back once', (
      tester,
    ) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _app(
          WelkSwitch(
            value: false,
            label: 'Email updates',
            onChanged: changes.add,
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(WelkSwitch)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Email updates'));
      await tester.pump();
      expect(changes, [true]);
      await tester.pumpWidget(
        _app(
          WelkSwitch(
            value: changes.single,
            label: 'Email updates',
            onChanged: changes.add,
          ),
        ),
      );
      expect(
        tester
            .widget<AnimatedPositionedDirectional>(
              find.byType(AnimatedPositionedDirectional),
            )
            .start,
        28,
      );
    });

    testWidgets('disabled switch is inert and exposes disabled semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const WelkSwitch(value: true, label: 'Locked', onChanged: null)),
      );
      await tester.tap(find.text('Locked'));
      await tester.pump();
      expect(find.bySemanticsLabel('Locked'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('Locked'));
      expect(
        node,
        isSemantics(
          label: 'Locked',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      semantics.dispose();
    });

    testWidgets('switch can be toggled from the keyboard', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _app(
          WelkSwitch(
            value: false,
            label: 'Keyboard switch',
            onChanged: changes.add,
          ),
        ),
      );
      final paintCountBeforeFocus = find.byType(CustomPaint).evaluate().length;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        find.byType(CustomPaint).evaluate().length,
        greaterThan(paintCountBeforeFocus),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(changes, [true]);
    });

    testWidgets('has one switch semantics node and respects RTL', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          WelkSwitch(
            value: false,
            label: 'Right to left',
            onChanged: (_) => calls++,
          ),
          textDirection: TextDirection.rtl,
        ),
      );
      final nodes = tester.getSemantics(find.bySemanticsLabel('Right to left'));
      expect(nodes, isSemantics(label: 'Right to left', isToggled: false));
      final track = find.descendant(
        of: find.byType(WelkSwitch),
        matching: find.byType(AnimatedContainer),
      );
      final thumb = find.descendant(
        of: find.byType(WelkSwitch),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      expect(
        tester.getTopLeft(thumb).dx - tester.getTopLeft(track).dx,
        greaterThan(24),
      );
      expect(
        tester
            .widget<AnimatedPositionedDirectional>(
              find.byType(AnimatedPositionedDirectional),
            )
            .start,
        4,
      );
      await tester.tap(find.text('Right to left'));
      expect(calls, 1);
      semantics.dispose();
    });

    testWidgets('respects reduced motion and theme colors', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: WelkTheme(
            data: const WelkThemeData().copyWith(accent: Colors.pink),
            child: const MaterialApp(
              home: Scaffold(
                body: WelkSwitch(value: true, label: 'Themed', onChanged: null),
              ),
            ),
          ),
        ),
      );
      final track = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(WelkSwitch),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect((track.decoration! as ShapeDecoration).color, Colors.pink);
      expect(track.duration, Duration.zero);
      expect(
        tester
            .widget<AnimatedPositionedDirectional>(
              find.byType(AnimatedPositionedDirectional),
            )
            .duration,
        Duration.zero,
      );
    });
  });

  group('WelkCard', () {
    testWidgets('quick taps animate down and compress the shadow', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _app(
          WelkCard(
            title: 'Tap',
            subtitle: 'Feedback',
            onPressed: () => calls++,
          ),
        ),
      );
      final surface = find.descendant(
        of: find.byType(WelkCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container && widget.decoration is ShapeDecoration,
        ),
      );
      final restingPosition = tester.getTopLeft(surface);
      await tester.tap(find.byType(WelkCard));
      expect(calls, 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.getTopLeft(surface), restingPosition + const Offset(2, 2));
      expect(
        tester
            .widget<TweenAnimationBuilder<Offset>>(
              find.byType(TweenAnimationBuilder<Offset>),
            )
            .tween
            .end,
        const Offset(3, 3),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(surface), restingPosition);
    });

    testWidgets(
      'feedback opt-out and reduced motion retain immediate actions',
      (tester) async {
        for (final reducedMotion in [false, true]) {
          var calls = 0;
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(disableAnimations: reducedMotion),
              child: _app(
                WelkCard(
                  title: 'Tap',
                  subtitle: 'Feedback',
                  enableFeedback: reducedMotion,
                  onPressed: () => calls++,
                ),
              ),
            ),
          );
          await tester.tap(find.byType(WelkCard));
          await tester.pump();
          final motion = tester.widget<AnimatedContainer>(
            find.byType(AnimatedContainer),
          );
          expect(calls, 1);
          expect(motion.duration, Duration.zero);
          expect(motion.transform!.getTranslation().x, 0);
          expect(tester.binding.hasScheduledFrame, isFalse);
        }
      },
    );

    testWidgets('cancelled presses restore the card without activation', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _app(
          WelkCard(
            title: 'Tap',
            subtitle: 'Feedback',
            onPressed: () => calls++,
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(WelkCard)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester
            .widget<TweenAnimationBuilder<Offset>>(
              find.byType(TweenAnimationBuilder<Offset>),
            )
            .tween
            .end,
        const Offset(1, 1),
      );
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(
        tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer))
            .transform!
            .getTranslation()
            .x,
        0,
      );
    });

    testWidgets('feedback changes and disposal cancel pending releases', (
      tester,
    ) async {
      for (final disableAction in [false, true]) {
        await tester.pumpWidget(
          _app(WelkCard(title: 'Tap', subtitle: 'Feedback', onPressed: () {})),
        );
        await tester.tap(find.byType(WelkCard));
        await tester.pump();
        await tester.pumpWidget(
          _app(
            WelkCard(
              title: 'Tap',
              subtitle: 'Feedback',
              onPressed: () {},
              enabled: !disableAction,
              enableFeedback: disableAction,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .transform!
              .getTranslation()
              .x,
          0,
        );
      }
      await tester.pumpWidget(
        _app(WelkCard(title: 'Tap', subtitle: 'Feedback', onPressed: () {})),
      );
      await tester.tap(find.byType(WelkCard));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 240));
      expect(tester.takeException(), isNull);
    });

    testWidgets('activates only when interactive', (tester) async {
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkCard(
            title: 'Action',
            subtitle: 'Open the item.',
            onPressed: () => activations++,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(WelkCard)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.byType(WelkCard));
      expect(activations, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('keyboard activation works and focus is visibly outlined', (
      tester,
    ) async {
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkCard(
            title: 'Keyboard card',
            subtitle: 'Activate from the keyboard.',
            onPressed: () => activations++,
          ),
        ),
      );
      final paintCountBeforeFocus = find.byType(CustomPaint).evaluate().length;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        find.byType(CustomPaint).evaluate().length,
        greaterThan(paintCountBeforeFocus),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activations, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('informational card has no button semantics or dimming', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const WelkCard(title: 'Notice', subtitle: 'Details')),
      );
      expect(find.bySemanticsLabel('Notice'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('Notice'));
      expect(node, isSemantics(label: 'Notice', isButton: false));
      expect(find.byType(Opacity), findsNothing);
      semantics.dispose();
    });

    testWidgets('explicitly disabled action stays inert and dimmed', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var activations = 0;
      await tester.pumpWidget(
        _app(
          WelkCard(
            title: 'Disabled',
            subtitle: 'Not available',
            enabled: false,
            onPressed: () => activations++,
          ),
        ),
      );
      await tester.tap(find.byType(WelkCard));
      expect(activations, 0);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.55);
      final node = tester.getSemantics(
        find.bySemanticsLabel('Disabled. Not available'),
      );
      expect(
        node,
        isSemantics(
          label: 'Disabled. Not available',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      semantics.dispose();
    });
  });

  testWidgets('large text and narrow RTL layout do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(280, 800),
          textScaler: TextScaler.linear(2),
        ),
        child: _app(
          const SingleChildScrollView(
            child: Column(
              children: [
                WelkButton(child: Text('A long action label')),
                WelkSwitch(
                  value: false,
                  label: 'A narrow switch label',
                  onChanged: null,
                ),
                WelkCard(
                  title: 'A long title that should wrap',
                  subtitle: 'A longer subtitle that should wrap without overlapping its icon.',
                  icon: Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          width: 240,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _app(Widget child, {double? width, TextDirection? textDirection}) {
  final content = SizedBox(width: width, child: child);
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: textDirection == null
            ? content
            : Directionality(textDirection: textDirection, child: content),
      ),
    ),
  );
}

Finder _buttonSurface() => find.descendant(
  of: find.byType(WelkButton),
  matching: find.byWidgetPredicate(
    (widget) => widget is Container && widget.decoration is ShapeDecoration,
  ),
);

Finder _buttonMotion() => find.descendant(
  of: find.byType(WelkButton),
  matching: find.byWidgetPredicate(
    (widget) => widget is AnimatedContainer && widget.decoration == null,
  ),
);

Finder _buttonShadow() => find.descendant(
  of: find.byType(WelkButton),
  matching: find.byType(TweenAnimationBuilder<Offset>),
);
