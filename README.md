# WelkUI Flutter

WelkUI Flutter provides mobile-first Flutter versions of the WelkUI button,
switch, card, and menu. The package targets Android and iOS and keeps the React
library's paper palette, crisp ink outlines, hard shadows, asymmetric shapes,
and Short Stack typography.

## Local development

This repository is a Flutter package. From the repository root:

```sh
flutter pub get
flutter test
cd example
flutter run
```

The example app uses a local path dependency on this package and is configured
for Android and iOS only.

To consume a local checkout from another Flutter app, add a path dependency:

```yaml
dependencies:
  welkui_flutter:
    path: ../welkUI-flutter
```

## Font

Short Stack is bundled in the package under the SIL Open Font License 1.1. The
package registers the font as `ShortStack`; consuming apps do not need to
declare or download it. The source provides a regular font file. Components
request weight 700 for emphasis, using the supplied font rather than a separate
bold download.

## Theme customization

Wrap the relevant part of the app in `WelkTheme` and pass a modified immutable
`WelkThemeData`. Defaults match the WelkUI design tokens.

```dart
WelkTheme(
  data: const WelkThemeData().copyWith(
    accent: const Color(0xFFFFD166),
    ink: const Color(0xFF202020),
  ),
  child: const SizedBox.shrink(),
)
```

## Widgets

Import the public package library:

```dart
import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';
```

### WelkButton

`WelkButton` defaults to the primary, medium treatment. A null `onPressed`
disables it. Supply any widget as its child for custom icon/text composition.

```dart
Widget build(BuildContext context) {
  return WelkButton(
    variant: WelkButtonVariant.primary,
    size: WelkButtonSize.medium,
    onPressed: () {},
    child: const Text('Save'),
  );
}
```

Variants are `primary`, `secondary`, `error`, `warning`, `ghost`, `info`, and
`success`. Sizes are `small`, `medium`, and `large`.

### WelkSwitch

The switch is controlled: update `value` in the parent in response to
`onChanged`. A null callback disables the complete row.

```dart
class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return WelkSwitch(
      value: notificationsEnabled,
      label: 'Notifications',
      onChanged: (value) => setState(() => notificationsEnabled = value),
    );
  }
}
```

### WelkCard

Cards without an `onPressed` callback are informational. To show an explicitly
disabled action card, provide the callback and set `enabled: false`.

```dart
Widget build(BuildContext context) {
  return WelkCard(
    title: 'Your workspace',
    subtitle: 'Manage members and settings.',
    icon: const Icon(Icons.arrow_forward),
    onPressed: () {},
    enableFeedback: true,
  );
}
```

For an informational card, omit `onPressed`; for a disabled action, set
`enabled: false`.

Actionable cards animate down and compress their hard shadow when tapped.
Set `enableFeedback: false` to disable this visual feedback while keeping the
card actionable. Feedback respects reduced-motion settings and never scales
the card.

### WelkMenu

`WelkMenu` renders a navigation list with ink separators, active-route styling,
and optional nested paper panels. Its width is 288 logical pixels, capped by
the parent's constraints. Routes must be unique within a menu.

```dart
Widget build(BuildContext context) {
  return WelkMenu(
    items: const [
      WelkMenuItem(title: 'Home', route: '/'),
      WelkMenuItem(
        title: 'Workspace',
        route: '/workspace',
        children: [
          WelkMenuItem(title: 'Members', route: '/members'),
          WelkMenuItem(title: 'Settings', route: '/settings'),
        ],
      ),
    ],
    variant: WelkMenuVariant.nested,
    collapsible: true,
    activeRoute: '/members',
    onSelected: (route) => Navigator.of(context).pushNamed(route),
  );
}
```

The default `WelkMenuVariant.standard` shows root destinations only; `nested`
adds expandable branches, including a destination for each parent. Set
`collapsible: true` to add the menu toggle (initially expanded). The parent owns
navigation and `activeRoute`; the menu does not assume a router. A null
`onSelected` disables destinations. Branches dismiss on outside interaction or
selection; keyboard users can navigate with Tab, activate with Enter/Space,
and dismiss with Escape. Motion respects the platform's reduced-motion setting.

## Running the example

From the repository root, run `cd example && flutter run` with an Android
emulator or iOS simulator available. The initial `/` route uses `WelkMenu` to
navigate to `/button`, `/switch`, `/card`, and `/menu`. Each widget has its own
screen showing its variants, interaction states, and long content; use the
back button to return to the initial menu.
