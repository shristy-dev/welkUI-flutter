# WelkUI mobile example

This Android/iOS Flutter app uses the package from the repository root through
a local path dependency.

From the repository root:

```sh
cd example
flutter pub get
flutter run
```

The initial route (`/`) uses `WelkMenu` to navigate to dedicated widget screens:

| Route | Examples |
| --- | --- |
| `/button` | Seven variants, three sizes, disabled states, custom children |
| `/switch` | Controlled on/off values, disabled states, long labels, RTL |
| `/card` | Actionable, informational, disabled, feedback off, icons, long content |
| `/menu` | Standard, nested, collapsible, active route, disabled destinations, RTL |

Use the back button to return to the parent menu.

## Documentation previews

The package remains Android/iOS-only; the example also builds for web to provide
embeddable documentation previews. It uses Flutter's default hash routing.

```sh
flutter run -d chrome --web-port 8080
```

Open `http://localhost:8080/?embed=1#/card` for the card preview. The real query
parameter `embed=1` hides the app bar and navigation chrome, while the hash
selects `/button`, `/switch`, `/card`, or `/menu`. Content scrolls within the
iframe; a 360 by 740 CSS-pixel phone viewport is a useful starting point.

The GitHub Actions preview workflow builds with base href `/welkUI-flutter/`
and deploys to `https://welkdock.github.io/welkUI-flutter/`. Enable GitHub Pages
with source **GitHub Actions** in repository Settings, then push to `main` or run
the workflow manually. For example, embed:

```html
<iframe
  src="https://welkdock.github.io/welkUI-flutter/?embed=1#/card"
  title="WelkCard live preview"
  width="360"
  height="740"
  style="border: 0;"
></iframe>
```
