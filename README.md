<p align="center">
  <a href="https://ui.welkdock.com/flutter">
    <img src="https://raw.githubusercontent.com/welkdock/welkUI-flutter/main/assets/images/welkui-logo.png" width="112" alt="WelkUI logo">
  </a>
</p>

<h1 align="center">WelkUI Flutter</h1>

<p align="center">
  <strong>A little character. A crisp outline. A distinctly WelkUI app.</strong><br>
  Paper surfaces, ink borders, hard shadows, and handwritten typography for Flutter.
</p>

<p align="center">
  <strong>Android &amp; iOS</strong> &nbsp;·&nbsp; MIT licensed &nbsp;·&nbsp; Locally bundled fonts
</p>

<p align="center">
  <a href="https://ui.welkdock.com/flutter"><strong>Full documentation</strong></a>
  &nbsp;·&nbsp;
  <a href="https://pub.dev/packages/welkui_flutter"><img src="https://img.shields.io/pub/v/welkui_flutter.svg" alt="pub.dev package"></a>
  &nbsp;·&nbsp;
  <a href="#quick-start">Quick start</a>
  &nbsp;·&nbsp;
  <a href="#widget-gallery">Widget gallery</a>
  &nbsp;·&nbsp;
  <a href="#run-the-example">Example app</a>
</p>

---

## Familiar WelkUI. Native Flutter.

WelkUI Flutter brings the visual identity of the
[WelkUI React library](https://github.com/welkdock/welkUI) to mobile apps with
idiomatic Dart APIs and Flutter interactions. No Material elevation, gradients,
or runtime font downloads.

- **Distinctive by default:** asymmetric corners, crisp ink outlines, solid
  offset shadows, and the Short Stack typeface.
- **Made for touch:** at least 48 logical-pixel interactive targets, visible tap
  feedback, and controlled state where it matters.
- **Accessibility built in:** semantics, keyboard focus, RTL layout, text
  scaling, and reduced-motion support.
- **Easy to make yours:** immutable theme tokens, local styling overrides,
  and no third-party runtime dependencies.

> **Full documentation:** [ui.welkdock.com/flutter](https://ui.welkdock.com/flutter)
>
> This README covers setup and the essentials. Visit the Flutter documentation
> for the full guide and a live preview of each widget.

## Widget gallery

Actual Flutter renders using the package's bundled font:

<table>
  <tr>
    <th>Buttons, switch &amp; card</th>
    <th>Navigation menus</th>
  </tr>
  <tr>
    <td align="center" valign="top">
      <img src="https://raw.githubusercontent.com/welkdock/welkUI-flutter/main/test/goldens/welk_widgets.png" width="352" alt="WelkUI Flutter preview: seven disabled button variants, three disabled button sizes, a disabled on-state switch, and an informational card">
    </td>
    <td align="center" valign="top">
      <img src="https://raw.githubusercontent.com/welkdock/welkUI-flutter/main/test/goldens/welk_menu.png" width="288" alt="WelkMenu preview: standard navigation with an active Home destination, an expanded nested Heroes panel, and a collapsed menu toggle">
    </td>
  </tr>
</table>

The first preview includes disabled button and switch styling; enabled controls
use full-opacity colors. Explore every state in the mobile example.

| Widget | What you get |
| --- | --- |
| `WelkButton` | Seven variants, three sizes, hard-shadow tap feedback, custom widget children |
| `WelkSwitch` | Parent-controlled state, tappable label, animated thumb, disabled states |
| `WelkCard` | Informational or actionable content, optional icon, configurable tap feedback |
| `WelkMenu` | Standard and nested navigation, collapsible toggle, active-route highlighting |

## Quick start

Requires **Dart 3.13.4+** and a compatible Flutter SDK satisfying the package's
Flutter **3.35.0+** constraint. The package targets **Android and iOS**.

### Add the dependency

Install from [pub.dev](https://pub.dev/packages/welkui_flutter):

```sh
flutter pub add welkui_flutter
```

Or add the equivalent dependency to `pubspec.yaml`:

```yaml
dependencies:
  welkui_flutter: ^0.0.3
```

Run `flutter pub get`, then import the public library:

```dart
import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';
```

### Your first WelkUI screen

```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFDF5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelkCard(
                  title: 'Hello, WelkUI!',
                  subtitle: 'A little personality for your next mobile app.',
                  icon: const Icon(Icons.auto_awesome),
                ),
                const SizedBox(height: 24),
                WelkButton(
                  onPressed: () {},
                  child: const Text("Let's build"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Meet the widgets

### WelkButton

A slightly tilted, outlined button with a solid shadow that compresses on tap.
The default is `primary` and `medium`. A null `onPressed` disables interaction.

```dart
WelkButton(
  variant: WelkButtonVariant.primary,
  size: WelkButtonSize.medium,
  onPressed: () {},
  child: const Text('Save changes'),
)
```

| Option | Values |
| --- | --- |
| `variant` | `primary`, `secondary`, `error`, `warning`, `ghost`, `info`, `success` |
| `size` | `small`, `medium`, `large` |
| `child` | Any widget, including an icon/text composition |

Even the transparent `ghost` variant keeps the WelkUI outline and hard shadow.

### WelkSwitch

A compact switch with a visible label and a subtly asymmetric track. The
parent owns the value; tapping either the track or label toggles once.

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

Set `onChanged: null` to disable the complete switch/label row.

### WelkCard

A paper card with asymmetric corners, space for an optional icon, and content
that wraps. Add `onPressed` to make it actionable.

```dart
WelkCard(
  title: 'Your workspace',
  subtitle: 'Manage members, projects, and settings in one place.',
  icon: const Icon(Icons.arrow_forward),
  onPressed: () {},
  enableFeedback: true,
)
```

| Treatment | Configuration |
| --- | --- |
| Informational | Omit `onPressed`; stays fully opaque without button semantics |
| Actionable | Provide `onPressed`; tap translates the card and compresses its shadow |
| Disabled action | Provide `onPressed` and set `enabled: false` |
| No tap animation | Set `enableFeedback: false`; the action still works |

### WelkMenu

Navigation with crisp separators, accent-filled active destinations, and nested
paper panels. The menu supplies selection callbacks rather than assuming a
particular router.

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

Register the destinations with your app's navigator. The parent owns navigation
and `activeRoute`, and routes must be unique within each menu.

| Option | Behavior |
| --- | --- |
| `WelkMenuVariant.standard` | Default; displays root destinations only |
| `WelkMenuVariant.nested` | Expandable branches with links to parent and child destinations |
| `collapsible: true` | Adds a menu toggle; initially expanded |
| `activeRoute` | Highlights the matching destination |
| `onSelected: null` | Disables destination actions |

The menu is 288 logical pixels wide, capped by the available space. Branches
dismiss on outside interaction or selection. Keyboard users can navigate with
Tab, activate with Enter/Space, and dismiss with Escape.

## Make it yours

Defaults work without a theme wrapper. Override shared styling with
`WelkTheme` and immutable `WelkThemeData`:

```dart
WelkTheme(
  data: const WelkThemeData().copyWith(
    accent: const Color(0xFFFFD166),
    ink: const Color(0xFF202020),
    paper: const Color(0xFFFFFDF5),
  ),
  child: WelkButton(
    onPressed: () {},
    child: const Text('Your colors. WelkUI character.'),
  ),
)
```

### Typography, without the network

**Short Stack is bundled locally** and registered by the package. Consuming
apps do not need to declare font assets or download fonts at runtime.

The supplied font is regular; button labels and card titles request weight
700 using that file, not a separate bold download. Flutter text scaling is
preserved.

To use the same typography outside the widgets:

```dart
const Text(
  'Made with WelkUI',
  style: TextStyle(
    fontFamily: 'ShortStack',
    package: 'welkui_flutter',
    fontSize: 20,
  ),
)
```

## Run the example

The example uses the actual package widgets through a local path dependency.
Start an Android emulator or iOS simulator, or connect a mobile device:

```sh
flutter pub get
cd example
flutter run
```

The initial menu links to a dedicated screen for each widget:

| Route | Explore |
| --- | --- |
| `/` | Parent menu and widget navigation |
| `/button` | All seven variants, all three sizes, disabled states, custom children |
| `/switch` | Controlled on/off values, disabled states, long labels, RTL |
| `/card` | Icons, long content, informational/actionable states, feedback options |
| `/menu` | Standard, nested, collapsible, active-route, disabled, and RTL examples |

Use the back button to return to the parent menu.

## Local development

To consume a local checkout from another app, use a path dependency:

```yaml
dependencies:
  welkui_flutter:
    path: ../welkUI-flutter
```

From the repository root:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
(cd example && flutter test)
```

Visual regression tests load the bundled font and compare deterministic
renders against the images in `test/goldens/`.

## License

WelkUI Flutter is released under the [MIT License](LICENSE).
Short Stack is distributed under the
[SIL Open Font License 1.1](assets/font/short_stack/OFL.txt).

---

<p align="center">
  Built by <a href="https://github.com/welkdock">Welkdock</a>.<br>
  <a href="https://ui.welkdock.com/flutter"><strong>Explore the full Flutter documentation &rarr;</strong></a>
</p>
