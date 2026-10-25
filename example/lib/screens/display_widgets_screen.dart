import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

const _comic = AssetImage(
  'assets/fallbacks/comic_bg_02.jpg',
  package: 'welkui_flutter',
);
const _superman = AssetImage(
  'assets/stickers/superman.png',
  package: 'welkui_flutter',
);
const _batman = AssetImage(
  'assets/stickers/batman.png',
  package: 'welkui_flutter',
);

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkAvatar',
    children: [
      const DemoHeading('The whole crew'),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final variant in WelkAvatarVariant.values)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WelkAvatar(
                  alt: variant.name,
                  variant: variant,
                  size: WelkAvatarSize.large,
                  growOnHover: true,
                ),
                const SizedBox(height: 8),
                Text(variant.name),
              ],
            ),
        ],
      ),
      const DemoHeading('Sizes & custom content'),
      const Wrap(
        spacing: 20,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          WelkAvatar(alt: 'Small profile', size: WelkAvatarSize.small),
          WelkAvatar(alt: 'Medium profile'),
          WelkAvatar(alt: 'Large profile', size: WelkAvatarSize.large),
          WelkAvatar(
            alt: 'Favorite profile',
            icon: Icon(Icons.star),
            color: Color(0xFF82CAFF),
          ),
          WelkAvatar(alt: 'Comic profile', image: _comic),
        ],
      ),
    ],
  );
}

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkBadge',
    children: [
      const DemoHeading('Status labels'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final variant in WelkBadgeVariant.values)
            WelkBadge(
              variant: variant,
              child: Text(
                variant == WelkBadgeVariant.defaultStyle
                    ? 'NEW!'
                    : variant.name,
              ),
            ),
        ],
      ),
      const DemoHeading('Sizes & counts'),
      const Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          WelkBadge(size: WelkBadgeSize.small, child: Text('Small')),
          WelkBadge(child: Text('Medium')),
          WelkBadge(size: WelkBadgeSize.large, child: Text('Large')),
          WelkBadge(semanticLabel: '12 unread messages', child: Text('12')),
        ],
      ),
      const DemoHeading('Long labels wrap'),
      const WelkBadge(
        variant: WelkBadgeVariant.success,
        child: Text('Mission complete — the entire crew returned safely!'),
      ),
    ],
  );
}

class BreadCrumbsScreen extends StatefulWidget {
  const BreadCrumbsScreen({super.key});
  @override
  State<BreadCrumbsScreen> createState() => _BreadCrumbsScreenState();
}

class _BreadCrumbsScreenState extends State<BreadCrumbsScreen> {
  String _destination = 'Superman';
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkBreadCrumbs',
    children: [
      const DemoHeading('Follow the trail'),
      WelkBreadCrumbs(
        items: [
          WelkBreadCrumbItem(
            label: const Text('Home'),
            onPressed: () => setState(() => _destination = 'Home'),
          ),
          WelkBreadCrumbItem(
            label: const Text('Heroes'),
            onPressed: () => setState(() => _destination = 'Heroes'),
          ),
          const WelkBreadCrumbItem(label: Text('Superman')),
        ],
      ),
      const SizedBox(height: 12),
      Text('Destination: $_destination'),
      const DemoHeading('Custom separator & current link'),
      WelkBreadCrumbs(
        separator: const Text('›'),
        items: [
          WelkBreadCrumbItem(
            label: const Text('Home'),
            onPressed: () => setState(() => _destination = 'Home'),
          ),
          WelkBreadCrumbItem(
            label: const Text('Heroes'),
            onPressed: () => setState(() => _destination = 'Heroes'),
          ),
        ],
      ),
      const DemoHeading('Wrapping & disabled navigation'),
      const WelkBreadCrumbs(
        items: [
          WelkBreadCrumbItem(label: Text('Archive'), enabled: false),
          WelkBreadCrumbItem(
            label: Text('The extraordinarily long superhero adventure archive'),
          ),
        ],
      ),
    ],
  );
}

class DividerScreen extends StatelessWidget {
  const DividerScreen({super.key});
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkDivider',
    children: [
      for (final variant in WelkDividerVariant.values) ...[
        DemoHeading(variant.name),
        WelkDivider(
          variant: variant,
          thickness: variant == WelkDividerVariant.plain ? 2 : 3,
        ),
      ],
      const DemoHeading('Vertical separators'),
      const Wrap(
        spacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Heroes'),
          WelkDivider(orientation: Axis.vertical, length: 64),
          Text('Missions'),
          WelkDivider(
            orientation: Axis.vertical,
            length: 64,
            variant: WelkDividerVariant.dotted,
            thickness: 3,
          ),
          Text('Archive'),
        ],
      ),
    ],
  );
}

class StickerScreen extends StatefulWidget {
  const StickerScreen({super.key});
  @override
  State<StickerScreen> createState() => _StickerScreenState();
}

class _StickerScreenState extends State<StickerScreen> {
  int _version = 0;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkSticker',
    children: [
      const DemoHeading('Peel & stick'),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          WelkSticker(
            key: ValueKey(_version),
            image: _superman,
            fallbackImage: _comic,
            alt: 'Superman sticker',
            width: 128,
            height: 128,
            elevateOnHover: true,
          ),
          const WelkSticker(
            image: _batman,
            fallbackImage: _comic,
            alt: 'Batman sticker',
            width: 100,
            height: 100,
            outlineThickness: 10,
            outlineColor: Color(0xFFFFDA57),
          ),
        ],
      ),
      WelkButton(
        onPressed: () => setState(() => _version++),
        child: const Text('Stick again'),
      ),
      const DemoHeading('Fallback & unavailable art'),
      const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          WelkSticker(
            image: AssetImage('missing-sticker.png'),
            fallbackImage: _comic,
            alt: 'Comic fallback',
            width: 100,
            height: 100,
          ),
          WelkSticker(
            image: AssetImage('missing-sticker.png'),
            alt: 'Unavailable sticker',
            width: 100,
            height: 100,
          ),
        ],
      ),
    ],
  );
}

class StickerCardScreen extends StatefulWidget {
  const StickerCardScreen({super.key});
  @override
  State<StickerCardScreen> createState() => _StickerCardScreenState();
}

class _StickerCardScreenState extends State<StickerCardScreen> {
  int _missions = 0;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkStickerCard',
    children: [
      const DemoHeading('Your next adventure'),
      Text('Missions launched: $_missions'),
      WelkStickerCard(
        title: 'A super adventure',
        subtitle: 'Your next mission starts here.',
        sticker: _superman,
        fallbackImage: _comic,
        onPressed: () => setState(() => _missions++),
      ),
      const WelkStickerCard(
        title: 'Gotham awaits',
        subtitle:
            'Take the scenic route through the city. '
            'Every great adventure starts with one brave step.',
        sticker: _batman,
        fallbackImage: _comic,
        outlineColor: Color(0xFFFFE87B),
      ),
      WelkStickerCard(
        title: 'Mission locked',
        subtitle: 'Return after completing your training.',
        sticker: _superman,
        fallbackImage: _comic,
        enabled: false,
        onPressed: () {},
      ),
    ],
  );
}

class AccordionScreen extends StatefulWidget {
  const AccordionScreen({super.key});
  @override
  State<AccordionScreen> createState() => _AccordionScreenState();
}

class _AccordionScreenState extends State<AccordionScreen> {
  bool _expanded = true;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkAccordion',
    children: [
      const DemoHeading('Controlled disclosure'),
      WelkAccordion(
        title: const Text('What is WelkUI?'),
        expanded: _expanded,
        onChanged: (value) => setState(() => _expanded = value),
        child: const Text(
          'Playful, outlined components for your next mission.',
        ),
      ),
      const DemoHeading('Horizontal on wide layouts'),
      const WelkAccordion(
        title: Text('Mission briefing'),
        variant: WelkAccordionVariant.horizontal,
        fixedWidth: 480,
        initiallyExpanded: true,
        child: Text(
          'On narrow screens this layout stacks to keep text readable.',
        ),
      ),
      const DemoHeading('Independent nested disclosures'),
      const WelkAccordion(
        title: Text('Parent accordion'),
        initiallyExpanded: true,
        child: WelkAccordion(
          title: Text('Child accordion'),
          variant: WelkAccordionVariant.nested,
          child: Text('Nested content with independent state.'),
        ),
      ),
      const DemoHeading('Tap elsewhere to close'),
      const WelkAccordion(
        title: Text('Dismissible briefing'),
        closeOnOutsideClick: true,
        child: Text('Tap outside this card to close it.'),
      ),
      const SizedBox(height: 16),
      const WelkAccordion(
        title: Text('Classified'),
        enabled: false,
        child: Text('Not available yet.'),
      ),
    ],
  );
}

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  String _value = 'overview';
  static const _items = [
    WelkTabItem(
      label: Text('Overview'),
      value: 'overview',
      content: Text('A quick overview of your next mission.'),
    ),
    WelkTabItem(
      label: Text('Objectives'),
      value: 'objectives',
      content: Text('Complete the mission and return safely.'),
    ),
    WelkTabItem(
      label: Text('Locked'),
      value: 'locked',
      disabled: true,
      content: Text('Not available.'),
    ),
  ];
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkTabs',
    children: [
      const DemoHeading('Controlled selection'),
      WelkTabs(
        label: 'Mission information',
        items: _items,
        value: _value,
        onValueChange: (value) => setState(() => _value = value),
      ),
      const SizedBox(height: 12),
      Text('Selected: $_value'),
      const DemoHeading('With background'),
      const WelkTabs(
        label: 'Mission details',
        items: _items,
        variant: WelkTabsVariant.withBg,
        defaultValue: 'objectives',
      ),
      const DemoHeading('Vertical, adaptive to mobile'),
      const WelkTabs(
        label: 'Mission navigation',
        items: _items,
        orientation: Axis.vertical,
      ),
      const DemoHeading('Vertical with background'),
      const WelkTabs(
        label: 'Crew navigation',
        items: _items,
        orientation: Axis.vertical,
        variant: WelkTabsVariant.withBg,
      ),
    ],
  );
}
