import 'package:flutter/widgets.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkAvatarVariant { user, maleUser, femaleUser, maleAdmin, femaleAdmin }

enum WelkAvatarSize { small, medium, large }

/// A circular portrait, custom image or icon with an ink outline and hard shadow.
class WelkAvatar extends StatefulWidget {
  const WelkAvatar({
    super.key,
    required this.alt,
    this.image,
    this.icon,
    this.variant = WelkAvatarVariant.user,
    this.size = WelkAvatarSize.medium,
    this.color,
    this.growOnHover = false,
  });

  final String alt;
  final ImageProvider? image;
  final Widget? icon;
  final WelkAvatarVariant variant;
  final WelkAvatarSize size;
  final Color? color;
  final bool growOnHover;

  @override
  State<WelkAvatar> createState() => _WelkAvatarState();
}

class _WelkAvatarState extends State<WelkAvatar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final extent = switch (widget.size) {
      WelkAvatarSize.small => 32.0,
      WelkAvatarSize.medium => 48.0,
      WelkAvatarSize.large => 64.0,
    };
    final shape = CircleBorder(
      side: BorderSide(color: theme.ink, width: theme.borderWidth),
    );
    final portrait = Padding(
      padding: EdgeInsets.all(extent * .12),
      child: Image.asset(
        'assets/portraits/${switch (widget.variant) {
          WelkAvatarVariant.user || WelkAvatarVariant.maleUser => 'male_user',
          WelkAvatarVariant.femaleUser => 'female_user',
          WelkAvatarVariant.maleAdmin => 'male_admin',
          WelkAvatarVariant.femaleAdmin => 'female_admin',
        }}.png',
        package: 'welkui_flutter',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => CustomPaint(
          painter: _PortraitPainter(
            theme.ink,
            widget.variant == WelkAvatarVariant.femaleUser ||
                widget.variant == WelkAvatarVariant.femaleAdmin,
            widget.variant == WelkAvatarVariant.maleAdmin ||
                widget.variant == WelkAvatarVariant.femaleAdmin,
          ),
        ),
      ),
    );
    return Semantics(
      image: true,
      label: widget.alt,
      child: ExcludeSemantics(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            scale:
                widget.growOnHover &&
                    _hovered &&
                    !welkAnimationsDisabled(context)
                ? 1.1
                : 1,
            duration: welkAnimationsDisabled(context)
                ? Duration.zero
                : const Duration(milliseconds: 120),
            child: CustomPaint(
              painter: WelkHardShadowPainter(
                shape: shape,
                color: theme.ink,
                offset: theme.buttonShadowOffset,
              ),
              child: Container(
                width: extent,
                height: extent,
                decoration: ShapeDecoration(
                  shape: shape,
                  color: widget.color ?? theme.paper,
                ),
                child: Padding(
                  padding: EdgeInsets.all(theme.borderWidth),
                  child: ClipOval(
                    child: widget.image != null
                        ? Image(
                            image: widget.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => portrait,
                          )
                        : widget.icon != null
                        ? Center(
                            child: SizedBox.square(
                              dimension: extent * .65,
                              child: FittedBox(child: widget.icon!),
                            ),
                          )
                        : portrait,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter(this.ink, this.female, this.admin);
  final Color ink;
  final bool female;
  final bool admin;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ink;
    final w = size.width;
    final h = size.height;
    if (female) {
      canvas.drawOval(Rect.fromLTWH(w * .23, h * .02, w * .54, h * .65), paint);
      paint.color = const Color(0xFFFFD1AA);
    }
    canvas.drawOval(Rect.fromLTWH(w * .32, h * .1, w * .36, h * .4), paint);
    paint.color = ink;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .16, h * .57, w * .68, h * .4),
        Radius.circular(w * .2),
      ),
      paint,
    );
    if (admin) {
      paint.color = const Color(0xFFFFDA57);
      canvas.drawCircle(Offset(w * .65, h * .77), w * .09, paint);
    }
  }

  @override
  bool shouldRepaint(_PortraitPainter oldDelegate) =>
      ink != oldDelegate.ink ||
      female != oldDelegate.female ||
      admin != oldDelegate.admin;
}
