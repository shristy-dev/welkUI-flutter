import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class AppBarScreen extends StatefulWidget {
  const AppBarScreen({super.key});

  @override
  State<AppBarScreen> createState() => _AppBarScreenState();
}

class _AppBarScreenState extends State<AppBarScreen> {
  WelkAppBarLayout _layout = WelkAppBarLayout.comicStrip;
  bool _floating = true;
  bool _pinned = true;
  bool _center = false;
  String _message = 'Tap any preview action';

  Widget get _logo => Image.asset(
    'assets/images/welkui-logo.png',
    package: 'welkui_flutter',
    width: 36,
    height: 36,
    fit: BoxFit.contain,
    semanticLabel: 'WelkUI logo',
  );

  List<Widget> get _actions => [
    IconButton(
      tooltip: 'Search',
      onPressed: () => setState(() => _message = 'Search tapped'),
      icon: const Icon(Icons.search),
    ),
    IconButton(
      tooltip: 'Notifications',
      onPressed: () => setState(() => _message = 'Notifications tapped'),
      icon: const Icon(Icons.notifications_outlined),
    ),
  ];

  void _launch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: CustomScrollView(
            slivers: [
              WelkSliverAppBar(
                pinned: _pinned,
                appBar: WelkAppBar(
                  title: 'WelkUI',
                  layout: _layout,
                  floating: _floating,
                  logo: _logo,
                  logoPosition: _center
                      ? WelkAppBarLogoPosition.center
                      : WelkAppBarLogoPosition.left,
                  actions: [
                    IconButton(
                      tooltip: 'Show message',
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text('Ready for adventure!'),
                            ),
                          ),
                      icon: const Icon(Icons.star_outline),
                    ),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: 40,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: WelkCard(
                    title: 'Panel ${index + 1}',
                    subtitle: 'Scroll to try pinned and scroll-away app bars.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkAppBar',
    children: [
      const Text(
        'Four comic-inspired layouts. Floating adds margins and a hard shadow; '
        'pinned keeps the app bar visible while scrolling.',
      ),
      Text(_message),
      for (final layout in WelkAppBarLayout.values) ...[
        DemoHeading(layout.name),
        for (final floating in [false, true]) ...[
          WelkAppBar(
            title: 'WelkUI',
            primary: false,
            automaticallyImplyLeading: false,
            layout: layout,
            floating: floating,
            logo: _logo,
            actions: _actions,
          ),
          const SizedBox(height: 12),
        ],
      ],
      const DemoHeading('Custom title and centered branding'),
      WelkAppBar(
        primary: false,
        automaticallyImplyLeading: false,
        floating: true,
        layout: WelkAppBarLayout.bubble,
        logo: _logo,
        logoPosition: WelkAppBarLogoPosition.center,
        titleWidget: const Text('WelkUI'),
        accentColor: const Color(0xFF82CAFF),
      ),
      const DemoHeading('Try scrolling'),
      WelkDropDown(
        label: 'Layout',
        value: _layout.name,
        options: [
          for (final layout in WelkAppBarLayout.values)
            WelkDropDownOption(value: layout.name, label: layout.name),
        ],
        onChanged: (value) =>
            setState(() => _layout = WelkAppBarLayout.values.byName(value)),
      ),
      const SizedBox(height: 16),
      WelkSwitch(
        label: 'Floating card',
        value: _floating,
        onChanged: (value) => setState(() => _floating = value),
      ),
      WelkSwitch(
        label: 'Pinned while scrolling',
        value: _pinned,
        onChanged: (value) => setState(() => _pinned = value),
      ),
      WelkSwitch(
        label: 'Centered logo and title',
        value: _center,
        onChanged: (value) => setState(() => _center = value),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WelkButton(
          onPressed: _launch,
          child: const Text('Launch app bar demo'),
        ),
      ),
    ],
  );
}
