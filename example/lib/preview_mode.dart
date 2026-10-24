import 'package:flutter/widgets.dart';

/// Example-only configuration for documentation iframe previews.
class PreviewMode extends InheritedWidget {
  const PreviewMode({super.key, required this.embedMode, required super.child});

  final bool embedMode;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PreviewMode>()?.embedMode ??
      false;

  @override
  bool updateShouldNotify(PreviewMode oldWidget) =>
      embedMode != oldWidget.embedMode;
}
