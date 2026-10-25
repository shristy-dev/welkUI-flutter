import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkTooltipVariant {
  bubble,
  speech,

  /// Compatibility with the original React spelling.
  speach,
}

/// A collision-aware tooltip shown on hover, keyboard focus or long press.
class WelkTooltip extends StatefulWidget {
  const WelkTooltip({
    super.key,
    required this.content,
    required this.child,
    this.variant = WelkTooltipVariant.bubble,
  });

  final String content;
  final Widget child;
  final WelkTooltipVariant variant;

  @override
  State<WelkTooltip> createState() => _WelkTooltipState();
}

class _WelkTooltipState extends State<WelkTooltip> {
  final _tooltip = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final shape = _TooltipShape(
      bubble: widget.variant == WelkTooltipVariant.bubble,
      ink: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Tooltip.dismissAllToolTips();
              return null;
            },
          ),
        },
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) {
            if (focused) {
              _tooltip.currentState?.ensureTooltipVisible();
            } else {
              Tooltip.dismissAllToolTips();
            }
          },
          child: Semantics(
            tooltip: widget.content,
            child: Tooltip(
              key: _tooltip,
              excludeFromSemantics: true,
              richMessage: WidgetSpan(
                child: _TooltipSurface(content: widget.content, shape: shape),
              ),
              triggerMode: TooltipTriggerMode.longPress,
              preferBelow: false,
              enableTapToDismiss: true,
              verticalOffset: 16,
              showDuration: const Duration(seconds: 4),
              waitDuration: const Duration(milliseconds: 100),
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.sizeOf(context).width * .8).clamp(0, 256),
              ),
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(),
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                color: theme.ink,
                fontSize: 14,
                height: 1.5,
                fontFamily: theme.fontFamily,
                package: theme.fontPackage,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipSurface extends StatelessWidget {
  const _TooltipSurface({required this.content, required this.shape});
  final String content;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final reduced = welkAnimationsDisabled(context);
    return TweenAnimationBuilder<double>(
      duration: reduced ? Duration.zero : const Duration(milliseconds: 220),
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      curve: const Cubic(.2, 1.4, .5, 1),
      builder: (context, progress, child) => Transform.translate(
        offset: Offset(0, (1 - progress) * 6),
        child: Transform.rotate(
          angle: (-6 + 4 * progress) * .01745329252,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(
            scale: .8 + .2 * progress,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
      child: CustomPaint(
        painter: WelkHardShadowPainter(
          shape: shape,
          color: theme.ink,
          offset: const Offset(3, 3),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(context).width * .8).clamp(0, 256),
          ),
          decoration: ShapeDecoration(color: theme.paper, shape: shape),
          padding: const EdgeInsets.fromLTRB(16, 12.8, 16, 28.8),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.ink,
              fontSize: 14,
              height: 1.5,
              fontFamily: theme.fontFamily,
              package: theme.fontPackage,
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipShape extends ShapeBorder {
  const _TooltipShape({
    required this.bubble,
    required this.ink,
    required this.strokeWidth,
  });

  final bool bubble;
  final Color ink;
  final double strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final body = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom - 16,
    );
    final radii = bubble
        ? WelkCornerRadii(
            topLeft: Radius.elliptical(body.width * .45, body.height * .40),
            topRight: Radius.elliptical(body.width * .38, body.height * .48),
            bottomRight: Radius.elliptical(body.width * .43, body.height * .38),
            bottomLeft: Radius.elliptical(body.width * .35, body.height * .45),
          )
        : const WelkCornerRadii(
            topLeft: Radius.elliptical(16, 12),
            topRight: Radius.elliptical(10, 18),
            bottomRight: Radius.elliptical(18, 10),
            bottomLeft: Radius.elliptical(12, 16),
          );
    final path = WelkShapeBorder(radii: radii).getOuterPath(body);
    if (bubble) {
      return path
        ..addOval(
          Rect.fromLTWH(
            body.left + body.width * .42,
            body.bottom + 1.6,
            11.2,
            8.8,
          ),
        )
        ..addOval(Rect.fromLTWH(body.center.dx, body.bottom + 12, 4.8, 4));
    }
    final tail = Path()
      ..moveTo(body.center.dx - 6.4, body.bottom - 2)
      ..lineTo(body.center.dx + 4, body.bottom + 8)
      ..lineTo(body.center.dx + 8, body.bottom - 2)
      ..close();
    return Path.combine(PathOperation.union, path, tail);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(strokeWidth), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
      getOuterPath(rect.deflate(strokeWidth / 2)),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  ShapeBorder scale(double t) =>
      _TooltipShape(bubble: bubble, ink: ink, strokeWidth: strokeWidth * t);
}
