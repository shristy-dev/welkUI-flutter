import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'preview_mode.dart';
import 'screens/gallery_screen.dart';
import 'widget_catalog.dart';

void main() {
  final bool embedMode = Uri.base.queryParameters['embed'] == '1';
  runApp(WelkExampleApp(embedMode: embedMode));
}

class WelkExampleApp extends StatelessWidget {
  const WelkExampleApp({super.key, this.embedMode = false});

  final bool embedMode;

  @override
  Widget build(BuildContext context) {
    const tokens = WelkThemeData();
    return PreviewMode(
      embedMode: embedMode,
      child: WelkTheme(
        data: tokens,
        child: MaterialApp(
          title: kIsWeb ? 'WelkUI Flutter preview' : 'WelkUI Flutter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: tokens.accent),
            scaffoldBackgroundColor: tokens.paper,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFFDF5),
              foregroundColor: Color(0xFF242424),
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Color(0xFF242424),
                fontFamily: 'ShortStack',
                package: 'welkui_flutter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(
                color: Color(0xFF242424),
                fontFamily: 'ShortStack',
                package: 'welkui_flutter',
              ),
            ),
          ),
          routes: {
            '/': (_) => const GalleryScreen(),
            for (final item in widgetCatalog) item.route: (_) => item.screen,
          },
        ),
      ),
    );
  }
}
