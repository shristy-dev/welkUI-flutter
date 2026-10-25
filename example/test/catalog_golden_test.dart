import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter_example/main.dart';
import 'package:welkui_flutter_example/widget_catalog.dart';

import '../../test/support/rasterization_golden_comparator.dart';

void main() {
  // Representative static screens; interaction and all routes are tested
  // separately, including narrow layouts with larger text.
  for (final route in [
    '/avatar',
    '/badge',
    '/sticker',
    '/checkbox',
    '/radio',
    '/divider',
    '/qr-code',
  ]) {
    testWidgets('$route mobile appearance with bundled font', (tester) async {
      final comparator = goldenFileComparator;
      if (comparator is LocalFileComparator) {
        goldenFileComparator = RasterizationGoldenComparator(
          comparator.basedir.resolve('catalog_golden_test.dart'),
          // CI differs at up to 0.136% of pixels, only on text edges.
          maxChangedPixelFraction: 0.0015,
        );
        addTearDown(() => goldenFileComparator = comparator);
      }
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      tester.binding.platformDispatcher.defaultRouteNameTestValue = route;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      final data = await rootBundle.load(
        'packages/welkui_flutter/assets/font/short_stack/ShortStack-Regular.ttf',
      );
      await (FontLoader(
        'packages/welkui_flutter/ShortStack',
      )..addFont(Future.value(data))).load();
      final icons = await rootBundle.load('fonts/MaterialIcons-Regular.otf');
      await (FontLoader('MaterialIcons')..addFont(Future.value(icons))).load();
      await tester.pumpWidget(const WelkExampleApp(embedMode: true));
      await tester.runAsync(() async {
        for (final path in [
          'portraits/male_user.png',
          'portraits/female_user.png',
          'portraits/male_admin.png',
          'portraits/female_admin.png',
          'stickers/superman.png',
          'stickers/batman.png',
        ]) {
          await precacheImage(
            AssetImage('assets/$path', package: 'welkui_flutter'),
            tester.element(find.byType(Scaffold)),
          );
        }
      });
      await tester.pumpAndSettle();
      final screen = widgetCatalog.singleWhere((item) => item.route == route);
      expect(find.byType(screen.screen.runtimeType), findsOneWidget);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/${route.substring(1)}.png'),
      );
    });
  }
}
