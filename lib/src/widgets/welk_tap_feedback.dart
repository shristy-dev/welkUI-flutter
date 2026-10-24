import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/welk_theme.dart';

/// Keeps quick taps visible without delaying activation callbacks.
mixin WelkTapFeedback<T extends StatefulWidget> on State<T> {
  static const transitionDuration = Duration(milliseconds: 120);

  bool get feedbackEnabled;

  bool feedbackPressed = false;
  bool _released = false;
  Timer? _pressTimer;

  void pressFeedback() {
    if (!feedbackEnabled) return;
    _pressTimer?.cancel();
    _released = false;
    if (!welkAnimationsDisabled(context)) {
      _pressTimer = Timer(transitionDuration, () {
        if (_released) setState(() => feedbackPressed = false);
      });
    }
    if (!feedbackPressed) setState(() => feedbackPressed = true);
  }

  void releaseFeedback({bool cancelled = false}) {
    _released = true;
    if (!cancelled &&
        feedbackEnabled &&
        !welkAnimationsDisabled(context) &&
        (_pressTimer?.isActive ?? false)) {
      return;
    }
    _pressTimer?.cancel();
    if (feedbackPressed) setState(() => feedbackPressed = false);
  }

  void activateFeedback() {
    if (!feedbackPressed) {
      pressFeedback();
      releaseFeedback();
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!feedbackEnabled) {
      _pressTimer?.cancel();
      feedbackPressed = false;
    }
  }

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }
}
