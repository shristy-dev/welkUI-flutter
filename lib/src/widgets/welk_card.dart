import 'package:flutter/material.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_tap_feedback.dart';

/// A WelkUI content card that can optionally behave as an action.
class WelkCard extends StatefulWidget {
  const WelkCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.onPressed,
    this.enabled = true,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
  });

  final String title;
  final String subtitle;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// Set to false together with [onPressed] to show a disabled action card.
  ///
  /// A card with no [onPressed] remains informational and fully opaque.
  final bool enabled;

  /// Whether actionable cards animate down and compress their shadow on tap.
  ///
  /// Does not affect activation or keyboard focus. Defaults to true and
  /// respects the platform's reduced-motion preference.
  final bool enableFeedback;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  @override
  State<WelkCard> createState() => _WelkCardState();
}

class _WelkCardState extends State<WelkCard> with WelkTapFeedback<WelkCard> {
  bool _showFocus = false;

  @override
  bool get feedbackEnabled =>
      widget.onPressed != null && widget.enabled && widget.enableFeedback;

  void _activate() {
    if (!widget.enabled || widget.onPressed == null) return;
    activateFeedback();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: widget.overRideDarkMode);
    final interactive = widget.onPressed != null;
    final enabled = interactive && widget.enabled;
    final pressed = feedbackEnabled && feedbackPressed;
    final duration = !widget.enableFeedback || welkAnimationsDisabled(context)
        ? Duration.zero
        : WelkTapFeedback.transitionDuration;
    final shape = WelkShapeBorder(
      radii: welkCardRadii,
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
    );

    final content = TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: Curves.ease,
      tween: Tween<Offset>(
        end: pressed ? const Offset(1, 1) : theme.cardShadowOffset,
      ),
      builder: (context, shadowOffset, child) => CustomPaint(
        painter: WelkHardShadowPainter(
          shape: shape,
          color: theme.shadow,
          offset: shadowOffset,
        ),
        child: child,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(
          20 + theme.borderWidth,
          20 + theme.borderWidth,
          64 + theme.borderWidth,
          20 + theme.borderWidth,
        ),
        decoration: ShapeDecoration(color: theme.paper, shape: shape),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  softWrap: true,
                  style: TextStyle(
                    color: theme.ink,
                    fontFamily: theme.fontFamily,
                    package: theme.fontPackage,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  softWrap: true,
                  style: TextStyle(
                    color: theme.ink,
                    fontFamily: theme.fontFamily,
                    package: theme.fontPackage,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
            if (widget.icon != null)
              PositionedDirectional(
                top: 0,
                end: -44,
                width: 24,
                height: 24,
                child: ExcludeSemantics(
                  child: theme.isDark
                      ? IconTheme.merge(
                          data: IconThemeData(color: theme.ink),
                          child: widget.icon!,
                        )
                      : widget.icon!,
                ),
              ),
          ],
        ),
      ),
    );

    final shapedContent = WelkFocusRing(
      visible: _showFocus && enabled,
      color: theme.focus,
      shape: shape,
      gap: 4,
      child: content,
    );

    if (!interactive) {
      return WelkTheme.scope(
        context,
        overRideDarkMode: widget.overRideDarkMode,
        child: shapedContent,
      );
    }

    final card = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (show) => setState(() => _showFocus = show),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (enabled) _activate();
              return null;
            },
          ),
        },
        child: Semantics(
          container: true,
          label: '${widget.title}. ${widget.subtitle}',
          button: true,
          enabled: enabled,
          onTap: enabled ? _activate : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? _activate : null,
            onTapDown: enabled ? (_) => pressFeedback() : null,
            onTapUp: enabled ? (_) => releaseFeedback() : null,
            onTapCancel: enabled
                ? () => releaseFeedback(cancelled: true)
                : null,
            child: ExcludeSemantics(
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.ease,
                transform: Matrix4.translationValues(
                  pressed ? 2 : 0,
                  pressed ? 2 : 0,
                  0,
                ),
                child: shapedContent,
              ),
            ),
          ),
        ),
      ),
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: widget.overRideDarkMode,
      child: card,
    );
  }
}
