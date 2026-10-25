import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('valid URLs produce one labeled image and no validation error', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const WelkQRCode(url: 'https://ui.welkdock.com/flutter')),
    );
    expect(
      find.bySemanticsLabel('QR code for https://ui.welkdock.com/flutter'),
      findsOneWidget,
    );
    expect(find.textContaining('valid URL'), findsNothing);
    expect(tester.getSize(find.byType(WelkQRCode)), const Size(212, 212));
    semantics.dispose();
  });

  testWidgets('invalid URL is visible and updates when parent supplies a URL', (
    tester,
  ) async {
    for (final value in ['not-a-url', 'ftp://example.com', 'https://']) {
      await tester.pumpWidget(_host(WelkQRCode(url: value)));
      expect(
        find.text('Enter a valid URL beginning with http:// or https://.'),
        findsOneWidget,
      );
    }
    await tester.pumpWidget(
      _host(const WelkQRCode(url: 'https://example.com')),
    );
    expect(find.textContaining('valid URL'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('oversized URL has an explicit error rather than a fake code', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(WelkQRCode(url: 'https://example.com/${'x' * 10000}')),
    );
    expect(find.text('This URL is too long for a QR code.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card wraps long content at narrow widths with large RTL text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SingleChildScrollView(
          child: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: 220,
                child: WelkQRCode(
                  url: 'https://example.com',
                  title: 'A longer title for a mobile QR card',
                  subtitle: 'Scan to open the mobile documentation.',
                  variant: WelkQRCodeVariant.card,
                  originalCode: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(WelkQRCode)).width, 220);
  });

  test('QR encoder creates standard finder patterns and medium correction', () {
    final code = QrImage(
      QrCode(payload: QrPayload.fromString('https://ui.welkdock.com')),
    );
    expect(code.errorCorrectLevel, QrErrorCorrectLevel.medium);
    for (final origin in [
      (0, 0),
      (0, code.moduleCount - 7),
      (code.moduleCount - 7, 0),
    ]) {
      for (var row = 0; row < 7; row++) {
        for (var col = 0; col < 7; col++) {
          final dark =
              row == 0 ||
              row == 6 ||
              col == 0 ||
              col == 6 ||
              (row >= 2 && row <= 4 && col >= 2 && col <= 4);
          expect(code.isDark(origin.$1 + row, origin.$2 + col), dark);
        }
      }
    }
  });

  testWidgets('QR appearance', (tester) async {
    tester.view.physicalSize = const Size(280, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFFFFDF5),
          body: Center(
            child: WelkQRCode(url: 'https://ui.welkdock.com/flutter'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/welk_qr_code.png'),
    );
  });
}
