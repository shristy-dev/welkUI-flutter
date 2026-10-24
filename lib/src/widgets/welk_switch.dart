import 'package:flutter/material.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// A controlled WelkUI switch with a single accessible switch semantics node.
class WelkSwitch extends StatefulWidget {
  const WelkSwitch({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<WelkSwitch> createState() => _WelkSwitchState();
}

class _WelkSwitchState extends State<WelkSwitch> {
  bool _showFocus = false;

  void _toggle() {
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final enabled = widget.onChanged != null;
    final reducedMotion = welkAnimationsDisabled(context);
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final textDirection = Directionality.of(context);
    final trackShape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(15, 14),
        topRight: Radius.elliptical(12, 13),
        bottomRight: Radius.elliptical(15, 14),
        bottomLeft: Radius.elliptical(13, 12),
      ),
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    final track = CustomPaint(
      painter: WelkHardShadowPainter(
        shape: trackShape,
        color: theme.ink,
        offset: theme.switchShadowOffset,
      ),
      child: SizedBox(
        width: 52,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.ease,
                decoration: ShapeDecoration(
                  color: widget.value ? theme.accent : theme.muted,
                  shape: trackShape,
                ),
              ),
            ),
            AnimatedPositionedDirectional(
              duration: duration,
              curve: const Cubic(0.2, 1.4, 0.5, 1),
              start: widget.value ? 28 : 4,
              top: 4,
              width: 20,
              height: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.paper,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.ink,
                    width: theme.borderWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (show) => setState(() => _showFocus = show),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (enabled) _toggle();
              return null;
            },
          ),
        },
        child: Semantics(
          container: true,
          label: widget.label,
          toggled: widget.value,
          enabled: enabled,
          onTap: enabled ? _toggle : null,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _toggle : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: textDirection,
                  children: [
                    WelkFocusRing(
                      visible: _showFocus && enabled,
                      color: theme.focus,
                      shape: trackShape,
                      gap: 4,
                      child: track,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: theme.ink,
                          fontFamily: theme.fontFamily,
                          package: theme.fontPackage,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
