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
| `/image` | Network and asset images, automatic comic and custom fallbacks |
| `/accordion` | Expandable content and disabled sections |
| `/attachment` | App-owned selection, file lists, validation, removal |
| `/avatar` | Reference portraits, custom images and icons, three sizes |
| `/badge` | Status colors and sizes |
| `/breadcrumbs` | Linked and current destinations, custom separators |
| `/checkbox` | Checked, unchecked, indeterminate, disabled |
| `/date-input` | Editable date field with a mobile calendar popup |
| `/date-picker` | Inline calendar, month navigation, allowed date ranges |
| `/dialog` | Modal content, dismissal, focus and actions |
| `/divider` | Separators and labels |
| `/drawer` | Drawers from all four edges |
| `/dropdown` | Controlled options and disabled states |
| `/icon-button` | Icon actions, variants and sizes |
| `/input` | Text fields, errors, disabled and other field treatments |
| `/otp-input` | One-time code entry and completion |
| `/qr-code` | Rounded and square modules, card treatment, URL validation |
| `/radio` | Controlled choices and disabled states |
| `/radio-group` | Grouped single-selection choices |
| `/range-slider` | Controlled ranges, steps and disabled states |
| `/snackbar` | Feedback variants and dismissal |
| `/sticker` | Outlined comic artwork, image fallbacks and entrance motion |
| `/sticker-card` | Decorated content cards |
| `/tabs` | Controlled panels and disabled tabs |
| `/time-picker` | Hours, minutes, optional seconds and manual entry |
| `/tooltip` | Long-press, focus, and pointer hints |

Use the back button to return to the parent menu.

Both date calendars show complete Monday-to-Sunday weeks without horizontal
scrolling. On narrow layouts, day targets become narrower than 48 pixels while
remaining at least 48 pixels tall; labels scale down only when necessary to fit
their column. Popup calendars scroll vertically if the viewport is too short.

`WelkImage.network(url, fallbackAsset: 'assets/placeholder.jpg')` uses the
consumer's asset on failure. Omit `fallbackAsset` to select one of five bundled
comic images once per failed source. `WelkImage.asset('assets/photo.jpg')` loads
a local asset. Both support `width`, `height`, `fit`, `alignment`, and
`semanticLabel`; the default frame is 4:3. Declare your own assets in your app's
pubspec. Use `package` (or `fallbackPackage`) for another package's assets.
Android consumers must declare `android.permission.INTERNET` for network images.
Invalid local or fallback assets surface normal Flutter image errors.

## Documentation previews

The package remains Android/iOS-only; the example also builds for web to provide
embeddable documentation previews. It uses Flutter's default hash routing.

```sh
flutter run -d chrome --web-port 8080
```

Open `http://localhost:8080/?embed=1#/card` for the card preview. The real query
parameter `embed=1` hides the app bar and navigation chrome, while the hash
selects any widget route from the table above. Content scrolls within the
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

The full catalog is defined in `lib/widget_catalog.dart`, which powers both
home navigation and named routes. QR codes are encoded locally (no service or
network request) using the pure-Dart `qr` dependency.

## Mobile behavior

The demos keep the React component palette, outlines, asymmetric corners, hard
shadows, and bundled Short Stack font. Touch targets and keyboard/semantics
behavior are implemented with Flutter widgets rather than browser elements.
Tooltips support touch interaction; modal controls use Flutter routes and
respect system back navigation. File selection/upload and destination routing
remain application responsibilities, not simulated backend services.

Use `flutter test` in this directory to exercise every catalog route at a
320-pixel width with larger text. Representative screen goldens load the bundled
font; behavioral tests also cover the widgets independently in the root suite.
