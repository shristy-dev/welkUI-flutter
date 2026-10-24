# Contributing to WelkUI Flutter

Thanks for helping improve WelkUI Flutter. Contributions should preserve its
visual identity, accessibility, and native mobile behavior.

## Before you start

Search [existing issues](https://github.com/welkdock/welkUI-flutter/issues) and
pull requests before opening a new one. For a new widget, public API change,
dependency, or substantial redesign, open an issue to discuss the approach first.
Small bug fixes and documentation corrections can go directly to a pull request.

For bug reports, include the Flutter version, device/OS, steps to reproduce,
expected and actual behavior, and a minimal reproduction. Add screenshots or
logs where useful, but remove credentials and personal information.

## Development setup

Use Flutter **3.47.5** (the version pinned in
[CI](.github/workflows/preview.yml)), which includes a compatible Dart SDK.
Use macOS for golden comparisons. Android development requires the Android SDK;
iOS development requires macOS, Xcode, and an available simulator or device.

Fork the repository if you do not have write access, clone your fork, and create
a focused branch:

```sh
git clone https://github.com/YOUR_USERNAME/welkUI-flutter.git
cd welkUI-flutter
git switch -c fix/describe-your-change
flutter pub get
cd example
flutter pub get
flutter run
```

The example depends on the package locally. To use your checkout from another
app, add:

```yaml
dependencies:
  welkui_flutter:
    path: ../welkUI-flutter
```

## Project structure and scope

| Path | Purpose |
| --- | --- |
| `lib/welkui_flutter.dart` | Public package exports |
| `lib/src/` | Widgets, shared theme, and painting helpers |
| `assets/font/short_stack/` | Bundled font and its license |
| `test/` | Behavior tests, golden comparisons, and approved images |
| `example/` | Widget gallery and documentation previews |

The package targets **Android and iOS**. The example's web build exists only for
embeddable documentation previews; do not expand package platform support or
add a separate documentation site as part of an unrelated change.

## Code and design guidelines

- Keep changes focused and follow the existing Dart conventions and shared helpers.
- Preserve WelkUI's colors, asymmetric shapes, crisp outlines, hard shadows, and
  bundled typography. Avoid Material elevation, gradients, and invented motion.
- Preserve public APIs unless a change has been discussed and approved.
- Maintain touch targets, coherent semantics, keyboard access, RTL behavior,
  text scaling, and reduced-motion support.
- Keep controlled state in the parent where the API requires it. Avoid duplicate
  callbacks or accessibility announcements.
- Avoid new runtime dependencies unless necessary and agreed upon.
- Keep documentation and example usage consistent with the implementation.

Refer to the [Flutter documentation](https://ui.welkdock.com/flutter) and the
[React design reference](https://github.com/welkdock/welkUI) when working on
component fidelity. Ask for clarification rather than redesigning a component.

## Required checks

Run these commands from the repository root:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
(
  cd example
  flutter pub get
  dart format --output=none --set-exit-if-changed .
  flutter analyze
  flutter test
)
```

Use `dart format .` to apply formatting if needed. Add focused regression tests
for changed behavior, including relevant disabled, accessibility, layout, and
reduced-motion cases. Exercise UI changes on Android and iOS where available;
state clearly in the PR which platforms you could not run.

For preview-related changes, also run:

```sh
cd example
flutter build web --release --base-href /welkUI-flutter/
flutter run -d chrome --web-port 8080
```

Open `http://localhost:8080/?embed=1#/card` and the other affected widget routes.
Check that navigation chrome is hidden and content scrolls in a 360 by 740
viewport. Keep default hash routing and iframe compatibility.

### Golden images

Generate and compare goldens on **macOS with Flutter 3.47.5**, matching CI.
Do not update baselines simply to silence a failure. First inspect the expected,
actual, and difference images; CI uploads these as the `golden-failures` artifact.

For an approved, intentional visual change:

```sh
flutter test test/welk_widgets_golden_test.dart --update-goldens
flutter test
```

Review and include the changed PNGs in your PR. The widget-gallery comparator
allows only measured rasterization noise: at most 0.05% changed pixels, each
with an RGB-channel difference of at most 16/255. Dimensions and alpha remain
exact, and the menu comparison is pixel-exact. Do not loosen these bounds or
skip tests to hide a regression.

## Pull requests

Open a PR targeting `main` with a clear title and a concise explanation of the
problem, solution, and any compatibility implications. Link related issues.
Include the commands you ran and their results; add before/after screenshots
for visual changes and identify any unavailable device coverage.

Keep unrelated refactors and generated build output out of the PR. Respond to
review feedback and ensure the required checks pass before merging.

## Versions and releases

Coordinate version bumps with maintainers to avoid conflicting release numbers.
Release-bound changes need a matching version in `pubspec.yaml`, an accurate
entry at the top of `CHANGELOG.md`, and an updated example lockfile after
`flutter pub get`. Describe user-visible changes rather than copying commit
messages. Maintainers decide whether multiple contributions share a release.

Before publishing, maintainers run:

```sh
dart pub publish --dry-run
```

Review the archive contents and resolve warnings from a clean checkout.
Do not include `example/build/`, credentials, or other generated artifacts.
Publishing to pub.dev is a maintainer action, not part of submitting a PR.

## License and collaboration

By submitting a contribution, you agree that it may be distributed under the
repository's [MIT License](LICENSE). Include only material you have the right to
contribute, preserve third-party notices, and retain the bundled font's
[SIL Open Font License](assets/font/short_stack/OFL.txt).

Be respectful and constructive in issues and reviews. Discuss the code and
behavior, not the person.
