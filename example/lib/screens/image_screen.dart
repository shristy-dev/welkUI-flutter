import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key});

  @override
  Widget build(BuildContext context) => const DemoPage(
    title: 'WelkImage',
    children: [
      DemoHeading('Network'),
      WelkImage.network(
        'https://raw.githubusercontent.com/welkdock/welkUI-flutter/main/assets/images/welkui-flutter-og.png',
        height: 160,
        semanticLabel: 'WelkUI Flutter',
      ),
      DemoHeading('Asset'),
      WelkImage.asset(
        'assets/fallbacks/comic_bg_02.jpg',
        package: 'welkui_flutter',
        height: 160,
        semanticLabel: 'Comic artwork',
      ),
      DemoHeading('Random comic fallback'),
      WelkImage.network(
        'https://example.invalid/missing.jpg',
        height: 160,
        semanticLabel: 'Comic fallback',
      ),
      DemoHeading('Custom fallback asset'),
      WelkImage.network(
        'https://example.invalid/custom.jpg',
        fallbackAsset: 'assets/fallbacks/comic_bg_04.jpg',
        fallbackPackage: 'welkui_flutter',
        height: 160,
        semanticLabel: 'Custom comic fallback',
      ),
      DemoHeading('Contain'),
      WelkImage.asset(
        'assets/fallbacks/comic_bg_01.jpg',
        package: 'welkui_flutter',
        height: 160,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ],
  );
}
