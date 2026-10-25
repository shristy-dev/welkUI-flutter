import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/welk_theme.dart';

enum WelkDividerVariant { plain, dotted, dashed }

/// A plain, dotted or dashed separator; vertical separators default to 32 high.
class WelkDivider extends StatelessWidget {
  const WelkDivider({
    super.key,
    this.orientation = Axis.horizontal,
    this.variant = WelkDividerVariant.plain,
    this.thickness = 2,
    this.length,
    this.color,
    this.semanticLabel,
  }) : assert(thickness > 0 && thickness < double.infinity),
       assert(length == null || (length >= 0 && length < double.infinity));

  final Axis orientation;
  final WelkDividerVariant variant;
  final double thickness;
  final double? length;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel ?? 'Separator',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = orientation == Axis.horizontal;
        final extent =
            length ??
            (horizontal && constraints.hasBoundedWidth
                ? constraints.maxWidth
                : 32);
        return SizedBox(
          width: horizontal ? extent : thickness,
          height: horizontal ? thickness : extent,
          child: CustomPaint(
            painter: _DividerPainter(
              orientation,
              variant,
              thickness,
              color ?? WelkTheme.of(context).ink,
            ),
          ),
        );
      },
    ),
  );
}

class _DividerPainter extends CustomPainter {
  const _DividerPainter(this.axis, this.variant, this.thickness, this.color);

  final Axis axis;
  final WelkDividerVariant variant;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final horizontal = axis == Axis.horizontal;
    final length = horizontal ? size.width : size.height;
    final paint = Paint()..color = color;
    if (variant == WelkDividerVariant.plain) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }
    final dash = variant == WelkDividerVariant.dotted
        ? thickness
        : thickness * 3;
    for (double start = 0; start < length; start += dash + thickness * 2) {
      final end = math.min(start + dash, length);
      if (variant == WelkDividerVariant.dotted) {
        canvas.drawCircle(
          horizontal
              ? Offset(start + (end - start) / 2, size.height / 2)
              : Offset(size.width / 2, start + (end - start) / 2),
          (end - start) / 2,
          paint,
        );
      } else {
        canvas.drawRect(
          horizontal
              ? Rect.fromLTWH(start, 0, end - start, size.height)
              : Rect.fromLTWH(0, start, size.width, end - start),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DividerPainter oldDelegate) =>
      axis != oldDelegate.axis ||
      variant != oldDelegate.variant ||
      thickness != oldDelegate.thickness ||
      color != oldDelegate.color;
}
