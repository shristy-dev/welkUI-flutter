import 'package:flutter/widgets.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkBadgeVariant { defaultStyle, info, success, warning, error }

enum WelkBadgeSize { small, medium, large }

/// A tilted, hard-shadowed label. Content wraps within the available width.
class WelkBadge extends StatelessWidget {
  const WelkBadge({
    super.key,
    required this.child,
    this.variant = WelkBadgeVariant.defaultStyle,
    this.size = WelkBadgeSize.medium,
    this.semanticLabel,
  });

  final Widget child;
  final WelkBadgeVariant variant;
  final WelkBadgeSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final dimensions = switch (size) {
      WelkBadgeSize.small => (6.4, 1.6, 10.4),
      WelkBadgeSize.medium => (8.8, 3.2, 12.8),
      WelkBadgeSize.large => (12.0, 4.8, 16.0),
    };
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(9, 6),
        topRight: Radius.elliptical(5, 10),
        bottomRight: Radius.elliptical(11, 5),
        bottomLeft: Radius.elliptical(6, 9),
      ),
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Transform.rotate(
        angle: -0.0349066,
        child: CustomPaint(
          painter: WelkHardShadowPainter(
            shape: shape,
            color: theme.ink,
            offset: const Offset(2, 2),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: dimensions.$1 + theme.borderWidth,
              vertical: dimensions.$2 + theme.borderWidth,
            ),
            decoration: ShapeDecoration(
              color: switch (variant) {
                WelkBadgeVariant.defaultStyle => theme.accent,
                WelkBadgeVariant.info => theme.info,
                WelkBadgeVariant.success => theme.success,
                WelkBadgeVariant.warning => theme.warning,
                WelkBadgeVariant.error => theme.error,
              },
              shape: shape,
            ),
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                package: theme.fontPackage,
                fontSize: dimensions.$3,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: theme.ink,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
