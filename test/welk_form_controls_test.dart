import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/src/widgets/welk_check_box.dart';
import 'package:welkui_flutter/src/widgets/welk_drop_down.dart';
import 'package:welkui_flutter/src/widgets/welk_input.dart';
import 'package:welkui_flutter/src/widgets/welk_otp_input.dart';
import 'package:welkui_flutter/src/widgets/welk_radio.dart';
import 'package:welkui_flutter/src/widgets/welk_radio_group.dart';
import 'package:welkui_flutter/src/widgets/welk_range_slider.dart';

// Exercise the demos without adding the example package as a test dependency.
// ignore: avoid_relative_lib_imports
import '../example/lib/screens/form_controls_screen.dart';

Widget _app(Widget child, {bool rtl = false, double scale = 1}) => MaterialApp(
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(
        size: const Size(800, 600),
        textScaler: TextScaler.linear(scale),
        disableAnimations: true,
      ),
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [child],
          ),
        ),
      ),
    ),
  ),
);

const _radios = [
  WelkRadioOption(value: 'hero', label: 'Hero'),
  WelkRadioOption(value: 'villain', label: 'Villain', disabled: true),
  WelkRadioOption(value: 'sidekick', label: 'Sidekick'),
];
const _heroes = [
  WelkDropDownOption(value: 'hero', label: 'Hero'),
  WelkDropDownOption(value: 'villain', label: 'Villain', disabled: true),
  WelkDropDownOption(value: 'sidekick', label: 'Sidekick'),
];

Finder _popupBarrier() => find.byWidgetPredicate(
  (widget) => widget is ModalBarrier && widget.dismissible,
);

void main() {
  testWidgets('checkbox emits once and remains controlled', (tester) async {
    final values = <bool>[];
    await tester.pumpWidget(
      _app(WelkCheckBox(label: 'Join', value: false, onChanged: values.add)),
    );
    expect(tester.getSize(find.byType(WelkCheckBox)).height, 48);
    await tester.tap(find.text('Join'));
    expect(values, [true]);
    expect(
      tester.widget<WelkCheckBox>(find.byType(WelkCheckBox)).value,
      isFalse,
    );
    await tester.pumpWidget(
      _app(WelkCheckBox(label: 'Join', value: true, onChanged: values.add)),
    );
    await tester.tap(find.text('Join'));
    expect(values, [true, false]);
  });

  testWidgets('checkbox mixed state and keyboard activate exactly once', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final values = <bool>[];
    await tester.pumpWidget(
      _app(
        WelkCheckBox(
          label: 'Select all',
          value: false,
          indeterminate: true,
          onChanged: values.add,
          focusNode: focus,
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(values, [true]);
  });

  testWidgets('checkbox exposes one semantics action and disables it', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var calls = 0;
    await tester.pumpWidget(
      _app(WelkCheckBox(label: 'Join', value: true, onChanged: (_) => calls++)),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Join'));
    expect(node.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
    node.owner!.performAction(node.id, ui.SemanticsAction.tap);
    expect(calls, 1);
    await tester.pumpWidget(
      _app(
        WelkCheckBox(
          label: 'Join',
          value: true,
          disabled: true,
          onChanged: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('Join'));
    expect(calls, 1);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Join'))
          .getSemanticsData()
          .hasAction(ui.SemanticsAction.tap),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('radio ignores selected and disabled activation', (tester) async {
    var calls = 0;
    for (final selected in [false, true]) {
      await tester.pumpWidget(
        _app(
          WelkRadio(
            label: 'Hero',
            selected: selected,
            onChanged: (_) => calls++,
          ),
        ),
      );
      await tester.tap(find.text('Hero'));
    }
    expect(calls, 1);
    await tester.pumpWidget(
      _app(
        WelkRadio(
          label: 'Hero',
          selected: false,
          disabled: true,
          onChanged: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('Hero'));
    expect(calls, 1);
  });

  testWidgets(
    'radio group updates, skips disabled and wraps arrow navigation',
    (tester) async {
      String? value = 'hero';
      final calls = <String>[];
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => WelkRadioGroup(
              label: 'Role',
              options: _radios,
              value: value,
              onChanged: (v) {
                calls.add(v);
                setState(() => value = v);
              },
            ),
          ),
        ),
      );
      final hero = tester.widget<WelkRadio>(
        find.widgetWithText(WelkRadio, 'Hero'),
      );
      hero.focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'sidekick');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(calls, ['sidekick', 'hero']);
      await tester.tap(find.text('Villain'));
      expect(calls.length, 2);
    },
  );

  testWidgets('disabled radio group cannot change any option', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        WelkRadioGroup(
          label: 'Role',
          options: _radios,
          value: 'hero',
          disabled: true,
          onChanged: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('Sidekick'));
    expect(calls, 0);
  });

  testWidgets('input edits, controlled replacement and trailing action', (
    tester,
  ) async {
    var value = '';
    final calls = <String>[];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => WelkInput(
            label: 'Name',
            value: value,
            onChanged: (v) {
              calls.add(v);
              setState(() => value = v);
            },
            endAction: WelkInputAction(
              label: 'Clear name',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => value = ''),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Captain');
    await tester.pump();
    expect(calls, ['Captain']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Captain',
    );
    await tester.tap(find.byTooltip('Clear name'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(calls.length, 1);
  });

  testWidgets('input rejects unaccepted controlled edits', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(
      _app(WelkInput(label: 'Name', value: 'fixed', onChanged: calls.add)),
    );
    await tester.enterText(find.byType(TextField), 'rejected');
    await tester.pump();
    expect(calls, ['rejected']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'fixed',
    );
  });

  testWidgets('input password, read-only, disabled and error semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var calls = 0;
    await tester.pumpWidget(
      _app(
        WelkInput(
          label: 'Secret',
          value: 'code',
          type: WelkInputType.password,
          readOnly: true,
          invalid: true,
          errorText: 'Try again',
          onChanged: (_) => calls++,
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
    expect(field.readOnly, isTrue);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.bySemanticsLabel('Secret'), findsWidgets);
    await tester.pumpWidget(
      _app(
        WelkInput(
          label: 'Disabled',
          value: '',
          disabled: true,
          onChanged: (_) => calls++,
          endAction: WelkInputAction(
            label: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: () => calls++,
          ),
        ),
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.tap(find.byTooltip('Clear'));
    expect(calls, 0);
    semantics.dispose();
  });

  testWidgets('OTP filters pasted input and completes exactly once', (
    tester,
  ) async {
    var value = '';
    final changes = <String>[];
    final completions = <String>[];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => WelkOTPInput(
            label: 'Code',
            value: value,
            length: 4,
            onChanged: (v) {
              changes.add(v);
              setState(() => value = v);
            },
            onComplete: completions.add,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'a1 2-345');
    await tester.pump();
    expect(value, '1234');
    expect(changes, ['1234']);
    expect(completions, ['1234']);
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    expect(completions, ['1234']);
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(value, '123');
    expect(completions.length, 1);
  });

  testWidgets('OTP stays controlled and supports programmatic values', (
    tester,
  ) async {
    final values = <String>[];
    await tester.pumpWidget(
      _app(WelkOTPInput(label: 'Code', value: '12', onChanged: values.add)),
    );
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(values, ['123']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '12',
    );
    await tester.pumpWidget(
      _app(WelkOTPInput(label: 'Code', value: '9876', onChanged: values.add)),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '9876',
    );
    expect(values.length, 1);
  });

  testWidgets('OTP has one editable semantics field and disabled editor', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const WelkOTPInput(label: 'Verification', value: '123', disabled: true),
      ),
    );
    expect(find.bySemanticsLabel('Verification'), findsWidgets);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.byType(EditableText), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('dropdown mobile popup selects once and remains controlled', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      _app(
        WelkDropDown(
          label: 'Role',
          options: _heroes,
          value: null,
          onChanged: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Villain'));
    await tester.pump();
    expect(changes, isEmpty);
    expect(find.text('Sidekick'), findsOneWidget);
    await tester.tap(find.text('Sidekick'));
    await tester.pumpAndSettle();
    expect(changes, ['sidekick']);
    expect(find.text('Select an option'), findsOneWidget);
  });

  testWidgets('dropdown searchable filters, reports no results and dismisses', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      _app(
        WelkDropDown(
          label: 'Role',
          options: _heroes,
          value: 'hero',
          searchable: true,
          onChanged: changes.add,
        ),
      ),
    );
    await tester.tap(find.text('Hero'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'no matching hero');
    await tester.pump();
    expect(find.text('No results found'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'side');
    await tester.pump();
    expect(find.text('Sidekick'), findsOneWidget);
    await tester.tap(find.text('Sidekick'));
    await tester.pumpAndSettle();
    expect(changes, ['sidekick']);
    expect(find.text('Hero'), findsOneWidget);
    await tester.tap(find.text('Hero'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(changes.length, 1);
  });

  testWidgets('dropdown keyboard skips disabled and selects active option', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final changes = <String>[];
    await tester.pumpWidget(
      _app(
        WelkDropDown(
          label: 'Role',
          options: _heroes,
          value: 'hero',
          focusNode: focus,
          onChanged: changes.add,
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes, ['sidekick']);
  });

  testWidgets('disabled dropdown cannot open', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        WelkDropDown(
          label: 'Role',
          options: _heroes,
          value: null,
          disabled: true,
          onChanged: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    expect(find.text('Sidekick'), findsNothing);
    expect(calls, 0);
  });

  testWidgets('dropdown Tab and Shift-Tab continue outside popup', (
    tester,
  ) async {
    final before = FocusNode();
    final select = FocusNode();
    final after = FocusNode();
    addTearDown(before.dispose);
    addTearDown(select.dispose);
    addTearDown(after.dispose);
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            WelkInput(
              label: 'Before',
              value: '',
              focusNode: before,
              onChanged: (_) {},
            ),
            WelkDropDown(
              label: 'Role',
              options: _heroes,
              value: null,
              focusNode: select,
              searchable: true,
              onChanged: (_) {},
            ),
            WelkInput(
              label: 'After',
              value: '',
              focusNode: after,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    select.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(after.hasFocus, isTrue);
    select.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(before.hasFocus, isTrue);
  });

  testWidgets(
    'search popup fits narrow mobile keyboard and reveals long-list End',
    (tester) async {
      tester.view.physicalSize = const Size(280, 600);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final values = <String>[];
      await tester.pumpWidget(
        _app(
          WelkDropDown(
            label: 'Team',
            searchable: true,
            value: null,
            options: [
              for (var i = 0; i < 30; i++)
                WelkDropDownOption(value: '$i', label: 'Hero $i'),
            ],
            onChanged: values.add,
          ),
          scale: 2,
          rtl: true,
        ),
      );
      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(find.text('Hero 29').hitTestable(), findsOneWidget);
      final last = tester.getRect(find.text('Hero 29'));
      expect(last.bottom, lessThanOrEqualTo(380));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(values, ['29']);
    },
  );

  testWidgets('dropdown parent accepts value and disabled state is respected', (
    tester,
  ) async {
    String? value;
    var disabled = false;
    late StateSetter update;
    var calls = 0;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return WelkDropDown(
              label: 'Role',
              options: _heroes,
              value: value,
              disabled: disabled,
              onChanged: (v) {
                calls++;
                setState(() => value = v);
              },
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sidekick'));
    await tester.pumpAndSettle();
    expect(value, 'sidekick');
    expect(find.text('Sidekick'), findsOneWidget);
    await tester.tap(find.text('Sidekick'));
    await tester.pumpAndSettle();
    update(() => disabled = true);
    await tester.pumpAndSettle();
    expect(find.text('Hero'), findsNothing);
    expect(calls, 1);
    expect(value, 'sidekick');
  });

  testWidgets('dropdown dismisses when parent removes an open option', (
    tester,
  ) async {
    final options = List<WelkDropDownOption>.of(_heroes);
    late StateSetter update;
    final calls = <String>[];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return WelkDropDown(
              label: 'Role',
              options: options,
              value: null,
              onChanged: calls.add,
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    expect(find.text('Sidekick'), findsOneWidget);
    // In-place list changes must be detected as well as replacement lists.
    update(() => options.removeWhere((o) => o.value == 'sidekick'));
    await tester.pumpAndSettle();
    expect(find.text('Sidekick'), findsNothing);
    expect(find.text('Hero'), findsNothing);
    expect(calls, isEmpty);
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    expect(find.text('Sidekick'), findsNothing);
    await tester.tap(find.text('Hero'));
    await tester.pumpAndSettle();
    expect(calls, ['hero']);
  });

  for (final change in ['value', 'disabled', 'option disabled']) {
    testWidgets('dropdown dismisses when parent changes $change', (
      tester,
    ) async {
      late StateSetter update;
      String? value;
      var disabled = false;
      var options = _heroes;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return WelkDropDown(
                label: 'Role',
                options: options,
                value: value,
                disabled: disabled,
                onChanged: (_) => fail('Dismissal must not emit a selection'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();
      update(() {
        if (change == 'value') value = 'hero';
        if (change == 'disabled') disabled = true;
        if (change == 'option disabled') {
          options = [
            const WelkDropDownOption(
              value: 'hero',
              label: 'Hero',
              disabled: true,
            ),
            ..._heroes.skip(1),
          ];
        }
      });
      await tester.pumpAndSettle();
      expect(find.text('Sidekick'), findsNothing);
      expect(_popupBarrier(), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'removing dropdown owner removes popup and barrier, not other UI',
    (tester) async {
      late StateSetter update;
      var show = true;
      var taps = 0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Column(
                children: [
                  if (show)
                    WelkDropDown(
                      label: 'Role',
                      options: _heroes,
                      value: null,
                      onChanged: (_) => fail('Disposed owner must not emit'),
                    ),
                  TextButton(
                    onPressed: () => taps++,
                    child: const Text('Other UI'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();
      expect(find.text('Sidekick'), findsOneWidget);
      update(() => show = false);
      await tester.pumpAndSettle();
      expect(find.text('Sidekick'), findsNothing);
      expect(_popupBarrier(), findsNothing);
      await tester.tap(find.text('Other UI'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('removing popup owner does not pop a covering unrelated route', (
    tester,
  ) async {
    late StateSetter update;
    var show = true;
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return show
                  ? WelkDropDown(
                      label: 'Role',
                      options: _heroes,
                      value: null,
                      onChanged: (_) => fail('Disposed owner must not emit'),
                    )
                  : const Text('Owner removed');
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Unrelated page')),
      ),
    );
    await tester.pumpAndSettle();
    update(() => show = false);
    await tester.pumpAndSettle();
    expect(find.text('Unrelated page'), findsOneWidget);
    expect(tester.takeException(), isNull);
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Owner removed'), findsOneWidget);
    expect(find.text('Sidekick'), findsNothing);
    expect(_popupBarrier(), findsNothing);
  });

  testWidgets('slider pointer snaps to steps and does not move itself', (
    tester,
  ) async {
    final values = <double>[];
    await tester.pumpWidget(
      _app(
        WelkRangeSlider(
          label: 'Power',
          value: 4,
          min: 0,
          max: 10,
          step: 2,
          onChanged: values.add,
        ),
      ),
    );
    final gesture = find.descendant(
      of: find.byType(WelkRangeSlider),
      matching: find.byType(GestureDetector),
    );
    final rect = tester.getRect(gesture);
    await tester.tapAt(Offset(rect.right - 2, rect.center.dy));
    expect(values, [10]);
    expect(
      tester.widget<WelkRangeSlider>(find.byType(WelkRangeSlider)).value,
      4,
    );
    expect(rect.height, 48);
  });

  testWidgets('slider keyboard clamps, steps and reverses horizontal RTL', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var value = 4.0;
    final values = <double>[];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => WelkRangeSlider(
            label: 'Power',
            value: value,
            min: 0,
            max: 10,
            step: 2,
            focusNode: focus,
            onChanged: (v) {
              values.add(v);
              setState(() => value = v);
            },
          ),
        ),
        rtl: true,
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(value, 10);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(values, [2, 10]);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(value, 0);
  });

  testWidgets('slider semantics adjusts once and disabled has no actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final values = <double>[];
    await tester.pumpWidget(
      _app(WelkRangeSlider(label: 'Power', value: 4, onChanged: values.add)),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Power').last);
    node.owner!.performAction(node.id, ui.SemanticsAction.increase);
    expect(values, [5]);
    await tester.pumpWidget(
      _app(const WelkRangeSlider(label: 'Power', value: 4)),
    );
    final disabled = tester.getSemantics(find.bySemanticsLabel('Power').last);
    expect(
      disabled.getSemanticsData().hasAction(ui.SemanticsAction.increase),
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('all controls fit narrow RTL viewports with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WelkCheckBox(
              label: 'A long checkbox label that wraps',
              value: true,
              onChanged: (_) {},
            ),
            WelkRadio(
              label: 'A long radio label that wraps',
              selected: true,
              onChanged: (_) {},
            ),
            WelkRadioGroup(
              label: 'Team',
              options: _radios,
              value: 'hero',
              onChanged: (_) {},
            ),
            WelkInput(label: 'Name', value: 'Captain', onChanged: (_) {}),
            WelkOTPInput(label: 'Code', value: '123456', onChanged: (_) {}),
            WelkDropDown(
              label: 'Hero',
              options: _heroes,
              value: null,
              onChanged: (_) {},
            ),
            WelkRangeSlider(label: 'Power', value: 50, onChanged: (_) {}),
          ],
        ),
        rtl: true,
        scale: 2,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    for (final type in [
      WelkInput,
      WelkOTPInput,
      WelkDropDown,
      WelkRangeSlider,
    ]) {
      expect(tester.getSize(find.byType(type)).width, lessThanOrEqualTo(248));
    }
  });

  for (final screen in <Widget>[
    const CheckBoxScreen(),
    const RadioScreen(),
    const RadioGroupScreen(),
    const InputScreen(),
    const OTPInputScreen(),
    const DropDownScreen(),
    const RangeSliderScreen(),
  ]) {
    testWidgets('${screen.runtimeType} demo fits compact large-text mobile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(280, 800),
              textScaler: TextScaler.linear(1.7),
              disableAnimations: true,
            ),
            child: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.fling(
        find.byType(ListView).first,
        const Offset(0, -1600),
        1600,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
