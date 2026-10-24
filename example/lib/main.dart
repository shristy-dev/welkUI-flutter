import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'screens/button_screen.dart';
import 'screens/card_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/switch_screen.dart';

void main() => runApp(const WelkExampleApp());

class WelkExampleApp extends StatelessWidget {
  const WelkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const tokens = WelkThemeData();
    return WelkTheme(
      data: tokens,
      child: MaterialApp(
        title: 'WelkUI Flutter',
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
        initialRoute: '/',
        routes: {
          '/': (_) => const GalleryScreen(),
          '/button': (_) => const ButtonScreen(),
          '/switch': (_) => const SwitchScreen(),
          '/card': (_) => const CardScreen(),
          '/menu': (_) => const MenuScreen(),
        },
      ),
    );
  }
}
