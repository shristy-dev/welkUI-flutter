import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import '../preview_mode.dart';
import '../widget_catalog.dart';
import 'demo_page.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkUI Flutter',
    children: [
      if (PreviewMode.of(context))
        const Text(
          'Open a widget preview using its dedicated documentation route.',
        )
      else ...[
        const Text(
          'Choose a widget to explore its variants and interactions.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const DemoHeading('Widgets'),
        Align(
          alignment: AlignmentDirectional.topStart,
          child: WelkMenu(
            semanticLabel: 'Widget examples',
            items: [
              for (final item in widgetCatalog)
                WelkMenuItem(title: item.name, route: item.route),
            ],
            onSelected: (route) => Navigator.of(context).pushNamed(route),
          ),
        ),
      ],
    ],
  );
}
