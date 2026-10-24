import 'package:flutter/material.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_tap_feedback.dart';

/// The visual treatment used by a [WelkButton].
enum WelkButtonVariant {
  primary,
  secondary,
  error,
  warning,
  ghost,
  info,
  success,
}

/// The density and label size used by a [WelkButton].
enum WelkButtonSize { small, medium, large }

/// A compact, outlined action button using WelkUI's hard-shadow style.
class WelkButton extends StatefulWidget {
  const WelkButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = WelkButtonVariant.primary,
    this.size = WelkButtonSize.medium,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final WelkButtonVariant variant;
  final WelkButtonSize size;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<WelkButton> createState() => _WelkButtonState();
}

class _WelkButtonState extends State<WelkButton>
    with WelkTapFeedback<WelkButton> {
  bool _showFocus = false;

  @override
  bool get feedbackEnabled => widget.onPressed != null;

  void _activate() {
    if (widget.onPressed == null) return;
    activateFeedback();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final disabled = widget.onPressed == null;
    final reducedMotion = welkAnimationsDisabled(context);
    final duration = reducedMotion
        ? Duration.zero
        : WelkTapFeedback.transitionDuration;
    final color = switch (widget.variant) {
      WelkButtonVariant.primary => theme.accent,
      WelkButtonVariant.secondary => theme.paper,
      WelkButtonVariant.error => theme.error,
      WelkButtonVariant.warning => theme.warning,
      WelkButtonVariant.ghost => Colors.transparent,
      WelkButtonVariant.info => theme.info,
      WelkButtonVariant.success => theme.success,
    };
    final size = switch (widget.size) {
      WelkButtonSize.small => (vertical: 6.4, horizontal: 12.0, font: 14.0),
      WelkButtonSize.medium => (vertical: 10.4, horizontal: 17.6, font: 16.0),
      WelkButtonSize.large => (vertical: 13.6, horizontal: 24.0, font: 18.0),
    };
    final pressed = !disabled && feedbackPressed;
    final shape = WelkShapeBorder(
      radii: welkButtonRadii,
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    final surface = TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: Curves.ease,
      tween: Tween<Offset>(
        end: pressed ? const Offset(1, 1) : theme.buttonShadowOffset,
      ),
      builder: (context, shadowOffset, child) => CustomPaint(
        painter: WelkHardShadowPainter(
          shape: shape,
          color: theme.ink,
          offset: shadowOffset,
        ),
        child: child,
      ),
      child: Container(
        decoration: ShapeDecoration(color: color, shape: shape),
        padding: EdgeInsets.symmetric(
          vertical: size.vertical + theme.borderWidth,
          horizontal: size.horizontal + theme.borderWidth,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.ink,
            fontFamily: theme.fontFamily,
            package: theme.fontPackage,
            fontSize: size.font,
            fontWeight: FontWeight.w700,
          ),
          child: widget.child,
        ),
      ),
    );
    final button = AnimatedContainer(
      duration: duration,
      curve: Curves.ease,
      transform: Matrix4.translationValues(
        pressed ? 2.0 : 0.0,
        pressed ? 2.0 : 0.0,
        0,
      ),
      child: Transform.rotate(
        angle: -0.017453292519943295,
        child: WelkFocusRing(
          visible: _showFocus && !disabled,
          color: theme.focus,
          shape: shape,
          gap: 5,
          child: surface,
        ),
      ),
    );

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: FocusableActionDetector(
        enabled: !disabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (show) => setState(() => _showFocus = show),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (!disabled) _activate();
              return null;
            },
          ),
        },
        child: Semantics(
          button: true,
          enabled: !disabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : _activate,
            onTapDown: disabled ? null : (_) => pressFeedback(),
            onTapUp: disabled ? null : (_) => releaseFeedback(),
            onTapCancel: disabled
                ? null
                : () => releaseFeedback(cancelled: true),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(widthFactor: 1, heightFactor: 1, child: button),
            ),
          ),
        ),
      ),
    );
  }
}
