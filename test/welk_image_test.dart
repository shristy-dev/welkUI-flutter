import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/src/painting/welk_shape_border.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('failed network paints bundled fallback inside themed frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        WelkTheme(
          data: const WelkThemeData().copyWith(
            ink: Colors.blue,
            paper: Colors.white,
          ),
          child: const WelkImage.network(
            'https://example.invalid/render.jpg',
            fallbackAsset: 'assets/fallbacks/comic_bg_04.jpg',
            fallbackPackage: 'welkui_flutter',
            width: 240,
            height: 160,
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/fallbacks/comic_bg_04.jpg',
          package: 'welkui_flutter',
        ),
        tester.element(find.byType(WelkImage)),
      );
      // Let the test HTTP client deliver its deterministic failure.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<Image>(find.byType(Image)).last.image,
      const AssetImage(
        'assets/fallbacks/comic_bg_04.jpg',
        package: 'welkui_flutter',
      ),
    );
    final decoration = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(WelkImage),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final shape =
        (decoration.decoration as ShapeDecoration).shape as WelkShapeBorder;
    expect(shape.strokeColor, Colors.blue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('asset frame appearance', (tester) async {
    tester.view.physicalSize = const Size(280, 220);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFFFFDF5),
          body: Center(
            child: WelkImage.asset(
              'assets/fallbacks/comic_bg_04.jpg',
              package: 'welkui_flutter',
              width: 240,
              height: 160,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/fallbacks/comic_bg_04.jpg',
          package: 'welkui_flutter',
        ),
        tester.element(find.byType(WelkImage)),
      );
    });
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/welk_image.png'),
    );
  });

  testWidgets('asset uses package, dimensions, fit, and one image label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const WelkImage.asset(
          'assets/fallbacks/comic_bg_02.jpg',
          package: 'welkui_flutter',
          width: 240,
          height: 120,
          fit: BoxFit.contain,
          semanticLabel: 'Comic artwork',
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).package, 'welkui_flutter');
    expect(image.fit, BoxFit.contain);
    expect(tester.getSize(find.byType(WelkImage)), const Size(240, 120));
    expect(find.bySemanticsLabel('Comic artwork'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Comic artwork')),
      matchesSemantics(label: 'Comic artwork', isImage: true),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('network error selects a stable fallback until source changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const WelkImage.network('https://example.invalid/one.jpg')),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    final context = tester.element(find.byType(Image));
    final fallback =
        image.errorBuilder!(context, Exception('offline'), null) as Image;
    final provider = fallback.image as AssetImage;
    expect(provider.package, 'welkui_flutter');
    expect(
      provider.assetName,
      matches(r'assets/fallbacks/comic_bg_0[1-5]\.jpg'),
    );
    await tester.pumpWidget(
      host(const WelkImage.network('https://example.invalid/one.jpg')),
    );
    final rebuilt = tester.widget<Image>(find.byType(Image).first);
    final repeated =
        rebuilt.errorBuilder!(context, Exception('offline'), null) as Image;
    expect(identical(repeated.image, provider), isTrue);
    await tester.pumpWidget(
      host(const WelkImage.network('https://example.invalid/two.jpg')),
    );
    final next = tester.widget<Image>(find.byType(Image).first);
    final replacement =
        next.errorBuilder!(context, Exception('offline'), null) as Image;
    expect(identical(replacement.image, provider), isFalse);
  });

  testWidgets('custom fallback is preferred and changes are respected', (
    tester,
  ) async {
    for (final path in [
      'assets/fallbacks/comic_bg_01.jpg',
      'assets/fallbacks/comic_bg_02.jpg',
    ]) {
      await tester.pumpWidget(
        host(
          WelkImage.network(
            'https://example.invalid/photo.jpg',
            fallbackAsset: path,
            fallbackPackage: 'welkui_flutter',
          ),
        ),
      );
      final image = tester.widget<Image>(find.byType(Image).first);
      final fallback = image.errorBuilder!(
        tester.element(find.byType(Image).first),
        Exception('offline'),
        null,
      ) as Image;
      expect(fallback.image, AssetImage(path, package: 'welkui_flutter'));
      expect(fallback.errorBuilder, isNull);
    }
  });

  testWidgets(
    'narrow RTL uses default ratio and decorative image has no label',
    (tester) async {
      await tester.pumpWidget(
        host(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 180,
              child: WelkImage.asset(
                'assets/fallbacks/comic_bg_02.jpg',
                package: 'welkui_flutter',
                semanticLabel: 'Not announced',
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(WelkImage)), const Size(180, 135));
      expect(find.bySemanticsLabel('Not announced'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all five bundled fallback assets decode on Flutter', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (var i = 1; i <= 5; i++) {
        final data = await rootBundle.load(
          'packages/welkui_flutter/assets/fallbacks/comic_bg_0$i.jpg',
        );
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0));
        frame.image.dispose();
        codec.dispose();
      }
    });
  });
}
