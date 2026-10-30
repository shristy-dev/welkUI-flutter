import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import '../example_theme_mode.dart';
import 'demo_page.dart';

const _items = [
  WelkBottomNavItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: 'Home',
  ),
  WelkBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
  WelkBottomNavItem(icon: Icon(Icons.add), label: 'Create'),
  WelkBottomNavItem(
    icon: Icon(Icons.mail_outline),
    activeIcon: Icon(Icons.mail),
    label: 'Inbox',
  ),
  WelkBottomNavItem(
    icon: Icon(Icons.person_outline),
    activeIcon: Icon(Icons.person),
    label: 'Profile',
  ),
];

/// Keeps the last item reachable above a floating (body-extending) bar.
EdgeInsets _pagePadding(BuildContext context) =>
    EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom);

String _title(String name) {
  final words = name.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => ' ${match[0]}',
  );
  return '${words[0].toUpperCase()}${words.substring(1)}';
}

List<WelkDropDownOption> _options(List<Enum> values) => [
  for (final value in values)
    WelkDropDownOption(value: value.name, label: _title(value.name)),
];

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final Map<WelkBottomNavLayout, int> _previewIndex = {
    for (final layout in WelkBottomNavLayout.values) layout: 2,
  };
  int _threeIndex = 1;
  WelkBottomNavLayout _layout = WelkBottomNavLayout.popCircle;
  WelkBottomNavMode _mode = WelkBottomNavMode.defaultMode;
  WelkBottomNavVisibility _visibility =
      WelkBottomNavVisibility.hideOnScrollDown;
  WelkBottomNavTransition _transition = WelkBottomNavTransition.fadeThrough;
  WelkBottomNavLabelBehavior _labels = WelkBottomNavLabelBehavior.alwaysShow;
  bool _hideOnSubpages = true;

  void _launch() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BottomNavDemoApp(
        layout: _layout,
        mode: _mode,
        visibility: _visibility,
        transition: _transition,
        labelBehavior: _labels,
        hideOnSubpages: _hideOnSubpages,
      ),
    ),
  );

  Widget _preview(WelkBottomNavLayout layout, WelkBottomNavMode mode) =>
      MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: WelkBottomNavBar(
          items: _items,
          currentIndex: _previewIndex[layout]!,
          layout: layout,
          mode: mode,
          semanticLabel: '${_title(layout.name)} preview',
          onTap: (index) => setState(() => _previewIndex[layout] = index),
        ),
      );

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkBottomNavBar',
    children: [
      const Text(
        'Tap the items in each preview, then launch the full demo to try '
        'per-tab pages, subpages, and scroll behavior.',
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
      for (final layout in WelkBottomNavLayout.values) ...[
        DemoHeading(_title(layout.name)),
        _preview(layout, WelkBottomNavMode.defaultMode),
        const SizedBox(height: 16),
        _preview(layout, WelkBottomNavMode.floating),
      ],
      const DemoHeading('Three items, custom style'),
      MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: WelkBottomNavBar(
          items: [_items[0], _items[2], _items[4]],
          currentIndex: _threeIndex,
          layout: WelkBottomNavLayout.popBlock,
          mode: WelkBottomNavMode.floating,
          semanticLabel: 'Custom style preview',
          style: const WelkBottomNavStyle(
            selectedItemColor: Color(0xFF82CAFF),
            featuredItemColor: Color(0xFF8DDD9B),
            borderRadius: 20,
            height: 60,
            activeItemSize: 56,
            labelBehavior: WelkBottomNavLabelBehavior.selectedOnly,
          ),
          onTap: (index) => setState(() => _threeIndex = index),
        ),
      ),
      const DemoHeading('Try the full demo'),
      WelkDropDown(
        label: 'Layout',
        options: _options(WelkBottomNavLayout.values),
        value: _layout.name,
        onChanged: (v) =>
            setState(() => _layout = WelkBottomNavLayout.values.byName(v)),
      ),
      const SizedBox(height: 12),
      WelkDropDown(
        label: 'Mode',
        options: _options(WelkBottomNavMode.values),
        value: _mode.name,
        onChanged: (v) =>
            setState(() => _mode = WelkBottomNavMode.values.byName(v)),
      ),
      const SizedBox(height: 12),
      WelkDropDown(
        label: 'Visibility',
        options: _options(WelkBottomNavVisibility.values),
        value: _visibility.name,
        onChanged: (v) => setState(
          () => _visibility = WelkBottomNavVisibility.values.byName(v),
        ),
      ),
      const SizedBox(height: 12),
      WelkDropDown(
        label: 'Transition',
        options: _options(WelkBottomNavTransition.values),
        value: _transition.name,
        onChanged: (v) => setState(
          () => _transition = WelkBottomNavTransition.values.byName(v),
        ),
      ),
      const SizedBox(height: 12),
      WelkDropDown(
        label: 'Labels',
        options: _options(WelkBottomNavLabelBehavior.values),
        value: _labels.name,
        onChanged: (v) => setState(
          () => _labels = WelkBottomNavLabelBehavior.values.byName(v),
        ),
      ),
      const SizedBox(height: 16),
      WelkSwitch(
        value: _hideOnSubpages,
        label: 'Hide on subpages',
        onChanged: (v) => setState(() => _hideOnSubpages = v),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WelkButton(
          onPressed: _launch,
          child: const Text('Launch demo app'),
        ),
      ),
    ],
  );
}

/// A five-destination app shell showing state preservation, subpages, and
/// scroll-driven visibility.
class BottomNavDemoApp extends StatelessWidget {
  const BottomNavDemoApp({
    super.key,
    this.layout = WelkBottomNavLayout.popCircle,
    this.mode = WelkBottomNavMode.defaultMode,
    this.visibility = WelkBottomNavVisibility.hideOnScrollDown,
    this.transition = WelkBottomNavTransition.fadeThrough,
    this.labelBehavior = WelkBottomNavLabelBehavior.alwaysShow,
    this.hideOnSubpages = true,
  });

  final WelkBottomNavLayout layout;
  final WelkBottomNavMode mode;
  final WelkBottomNavVisibility visibility;
  final WelkBottomNavTransition transition;
  final WelkBottomNavLabelBehavior labelBehavior;
  final bool hideOnSubpages;

  @override
  Widget build(BuildContext context) => WelkBottomNavScaffold(
    layout: layout,
    mode: mode,
    visibility: visibility,
    transition: transition,
    hideOnSubpages: hideOnSubpages,
    style: WelkBottomNavStyle(labelBehavior: labelBehavior),
    items: [
      WelkBottomNavItem(
        icon: _items[0].icon,
        activeIcon: _items[0].activeIcon,
        label: 'Home',
        builder: (_) => const _HomePage(),
      ),
      WelkBottomNavItem(
        icon: _items[1].icon,
        label: 'Search',
        builder: (_) => const _SearchPage(),
      ),
      WelkBottomNavItem(
        icon: _items[2].icon,
        label: 'Create',
        builder: (_) => const _CreatePage(),
      ),
      WelkBottomNavItem(
        icon: _items[3].icon,
        activeIcon: _items[3].activeIcon,
        label: 'Inbox',
        badge: const _CountBadge(3),
        builder: (_) => const _InboxPage(),
      ),
      WelkBottomNavItem(
        icon: _items[4].icon,
        activeIcon: _items[4].activeIcon,
        label: 'Profile',
        builder: (_) => const _ProfilePage(),
      ),
    ],
  );
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = WelkTheme.of(context).resolveColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outline, width: 1.5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontFamily: colors.fontFamily,
          package: colors.fontPackage,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.onFill(colors.error),
        ),
      ),
    );
  }
}

/// A destination root page with an exit button and the global theme toggle.
class _DemoTab extends StatelessWidget {
  const _DemoTab({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final themeMode = ExampleThemeMode.maybeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: 'Close demo',
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).maybePop(),
        ),
        actions: [
          if (themeMode != null)
            IconButton(
              tooltip: themeMode.darkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              icon: Icon(
                themeMode.darkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: themeMode.toggle,
            ),
        ],
      ),
      body: body,
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => _DemoTab(
    title: 'Home',
    body: ListView(
      padding: _pagePadding(context),
      children: [
        const Text(
          'This counter keeps its value when you switch tabs.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WelkButton(
            onPressed: () => setState(() => _taps++),
            child: Text('Tapped $_taps times'),
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 1; i <= 3; i++) ...[
          WelkCard(
            title: 'Story #$i',
            subtitle: 'Opens a details subpage inside the Home tab.',
            icon: const Icon(Icons.arrow_forward, size: 24),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => _DetailsPage(i))),
          ),
          const SizedBox(height: 12),
        ],
      ],
    ),
  );
}

class _DetailsPage extends StatelessWidget {
  const _DetailsPage(this.number, {this.depth = 1});

  final int number;
  final int depth;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Story #$number details')),
    body: ListView(
      padding: _pagePadding(context),
      children: [
        Text(
          'Subpage depth $depth. The bottom navigation bar is hidden here '
          'when "Hide on subpages" is on; go back to bring it back.',
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WelkButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _DetailsPage(number, depth: depth + 1),
              ),
            ),
            child: const Text('Go deeper'),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WelkButton(
            variant: WelkButtonVariant.secondary,
            onPressed: () => WelkBottomNavScaffold.of(context).popToRoot(),
            child: const Text('Back to tab root'),
          ),
        ),
      ],
    ),
  );
}

class _SearchPage extends StatefulWidget {
  const _SearchPage();

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) => _DemoTab(
    title: 'Search',
    body: ListView(
      padding: _pagePadding(context),
      children: [
        WelkInput(
          label: 'Search heroes',
          value: _query,
          placeholder: 'Type, switch tabs, come back',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 16),
        Text(
          _query.isEmpty ? 'Nothing searched yet.' : 'Results for "$_query"',
        ),
      ],
    ),
  );
}

class _CreatePage extends StatefulWidget {
  const _CreatePage();

  @override
  State<_CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<_CreatePage> {
  int _stickers = 0;

  @override
  Widget build(BuildContext context) => _DemoTab(
    title: 'Create',
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_stickers stickers created',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          WelkButton(
            onPressed: () => setState(() => _stickers++),
            child: const Text('Make a sticker'),
          ),
        ],
      ),
    ),
  );
}

class _InboxPage extends StatelessWidget {
  const _InboxPage();

  @override
  Widget build(BuildContext context) => _DemoTab(
    title: 'Inbox',
    body: ListView.separated(
      padding: _pagePadding(context),
      itemCount: 40,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => WelkCard(
        title: 'Message ${index + 1}',
        subtitle: 'Scroll down to hide the bar, up to reveal it.',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text('Message ${index + 1}')),
              body: const Center(child: Text('A message subpage.')),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) => _DemoTab(
    title: 'Profile',
    body: ListView(
      padding: _pagePadding(context),
      children: [
        WelkSwitch(
          value: _notifications,
          label: 'Notifications',
          onChanged: (v) => setState(() => _notifications = v),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WelkButton(
            onPressed: () => WelkBottomNavScaffold.of(context).select(0),
            child: const Text('Jump to Home'),
          ),
        ),
      ],
    ),
  );
}
