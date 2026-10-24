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
