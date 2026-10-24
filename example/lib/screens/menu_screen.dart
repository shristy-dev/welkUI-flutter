import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const _items = [
    WelkMenuItem(title: 'Home', route: '/home'),
    WelkMenuItem(
      title: 'Heroes',
      route: '/heroes',
      children: [
        WelkMenuItem(title: 'Superman', route: '/superman'),
        WelkMenuItem(
          title: 'Batman',
          route: '/batman',
          children: [WelkMenuItem(title: 'Gotham', route: '/gotham')],
        ),
      ],
    ),
    WelkMenuItem(title: 'About', route: '/about'),
  ];

  String _activeRoute = '/home';

  void _select(String route) => setState(() => _activeRoute = route);

  Widget _menu({
    WelkMenuVariant variant = WelkMenuVariant.standard,
    bool collapsible = false,
    bool highlight = false,
    bool disabled = false,
  }) => Align(
    alignment: AlignmentDirectional.topStart,
    child: WelkMenu(
      items: _items,
      variant: variant,
      collapsible: collapsible,
      activeRoute: highlight ? _activeRoute : null,
      onSelected: disabled ? null : _select,
    ),
  );

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkMenu',
    children: [
      Text('Selected route: $_activeRoute'),
      const DemoHeading('Default'),
      _menu(),
      const DemoHeading('Nested'),
      _menu(variant: WelkMenuVariant.nested),
      const DemoHeading('Collapsible'),
      _menu(variant: WelkMenuVariant.nested, collapsible: true),
      const DemoHeading('Active route'),
      _menu(highlight: true),
      const DemoHeading('Disabled destinations'),
      _menu(disabled: true),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: _menu(variant: WelkMenuVariant.nested, highlight: true),
      ),
      const DemoHeading('Long labels'),
      Align(
        alignment: AlignmentDirectional.topStart,
        child: WelkMenu(
          items: const [
            WelkMenuItem(
              title: 'A longer destination title that wraps on narrow screens',
              route: '/long',
            ),
          ],
          onSelected: _select,
        ),
      ),
    ],
  );
}
