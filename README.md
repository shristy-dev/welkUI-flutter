<p align="center">
  <a href="https://ui.welkdock.com/flutter">
    <img src="https://raw.githubusercontent.com/welkdock/welkUI-flutter/main/assets/images/welkui-flutter-og.png" width="960" alt="WelkUI Flutter banner">
  </a>
</p>

<h1 align="center">WelkUI Flutter</h1>

<p align="center">
  <a href="https://pub.dev/packages/welkui_flutter">pub.dev</a>
  &nbsp;·&nbsp;
  <a href="https://ui.welkdock.com/flutter">Documentation</a>
  &nbsp;·&nbsp;
  <a href="CONTRIBUTING.md">Contributing</a>
  &nbsp;·&nbsp;
  <a href="LICENSE">MIT License</a>
</p>

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
  and locally bundled typography. QR encoding uses the pure-Dart `qr` package.

> **Full documentation:** [ui.welkdock.com/flutter](https://ui.welkdock.com/flutter)
>
> This README covers setup and the essentials. Visit the Flutter documentation
> for the full guide and a live preview of each widget.

## Quick start

For **Android and iOS** apps, install from pub.dev:

```sh
flutter pub add welkui_flutter
```

Or add the dependency to `pubspec.yaml` and run `flutter pub get`:

```yaml
dependencies:
  welkui_flutter: ^0.1.5
```

Requires Dart **3.13.4+** and a compatible Flutter SDK satisfying **3.35.0+**.
Short Stack is bundled locally; no additional font setup is needed.

## Widgets

| Controls & forms | Content & navigation | Overlays & utilities |
| --- | --- | --- |
| `WelkButton` | `WelkAccordion` | `WelkDialog` |
| `WelkIconButton` | `WelkAvatar` | `WelkDrawer` |
| `WelkCheckBox` | `WelkBadge` | `WelkTooltip` |
| `WelkRadio` | `WelkBreadCrumbs` | `WelkSnackBar` |
| `WelkRadioGroup` | `WelkCard` | `WelkAttachment` |
| `WelkSwitch` | `WelkDivider` | `WelkQRCode` |
| `WelkInput` | `WelkImage` | `WelkDateInput` |
| `WelkOTPInput` | `WelkMenu` | `WelkDatePicker` |
| `WelkDropDown` | `WelkSticker` | `WelkTimePicker` |
| `WelkRangeSlider` | `WelkStickerCard` | `WelkTabs` |
| | `WelkBottomNavBar` | `WelkBottomNavScaffold` |

## Bottom navigation

`WelkBottomNavScaffold` is a complete app shell for 2–5 destinations. Each
destination gets its own stateful page and nested `Navigator`, so page state is
kept while switching tabs, and `Navigator.of(context).push(...)` opens a subpage
inside the current destination.

```dart
WelkBottomNavScaffold(
  layout: WelkBottomNavLayout.popCircle, // blockCenter, popBlock, comicDock, bubbleRail
  mode: WelkBottomNavMode.floating, // or defaultMode (anchored)
  visibility: WelkBottomNavVisibility.hideOnScrollDown, // sticky, alwaysVisible
  hideOnSubpages: true,
  transition: WelkBottomNavTransition.fadeThrough,
  initialIndex: 0,
  onIndexChanged: (index) {},
  style: const WelkBottomNavStyle(height: 64, activeItemSize: 60),
  items: [
    WelkBottomNavItem(
      icon: const Icon(Icons.home_outlined),
      activeIcon: const Icon(Icons.home),
      label: 'Home',
      builder: (_) => const HomePage(),
    ),
    // ...up to five items
  ],
)
```

- **Layouts:** `popCircle`, `blockCenter`, and `popBlock` feature the middle
  destination (with 3 or 5 items); `comicDock` raises a comic tile for the
  active item; `bubbleRail` glides a bubble between items.
- **Visibility:** `sticky` stays visible while scrolling, `hideOnScrollDown`
  hides when scrolling down (tune with `scrollSensitivity`), and
  `alwaysVisible` never hides. `hideOnSubpages` (default `true`) hides the bar
  on pushed subpages and restores it on the destination's root page.
- **State:** use `WelkBottomNavScaffold.of(context)` to `select(index)` or
  `popToRoot()`. Tapping the active item again pops it to its root page.
- **Styling:** `WelkBottomNavStyle` covers colors, icons, typography, label
  behavior, height, width, margins, padding, corner radius, borders, shadows,
  elevation, active-item size, and animation duration and curve. Unset colors
  follow the WelkUI light and dark palettes.

Use the stateless `WelkBottomNavBar` (with `currentIndex` and `onTap`) to manage
pages yourself, for example as a `Scaffold.bottomNavigationBar` with
`extendBody: true`.

## Global dark mode

Set `WelkThemeData.darkMode` once in your app's `WelkTheme` to control dark mode
globally. Rebuild the provider with `data.copyWith(darkMode: true)` or `false`
to switch modes. When `darkMode` is null (the default), widgets follow
Flutter's `ThemeData.brightness`.

All WelkUI widgets consume the dark-mode preference, including controls,
content, pickers, and overlays. The example app includes a floating
`WelkIconButton` theme toggle on non-embedded screens.

```dart
WelkTheme(
  data: const WelkThemeData(darkMode: true),
  child: MaterialApp(home: MyHomePage()),
)
```

Set `overRideDarkMode` on any widget to force dark (`true`) or light (`false`),
regardless of the global setting. Omit it to inherit. Container overrides also
flow into nested WelkUI widgets; dialog, drawer, and snackbar show functions
accept the same override.

Place the global `WelkTheme` above `MaterialApp` so open popups and overlays
can also follow its updates. Local themes are carried into overlays when opened.

Dark mode adds a 10% black tint to semantic variant fills, with black borders,
whitish-gray hard shadows, and contrasting text and icons. Secondary buttons use
a charcoal-gray surface, and ghost buttons remain transparent.
Neutral surfaces and text adapt to dark mode. QR modules retain a light backing
and dark modules for scanning. Avatar portraits use black assets in light mode
and white assets in dark mode; custom icons and profile images are not filtered.
Customize the dark palette with `darkPaper`, `darkMuted`, `darkInk`, `darkOutline`,
`darkShadow`, `darkButtonTint`, and `darkFocus` design tokens.

```dart
WelkButton(
  overRideDarkMode: true,
  variant: WelkButtonVariant.secondary,
  onPressed: () {},
  child: const Text('Continue'),
)
```

## Contributing & license

See the [contribution guidelines](CONTRIBUTING.md) for setup and pull requests.
Released under the [MIT License](LICENSE); the bundled Short Stack font uses
the [SIL Open Font License 1.1](assets/font/short_stack/OFL.txt).
