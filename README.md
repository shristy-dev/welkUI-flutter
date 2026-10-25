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

## Contributing & license

See the [contribution guidelines](CONTRIBUTING.md) for setup and pull requests.
Released under the [MIT License](LICENSE); the bundled Short Stack font uses
the [SIL Open Font License 1.1](assets/font/short_stack/OFL.txt).
