import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'example_theme_mode.dart';
import 'preview_mode.dart';
import 'screens/gallery_screen.dart';
import 'widget_catalog.dart';

void main() {
  final bool embedMode = Uri.base.queryParameters['embed'] == '1';
  runApp(WelkExampleApp(embedMode: embedMode));
}

class WelkExampleApp extends StatefulWidget {
  const WelkExampleApp({super.key, this.embedMode = false});

  final bool embedMode;

  @override
  State<WelkExampleApp> createState() => _WelkExampleAppState();
}

class _WelkExampleAppState extends State<WelkExampleApp> {
  bool _darkMode = false;

  void _toggleTheme() => setState(() => _darkMode = !_darkMode);

  @override
  Widget build(BuildContext context) {
    final tokens = WelkThemeData(darkMode: _darkMode);
    final background = _darkMode ? tokens.darkPaper : Colors.white;
    final foreground = _darkMode ? tokens.darkInk : tokens.ink;
    return PreviewMode(
      embedMode: widget.embedMode,
      child: ExampleThemeMode(
        darkMode: _darkMode,
        toggle: _toggleTheme,
        child: WelkTheme(
          data: tokens,
          child: MaterialApp(
            title: kIsWeb ? 'WelkUI Flutter preview' : 'WelkUI Flutter',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: tokens.accent,
                brightness: _darkMode ? Brightness.dark : Brightness.light,
                surface: background,
              ),
              scaffoldBackgroundColor: background,
              canvasColor: background,
              appBarTheme: AppBarTheme(
                backgroundColor: background,
                surfaceTintColor: Colors.transparent,
                foregroundColor: foreground,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  color: foreground,
                  fontFamily: 'ShortStack',
                  package: 'welkui_flutter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: foreground,
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
      ),
    );
  }
}
