import 'package:flutter/material.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_tap_feedback.dart';

enum WelkIconButtonVariant { standard, text }

/// An accessible icon action. The painted 44px icon has a 48px touch target.
class WelkIconButton extends StatefulWidget {
  const WelkIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.variant = WelkIconButtonVariant.standard,
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
  }) : _close = false,
       _dialog = false;

  /// The unshadowed paper close action used by Welk modal surfaces.
  ///
  /// Paints the neutral paper surface (muted on hover) rather than the accent.
  const WelkIconButton.close({
    super.key,
    required this.label,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
    bool dialog = false,
  }) : icon = const Icon(Icons.close),
       variant = WelkIconButtonVariant.standard,
       _close = true,
       // Keep the close-specific option out of the standard action API.
       // ignore: prefer_initializing_formals
       _dialog = dialog;

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final WelkIconButtonVariant variant;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;
  final bool _close;
  final bool _dialog;

  @override
  State<WelkIconButton> createState() => _WelkIconButtonState();
}

class _WelkIconButtonState extends State<WelkIconButton>
    with WelkTapFeedback<WelkIconButton> {
  bool _focused = false;
  bool _hovered = false;

  @override
  bool get feedbackEnabled => widget.onPressed != null;

  void _activate() {
    if (!feedbackEnabled) return;
    activateFeedback();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: widget.overRideDarkMode);
    final text = widget.variant == WelkIconButtonVariant.text;
    final hovered = _hovered && feedbackEnabled;
    final fill = widget._close
        ? (hovered ? theme.muted : theme.paper)
        : (hovered ? theme.accentHover : theme.accent);
    final foreground = widget._close ? theme.ink : theme.onFill(fill);
    final shape = WelkShapeBorder(
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
      radii: widget._close && !widget._dialog
          ? const WelkCornerRadii(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(6),
            )
          : text
          ? const WelkCornerRadii(
              topLeft: Radius.elliptical(10, 7),
              topRight: Radius.elliptical(6, 12),
              bottomRight: Radius.elliptical(12, 6),
              bottomLeft: Radius.elliptical(7, 10),
            )
          : const WelkCornerRadii(
              topLeft: Radius.elliptical(7.92, 5.28),
              topRight: Radius.elliptical(4.4, 9.68),
              bottomRight: Radius.elliptical(8.8, 6.16),
              bottomLeft: Radius.elliptical(5.28, 7.92),
            ),
    );
    final pressed = feedbackEnabled && feedbackPressed;
    final dimension = widget._dialog ? 40.0 : 44.0;
    final surface = CustomPaint(
      painter: WelkHardShadowPainter(
        shape: shape,
        color: theme.shadow,
        offset: widget._close
            ? Offset.zero
            : pressed
            ? const Offset(1, 1)
            : const Offset(3, 3),
      ),
      child: Container(
        width: text ? null : dimension,
        constraints: BoxConstraints(minHeight: dimension),
        padding: EdgeInsets.symmetric(
          horizontal: text ? 15.6 : 2,
          vertical: text ? 11.6 : 2,
        ),
        decoration: ShapeDecoration(shape: shape, color: fill),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: IconTheme(
                data: IconThemeData(size: 20, color: foreground),
                child: SizedBox(width: 20, height: 20, child: widget.icon),
              ),
            ),
            if (text) ...[
              const SizedBox(width: 9.6),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    package: theme.fontPackage,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    final button = Opacity(
      opacity: feedbackEnabled ? 1 : 0.55,
      child: FocusableActionDetector(
        enabled: feedbackEnabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: Semantics(
          container: true,
          label: widget.label,
          button: true,
          enabled: feedbackEnabled,
          excludeSemantics: true,
          onTap: feedbackEnabled ? _activate : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: feedbackEnabled ? _activate : null,
            onTapDown: feedbackEnabled ? (_) => pressFeedback() : null,
            onTapUp: feedbackEnabled ? (_) => releaseFeedback() : null,
            onTapCancel: feedbackEnabled
                ? () => releaseFeedback(cancelled: true)
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: AnimatedContainer(
                  duration: welkAnimationsDisabled(context)
                      ? Duration.zero
                      : WelkTapFeedback.transitionDuration,
                  transform: Matrix4.translationValues(
                    pressed && !widget._close ? 2 : 0,
                    pressed && !widget._close ? 2 : 0,
                    0,
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: widget._close
                        ? (Matrix4.identity()
                            ..rotateZ(widget._dialog ? -0.0349066 : 0))
                        : (Matrix4.identity()
                            ..rotateZ(-0.0349066)
                            ..setEntry(0, 1, -0.017455)
                            ..setEntry(1, 0, 0.008727)),
                    child: WelkFocusRing(
                      visible: _focused && feedbackEnabled,
                      color: theme.focus,
                      shape: shape,
                      gap: 5,
                      child: surface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: widget.overRideDarkMode,
      child: button,
    );
  }
}
