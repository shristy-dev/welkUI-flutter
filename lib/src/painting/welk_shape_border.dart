import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Independent horizontal and vertical elliptical radii for each corner.
@immutable
class WelkCornerRadii {
  const WelkCornerRadii({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  final Radius topLeft;
  final Radius topRight;
  final Radius bottomRight;
  final Radius bottomLeft;

  WelkCornerRadii inset(double amount) {
    Radius adjust(Radius radius) => Radius.elliptical(
      math.max(0, radius.x - amount),
      math.max(0, radius.y - amount),
    );
    return WelkCornerRadii(
      topLeft: adjust(topLeft),
      topRight: adjust(topRight),
      bottomRight: adjust(bottomRight),
      bottomLeft: adjust(bottomLeft),
    );
  }

  WelkCornerRadii inflate(double amount) {
    Radius adjust(Radius radius) =>
        Radius.elliptical(radius.x + amount, radius.y + amount);
    return WelkCornerRadii(
      topLeft: adjust(topLeft),
      topRight: adjust(topRight),
      bottomRight: adjust(bottomRight),
      bottomLeft: adjust(bottomLeft),
    );
  }

  WelkCornerRadii scale(double scale) {
    Radius adjust(Radius radius) =>
        Radius.elliptical(radius.x * scale, radius.y * scale);
    return WelkCornerRadii(
      topLeft: adjust(topLeft),
      topRight: adjust(topRight),
      bottomRight: adjust(bottomRight),
      bottomLeft: adjust(bottomLeft),
    );
  }
}

/// A crisp outline shape with CSS-compatible elliptical corner radii.
class WelkShapeBorder extends ShapeBorder {
  const WelkShapeBorder({
    required this.radii,
    this.strokeColor = const Color(0xFF242424),
    this.strokeWidth = 2,
  });

  final WelkCornerRadii radii;
  final Color strokeColor;
  final double strokeWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  WelkCornerRadii _fit(Rect rect, WelkCornerRadii source) {
    final candidates = <double>[
      1,
      _ratio(rect.width, source.topLeft.x + source.topRight.x),
      _ratio(rect.width, source.bottomLeft.x + source.bottomRight.x),
      _ratio(rect.height, source.topLeft.y + source.bottomLeft.y),
      _ratio(rect.height, source.topRight.y + source.bottomRight.y),
    ];
    return source.scale(candidates.reduce(math.min));
  }

  double _ratio(double size, double radii) =>
      radii == 0 ? 1 : math.max(0, size / radii);

  Path _path(Rect rect, WelkCornerRadii source) {
    final fitted = _fit(rect, source);
    return Path()
      ..moveTo(rect.left + fitted.topLeft.x, rect.top)
      ..lineTo(rect.right - fitted.topRight.x, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + fitted.topRight.y),
        radius: fitted.topRight,
      )
      ..lineTo(rect.right, rect.bottom - fitted.bottomRight.y)
      ..arcToPoint(
        Offset(rect.right - fitted.bottomRight.x, rect.bottom),
        radius: fitted.bottomRight,
      )
      ..lineTo(rect.left + fitted.bottomLeft.x, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - fitted.bottomLeft.y),
        radius: fitted.bottomLeft,
      )
      ..lineTo(rect.left, rect.top + fitted.topLeft.y)
      ..arcToPoint(
        Offset(rect.left + fitted.topLeft.x, rect.top),
        radius: fitted.topLeft,
      )
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, radii);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final inset = strokeWidth;
    return _path(rect.deflate(inset), radii.inset(inset));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (strokeWidth == 0) return;
    final halfStroke = strokeWidth / 2;
    canvas.drawPath(
      _path(rect.deflate(halfStroke), radii.inset(halfStroke)),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  ShapeBorder scale(double t) => WelkShapeBorder(
    radii: radii.scale(t),
    strokeColor: strokeColor,
    strokeWidth: strokeWidth * t,
  );
}

/// Draws the unblurred silhouette beyond the shape, without tinting transparent
/// areas inside the component (notably the ghost button).
class WelkHardShadowPainter extends CustomPainter {
  const WelkHardShadowPainter({
    required this.shape,
    required this.color,
    required this.offset,
  });

  final ShapeBorder shape;
  final Color color;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final path = shape.getOuterPath(Offset.zero & size);
    final shadow = Path.combine(
      PathOperation.difference,
      path.shift(offset),
      path,
    );
    canvas.drawPath(shadow, Paint()..color = color);
  }

  @override
  bool shouldRepaint(WelkHardShadowPainter oldDelegate) =>
      shape != oldDelegate.shape ||
      color != oldDelegate.color ||
      offset != oldDelegate.offset;
}

const WelkCornerRadii welkButtonRadii = WelkCornerRadii(
  topLeft: Radius.elliptical(14, 9),
  topRight: Radius.elliptical(8, 15),
  bottomRight: Radius.elliptical(16, 8),
  bottomLeft: Radius.elliptical(9, 13),
);

const WelkCornerRadii welkCardRadii = WelkCornerRadii(
  topLeft: Radius.elliptical(14, 9),
  topRight: Radius.elliptical(8, 16),
  bottomRight: Radius.elliptical(17, 8),
  bottomLeft: Radius.elliptical(9, 14),
);
