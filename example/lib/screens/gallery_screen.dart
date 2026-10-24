import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkUI Flutter',
    children: [
      const Text(
        'Choose a widget to explore its variants and interactions.',
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
      const DemoHeading('Widgets'),
      Align(
        alignment: AlignmentDirectional.topStart,
        child: WelkMenu(
          semanticLabel: 'Widget examples',
          items: const [
            WelkMenuItem(title: 'WelkButton', route: '/button'),
            WelkMenuItem(title: 'WelkSwitch', route: '/switch'),
            WelkMenuItem(title: 'WelkCard', route: '/card'),
            WelkMenuItem(title: 'WelkMenu', route: '/menu'),
          ],
          onSelected: (route) => Navigator.of(context).pushNamed(route),
        ),
      ),
    ],
  );
}
