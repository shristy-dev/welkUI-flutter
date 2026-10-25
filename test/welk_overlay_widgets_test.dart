import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/src/theme/welk_theme.dart';
import 'package:welkui_flutter/src/widgets/welk_attachment.dart';
import 'package:welkui_flutter/src/widgets/welk_button.dart';
import 'package:welkui_flutter/src/widgets/welk_dialog.dart';
import 'package:welkui_flutter/src/widgets/welk_drawer.dart';
import 'package:welkui_flutter/src/widgets/welk_icon_button.dart';
import 'package:welkui_flutter/src/widgets/welk_snack_bar.dart';
import 'package:welkui_flutter/src/widgets/welk_tooltip.dart';

// The example is a separate app, not a dependency of this package.
// ignore: avoid_relative_lib_imports
import '../example/lib/screens/overlay_widgets_screen.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(800, 600),
      disableAnimations: reduced,
    ),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  for (final drawer in [false, true]) {
    testWidgets('${drawer ? 'drawer' : 'dialog'} supports TextField editing', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => WelkButton(
              onPressed: () {
                if (drawer) {
                  showWelkDrawer<void>(
                    context: context,
                    builder: (_) => const WelkDrawer(
                      title: Text('Edit'),
                      child: TextField(),
                    ),
                  );
                } else {
                  showWelkDialog<void>(
                    context: context,
                    builder: (_) => const WelkDialog(
                      title: Text('Edit'),
                      child: TextField(),
                    ),
                  );
                }
              },
              child: const Text('Open editor'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'Mission updated');
      await tester.pump();
      expect(find.text('Mission updated'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    });
  }

  for (final clear in [false, true]) {
    testWidgets(
      'attachment ${clear ? 'clear' : 'reset'} invalidates selection',
      (tester) async {
        final form = GlobalKey<FormState>();
        final first = Completer<List<WelkAttachmentFile>?>();
        final second = Completer<List<WelkAttachmentFile>?>();
        var selections = 0;
        final changes = <List<WelkAttachmentFile>>[];
        await tester.pumpWidget(
          host(
            Form(
              key: form,
              child: WelkAttachment(
                label: const Text('Files'),
                initialFiles: clear
                    ? const [WelkAttachmentFile(name: 'existing', size: 1)]
                    : const [],
                onSelectFiles: () =>
                    selections++ == 0 ? first.future : second.future,
                onFilesChange: changes.add,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Choose files'));
        await tester.pump();
        if (clear) {
          await tester.tap(find.text('Clear attachments'));
        } else {
          form.currentState!.reset();
        }
        await tester.pump();
        expect(find.text('Choose files'), findsOneWidget);
        await tester.tap(find.text('Choose files'));
        await tester.pump();
        first.complete(const [WelkAttachmentFile(name: 'stale', size: 1)]);
        await tester.pump();
        expect(find.text('stale'), findsNothing);
        expect(changes.length, clear ? 1 : 0);
        expect(find.text('Selecting files…'), findsOneWidget);
        second.complete(const [WelkAttachmentFile(name: 'current', size: 1)]);
        await tester.pumpAndSettle();
        expect(find.text('current'), findsOneWidget);
        expect(changes.last.single.name, 'current');
        expect(changes.length, clear ? 2 : 1);
      },
    );
  }

  for (final closing in [false, true]) {
    testWidgets('snackbar owner teardown completes closed, closing=$closing', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (value) {
              context = value;
              return const Text('Owner');
            },
          ),
        ),
      );
      final notification = showWelkSnackBar(
        context: context,
        message: const Text('Owned notification'),
      );
      await tester.pumpAndSettle();
      var completed = false;
      notification.closed.then((_) => completed = true);
      if (closing) {
        notification.close();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(completed, isTrue);
      notification.close();
      notification.close();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  for (final screen in <Widget>[
    const DialogScreen(),
    const DrawerScreen(),
    const TooltipScreen(),
    const SnackBarScreen(),
    const AttachmentScreen(),
    const IconButtonScreen(),
  ]) {
    testWidgets('${screen.runtimeType} renders at 320px', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (var step = 0; step < 8; step++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('icon action has a 48px target, semantics and disabled state', (
    tester,
  ) async {
    var calls = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        WelkIconButton(
          icon: const Icon(Icons.add),
          label: 'Add item',
          onPressed: () => calls++,
        ),
      ),
    );
    final size = tester.getSize(find.byType(WelkIconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.bySemanticsLabel('Add item'), findsOneWidget);
    await tester.tap(find.byType(WelkIconButton));
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.pumpWidget(
      host(
        const WelkIconButton(
          icon: Icon(Icons.add),
          label: 'Add item',
          variant: WelkIconButtonVariant.text,
        ),
      ),
    );
    expect(find.text('Add item'), findsOneWidget);
    await tester.tap(find.byType(WelkIconButton));
    expect(calls, 1);
    semantics.dispose();
  });

  testWidgets('icon keyboard activation uses supplied focus node', (
    tester,
  ) async {
    var calls = 0;
    final focus = FocusNode();
    await tester.pumpWidget(
      host(
        WelkIconButton(
          icon: const Icon(Icons.add),
          label: 'Keyboard action',
          focusNode: focus,
          onPressed: () => calls++,
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
  });

  testWidgets('dialog defaults to a non-dismissible backdrop and closes', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => WelkButton(
            onPressed: () => showWelkDialog<void>(
              context: context,
              builder: (_) => const WelkDialog(
                title: Text('Mission'),
                child: Text('Continue here'),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Mission'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Mission'), findsOneWidget);
    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();
    expect(find.text('Mission'), findsNothing);
  });

  testWidgets('dialog confirmation callbacks replace dismissal', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => WelkButton(
            onPressed: () => showWelkDialog<void>(
              context: context,
              closeOnTapOutside: true,
              builder: (_) => WelkDialog(
                title: const Text('Continue?'),
                type: WelkDialogType.confirmation,
                variant: WelkDialogVariant.success,
                yesText: 'Proceed',
                noText: 'Cancel',
                onYesPressed: () => confirmed++,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();
    expect(confirmed, 1);
    expect(find.text('Continue?'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Continue?'), findsNothing);
  });

  testWidgets('dialog scrolls at narrow size and handles Escape', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => WelkButton(
            onPressed: () => showWelkDialog<void>(
              context: context,
              builder: (_) => WelkDialog(
                title: const Text('A long mobile-safe dialog heading'),
                child: Text(List.filled(40, 'A heroic tale!').join(' ')),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(WelkDialog), findsNothing);
  });

  for (final position in WelkDrawerPosition.values) {
    testWidgets('drawer ${position.name} is mobile-safe and back dismisses', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => WelkButton(
              onPressed: () => showWelkDrawer<void>(
                context: context,
                position: position,
                builder: (_) => WelkDrawer(
                  title: const Text('Mission details'),
                  child: Text(List.filled(100, 'A heroic tale!').join(' ')),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(WelkDrawer), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(WelkDrawer), findsNothing);
    });
  }

  testWidgets('drawer outside dismissal is optional and close is labelled', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => WelkButton(
            onPressed: () => showWelkDrawer<void>(
              context: context,
              closeOnTapOutside: true,
              builder: (_) => const WelkDrawer(
                title: Text('Notes'),
                child: Text('Tap outside'),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Close drawer'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(WelkDrawer), findsNothing);
  });

  for (final variant in WelkTooltipVariant.values) {
    testWidgets('tooltip ${variant.name} opens on long press', (tester) async {
      await tester.pumpWidget(
        host(
          WelkTooltip(
            content: 'A brilliant idea!',
            variant: variant,
            child: WelkButton(
              onPressed: () {},
              child: const Text('Hold for help'),
            ),
          ),
        ),
      );
      expect(find.text('A brilliant idea!'), findsNothing);
      await tester.longPress(find.text('Hold for help'));
      await tester.pumpAndSettle();
      expect(find.text('A brilliant idea!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      Tooltip.dismissAllToolTips();
      await tester.pumpAndSettle();
      expect(find.text('A brilliant idea!'), findsNothing);
    });
  }

  testWidgets('tooltip opens on focus and Escape dismisses', (tester) async {
    final focus = FocusNode();
    await tester.pumpWidget(
      host(
        WelkTooltip(
          content: 'Focus hint',
          child: WelkButton(
            focusNode: focus,
            onPressed: () {},
            child: const Text('Focus'),
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Focus hint'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Focus hint'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
  });

  testWidgets('snackbar overlay is non-modal, persistent and dismissible', (
    tester,
  ) async {
    var taps = 0;
    WelkSnackBarController? controller;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WelkButton(
                onPressed: () => controller = showWelkSnackBar(
                  context: context,
                  message: const Text('POW! Saved.'),
                  variant: WelkSnackBarVariant.success,
                ),
                child: const Text('Notify'),
              ),
              WelkButton(
                onPressed: () => taps++,
                child: const Text('Underlying action'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Notify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Underlying action'));
    await tester.pump(const Duration(seconds: 10));
    expect(taps, 1);
    expect(find.text('POW! Saved.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Dismiss notification'));
    await tester.pumpAndSettle();
    await controller!.closed;
    expect(find.text('POW! Saved.'), findsNothing);
  });

  testWidgets('snackbar auto hides and can be closed before first frame', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (value) {
            context = value;
            return const Text('Content');
          },
        ),
      ),
    );
    final unshown = showWelkSnackBar(
      context: context,
      message: const Text('Never shown'),
    );
    unshown.close();
    await tester.pump();
    await unshown.closed;
    expect(find.text('Never shown'), findsNothing);
    final timed = showWelkSnackBar(
      context: context,
      message: const Text('Timed'),
      autoHideDuration: const Duration(seconds: 2),
    );
    await tester.pumpAndSettle();
    expect(find.text('Timed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await timed.closed;
    expect(find.text('Timed'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('snackbar auto hide pauses while keyboard focused', (
    tester,
  ) async {
    var dismissed = 0;
    await tester.pumpWidget(
      host(
        WelkSnackBar(
          message: const Text('Status'),
          autoHideDuration: const Duration(seconds: 2),
          onClose: () => dismissed++,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(dismissed, 0);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(dismissed, 1);
  });

  testWidgets('reduced-motion overlays present without entry animations', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (value) {
            context = value;
            return const Text('Content');
          },
        ),
        reduced: true,
      ),
    );
    final notification = showWelkSnackBar(
      context: context,
      message: const Text('Immediately visible'),
      position: WelkSnackBarPosition.top,
    );
    await tester.pump();
    expect(find.text('Immediately visible'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    notification.close();
    await tester.pump();
    await notification.closed;
    expect(find.text('Immediately visible'), findsNothing);
    final drawer = showWelkDrawer<void>(
      context: context,
      builder: (_) => const WelkDrawer(
        title: Text('Reduced drawer'),
        child: Text('No sliding'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reduced drawer'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await drawer;
    expect(find.text('Reduced drawer'), findsNothing);
  });

  testWidgets('long notifications wrap on a narrow mobile screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (value) {
            context = value;
            return const Text('Content');
          },
        ),
      ),
    );
    for (final position in WelkSnackBarPosition.values) {
      final notification = showWelkSnackBar(
        context: context,
        position: position,
        message: const Text(
          'A comic notification with a longer message that wraps naturally '
          'on smaller screens. Your next adventure is ready.',
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final bounds = tester.getRect(find.byType(WelkSnackBar));
      expect(bounds.center.dx, closeTo(160, 1));
      if (position == WelkSnackBarPosition.top) {
        expect(bounds.top, closeTo(16, 1));
      } else {
        expect(bounds.bottom, closeTo(464, 1));
      }
      notification.close();
      await tester.pumpAndSettle();
      await notification.closed;
    }
  });

  testWidgets('modal presentation preserves caller Welk theme', (tester) async {
    await tester.pumpWidget(
      host(
        WelkTheme(
          data: const WelkThemeData(accent: Colors.purple),
          child: Builder(
            builder: (context) => WelkButton(
              onPressed: () => showWelkDialog<void>(
                context: context,
                builder: (_) => const WelkDialog(title: Text('Inherited')),
              ),
              child: const Text('Open themed dialog'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open themed dialog'));
    await tester.pumpAndSettle();
    expect(
      WelkTheme.of(tester.element(find.text('Inherited'))).accent,
      Colors.purple,
    );
    await tester.tap(find.bySemanticsLabel('Close dialog'));
    await tester.pumpAndSettle();
  });

  testWidgets('attachment accepts metadata, previews, change and clear', (
    tester,
  ) async {
    List<WelkAttachmentFile>? changed;
    await tester.pumpWidget(
      host(
        WelkAttachment(
          label: const Text('Mission files'),
          accept: 'image/*,.pdf',
          maxFiles: 3,
          maxFileSize: 1024,
          onSelectFiles: () async => const [
            WelkAttachmentFile(
              name: 'hero.PNG',
              size: 200,
              mimeType: 'image/png',
              preview: SizedBox(width: 128, height: 96),
            ),
          ],
          onFilesChange: (files) => changed = files,
        ),
      ),
    );
    await tester.tap(find.text('Choose files'));
    await tester.pumpAndSettle();
    expect(find.text('hero.PNG'), findsOneWidget);
    expect(find.text('200 bytes'), findsOneWidget);
    expect(changed!.single.name, 'hero.PNG');
    expect(find.bySemanticsLabel('Preview of hero.PNG'), findsOneWidget);
    await tester.tap(find.text('Clear attachments'));
    await tester.pumpAndSettle();
    expect(changed, isEmpty);
    expect(find.text('hero.PNG'), findsNothing);
  });

  final invalidSelections = <(List<WelkAttachmentFile>, String)>[
    (
      const [
        WelkAttachmentFile(name: 'a.png', size: 2),
        WelkAttachmentFile(name: 'b.png', size: 2),
      ],
      'Choose no more than 1 file.',
    ),
    (
      const [WelkAttachmentFile(name: 'large.png', size: 2000)],
      'large.png exceeds the 1024-byte limit.',
    ),
    (
      const [WelkAttachmentFile(name: 'script.txt', size: 10)],
      'script.txt is not an accepted file type.',
    ),
  ];
  for (final (files, message) in invalidSelections) {
    testWidgets('attachment rejects $message', (tester) async {
      List<WelkAttachmentFile>? changed;
      await tester.pumpWidget(
        host(
          WelkAttachment(
            label: const Text('Files'),
            multiple: false,
            maxFileSize: 1024,
            accept: '.png',
            onSelectFiles: () async => files,
            onFilesChange: (files) => changed = files,
          ),
        ),
      );
      await tester.tap(find.text('Choose file'));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      expect(changed, isEmpty);
    });
  }

  testWidgets('attachment form validates, resets, and cancellation preserves', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    var cancel = false;
    await tester.pumpWidget(
      host(
        Form(
          key: form,
          child: WelkAttachment(
            label: const Text('Required artwork'),
            isRequired: true,
            onSelectFiles: () async =>
                cancel ? null : const [WelkAttachmentFile(name: 'a', size: 10)],
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Choose at least one file.'), findsOneWidget);
    await tester.tap(find.text('Choose files'));
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isTrue);
    cancel = true;
    await tester.tap(find.text('Choose files'));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsOneWidget);
    form.currentState!.reset();
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNothing);
    expect(find.text('Choose at least one file.'), findsNothing);
  });

  testWidgets('attachment handles disabled, pending and disposed selection', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<List<WelkAttachmentFile>?>();
    await tester.pumpWidget(
      host(
        WelkAttachment(
          label: const Text('Files'),
          disabled: true,
          onSelectFiles: () async {
            calls++;
            return null;
          },
        ),
      ),
    );
    await tester.tap(find.text('Choose files'));
    expect(calls, 0);
    await tester.pumpWidget(
      host(
        WelkAttachment(
          label: const Text('Files'),
          onSelectFiles: () => pending.future,
        ),
      ),
    );
    await tester.tap(find.text('Choose files'));
    await tester.pump();
    expect(find.text('Selecting files…'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    pending.complete(const [WelkAttachmentFile(name: 'late', size: 1)]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme tokens and package font apply without Material surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        WelkTheme(
          data: const WelkThemeData(accent: Colors.purple),
          child: WelkSnackBar(message: const Text('Themed'), onClose: () {}),
        ),
      ),
    );
    final style =
        tester.widget<Text>(find.text('Themed')).style ??
        DefaultTextStyle.of(tester.element(find.text('Themed'))).style;
    expect(style.fontFamily, 'packages/welkui_flutter/ShortStack');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is ShapeDecoration &&
            (widget.decoration! as ShapeDecoration).color == Colors.purple,
      ),
      findsOneWidget,
    );
  });
}
