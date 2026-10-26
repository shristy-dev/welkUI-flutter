import 'package:flutter/widgets.dart';

/// Shares the example app's global theme toggle across preview routes.
class ExampleThemeMode extends InheritedWidget {
  const ExampleThemeMode({
    super.key,
    required this.darkMode,
    required this.toggle,
    required super.child,
  });

  final bool darkMode;
  final VoidCallback toggle;

  static ExampleThemeMode of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExampleThemeMode>()!;

  @override
  bool updateShouldNotify(ExampleThemeMode oldWidget) =>
      darkMode != oldWidget.darkMode || toggle != oldWidget.toggle;
}
