import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'support/rasterization_golden_comparator.dart';

void main() {
  for (final darkMode in [false, true]) {
    testWidgets('captures the WelkUI widget appearance (dark=$darkMode)', (
      tester,
    ) async {
      final originalComparator = goldenFileComparator;
      if (originalComparator is LocalFileComparator) {
        // macOS CI differs on 118 text-edge pixels (maximum channel delta 14).
        goldenFileComparator = RasterizationGoldenComparator(
          originalComparator.basedir.resolve('welk_widgets_golden_test.dart'),
        );
        addTearDown(() => goldenFileComparator = originalComparator);
      }
      tester.view.physicalSize = const Size(440, 620);
      tester.view.devicePixelRatio = 1;
      final fontData = await rootBundle.load(
        'packages/welkui_flutter/assets/font/short_stack/ShortStack-Regular.ttf',
      );
      await (FontLoader(
        'packages/welkui_flutter/ShortStack',
      )..addFont(Future.value(fontData))).load();

      await tester.pumpWidget(
        WelkTheme(
          data: WelkThemeData(darkMode: darkMode),
          child: MaterialApp(
            theme: ThemeData(
              brightness: darkMode ? Brightness.dark : Brightness.light,
            ),
            home: Scaffold(
              backgroundColor: darkMode
                  ? const WelkThemeData().darkPaper
                  : const Color(0xFFFFFDF5),
              body: const Padding(
                padding: EdgeInsets.all(24),
                child: _GoldenGallery(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_GoldenGallery),
        matchesGoldenFile(
          darkMode
              ? 'goldens/welk_widgets_dark.png'
              : 'goldens/welk_widgets.png',
        ),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('captures menu reference variants with the bundled font', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fontData = await rootBundle.load(
      'packages/welkui_flutter/assets/font/short_stack/ShortStack-Regular.ttf',
    );
    await (FontLoader(
      'packages/welkui_flutter/ShortStack',
    )..addFont(Future.value(fontData))).load();
    const items = [
      WelkMenuItem(title: 'Home', route: '/'),
      WelkMenuItem(
        title: 'Heroes',
        route: '/heroes',
        children: [
          WelkMenuItem(title: 'Superman', route: '/superman'),
          WelkMenuItem(title: 'Batman', route: '/batman'),
        ],
      ),
      WelkMenuItem(title: 'About', route: '/about'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFFFFDF5),
          body: RepaintBoundary(
            key: const ValueKey('menus'),
            child: ColoredBox(
              color: const Color(0xFFFFFDF5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelkMenu(
                      items: items,
                      activeRoute: '/',
                      onSelected: (_) {},
                    ),
                    const SizedBox(height: 28),
                    WelkMenu(
                      key: const ValueKey('nested'),
                      items: items,
                      variant: WelkMenuVariant.nested,
                      activeRoute: '/superman',
                      onSelected: (_) {},
                    ),
                    const SizedBox(height: 28),
                    WelkMenu(
                      key: const ValueKey('collapsed'),
                      items: items,
                      collapsible: true,
                      onSelected: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('nested')),
        matching: find.text('Heroes'),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('collapsed')),
        matching: find.bySemanticsLabel('Collapse menu'),
      ),
    );
    // Tapping outside a menu intentionally closes its branches.
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('nested')),
        matching: find.text('Heroes'),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('menus')),
      matchesGoldenFile('goldens/welk_menu.png'),
    );
  });
}

class _GoldenGallery extends StatelessWidget {
  const _GoldenGallery();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 14,
          children: [
            for (final variant in WelkButtonVariant.values)
              WelkButton(variant: variant, child: Text(variant.name)),
          ],
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 12,
          runSpacing: 14,
          children: [
            WelkButton(size: WelkButtonSize.small, child: Text('Small')),
            WelkButton(size: WelkButtonSize.medium, child: Text('Medium')),
            WelkButton(size: WelkButtonSize.large, child: Text('Large')),
          ],
        ),
        const SizedBox(height: 24),
        const WelkSwitch(value: true, label: 'On state'),
        const SizedBox(height: 14),
        const WelkCard(
          title: 'WelkCard',
          subtitle: 'Paper surface, ink outline, and a crisp hard shadow.',
        ),
      ],
    );
  }
}
