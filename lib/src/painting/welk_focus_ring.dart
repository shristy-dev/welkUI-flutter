import 'package:flutter/material.dart';

import 'welk_shape_border.dart';

/// Paints a focus outline outside [child] without changing its layout size.
class WelkFocusRing extends StatelessWidget {
  const WelkFocusRing({
    super.key,
    required this.child,
    required this.visible,
    required this.color,
    required this.shape,
    required this.gap,
  });

  final Widget child;
  final bool visible;
  final Color color;
  final ShapeBorder shape;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    final strokeWidth = 3.0;
    final padding = gap + strokeWidth + 1;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          left: -padding,
          top: -padding,
          right: -padding,
          bottom: -padding,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WelkFocusPainter(
                shape: _expandedShape(shape, gap + strokeWidth / 2, color),
                gap: gap,
                strokeWidth: strokeWidth,
                padding: padding,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }

  ShapeBorder _expandedShape(ShapeBorder shape, double amount, Color color) {
    if (shape is WelkShapeBorder) {
      return WelkShapeBorder(
        radii: shape.radii.inflate(amount + 1.5),
        strokeColor: color,
        strokeWidth: 3,
      );
    }
    if (shape is RoundedRectangleBorder) {
      final borderRadius = shape.borderRadius.resolve(TextDirection.ltr);
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: borderRadius.topLeft + Radius.circular(amount),
          topRight: borderRadius.topRight + Radius.circular(amount),
          bottomRight: borderRadius.bottomRight + Radius.circular(amount),
          bottomLeft: borderRadius.bottomLeft + Radius.circular(amount),
        ),
        side: BorderSide(color: color, width: 3),
      );
    }
    return shape;
  }
}

class _WelkFocusPainter extends CustomPainter {
  const _WelkFocusPainter({
    required this.shape,
    required this.gap,
    required this.strokeWidth,
    required this.padding,
  });

  final ShapeBorder shape;
  final double gap;
  final double strokeWidth;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final outset = gap + strokeWidth;
    shape.paint(
      canvas,
      Rect.fromLTWH(
        padding - outset,
        padding - outset,
        size.width - (padding - outset) * 2,
        size.height - (padding - outset) * 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_WelkFocusPainter oldDelegate) =>
      shape != oldDelegate.shape || gap != oldDelegate.gap;
}
