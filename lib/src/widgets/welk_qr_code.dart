import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkQRCodeVariant { standard, card }

/// A real, locally encoded QR code with a four-module quiet zone.
///
/// Accepts HTTP(S) URLs, as in the React reference. Invalid or oversized data
/// produces a visible validation message rather than an unscannable pattern.
class WelkQRCode extends StatefulWidget {
  const WelkQRCode({
    super.key,
    required this.url,
    this.variant = WelkQRCodeVariant.standard,
    this.title,
    this.subtitle,
    this.cardColor,
    this.originalCode = false,
    this.size = 192,
  }) : assert(size > 0 && size < double.infinity);

  final String url;
  final WelkQRCodeVariant variant;
  final String? title;
  final String? subtitle;
  final Color? cardColor;
  final bool originalCode;
  final double size;

  @override
  State<WelkQRCode> createState() => _WelkQRCodeState();
}

class _WelkQRCodeState extends State<WelkQRCode> {
  QrImage? _code;
  String? _error;

  @override
  void initState() {
    super.initState();
    _encode();
  }

  @override
  void didUpdateWidget(WelkQRCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _encode();
  }

  void _encode() {
    _code = null;
    _error = null;
    final uri = Uri.tryParse(widget.url);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      _error = 'Enter a valid URL beginning with http:// or https://.';
      return;
    }
    try {
      _code = QrImage(QrCode(payload: QrPayload.fromString(widget.url)));
    } on InputTooLongException {
      _error = 'This URL is too long for a QR code.';
    }
  }

  Widget _frame(
    BuildContext context, {
    required Widget child,
    required EdgeInsets padding,
    required WelkCornerRadii radii,
    Color? color,
  }) {
    final theme = WelkTheme.of(context);
    final shape = WelkShapeBorder(
      radii: radii,
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return CustomPaint(
      painter: WelkHardShadowPainter(
        shape: shape,
        color: theme.ink,
        offset: theme.cardShadowOffset,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: color ?? theme.paper, shape: shape),
        child: Padding(
          padding: padding + EdgeInsets.all(theme.borderWidth),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final card = widget.variant == WelkQRCodeVariant.card;
    final code = _code;
    final body = code == null
        ? Semantics(
            liveRegion: true,
            child: _frame(
              context,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              radii: const WelkCornerRadii(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(7),
                bottomRight: Radius.circular(3),
                bottomLeft: Radius.circular(6),
              ),
              child: Text(_error!),
            ),
          )
        : Transform.rotate(
            angle: -math.pi / 180,
            child: _frame(
              context,
              padding: const EdgeInsets.all(8),
              radii: const WelkCornerRadii(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(3),
                bottomRight: Radius.circular(6),
                bottomLeft: Radius.circular(4),
              ),
              child: Semantics(
                image: true,
                label: 'QR code for ${widget.url}',
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: _QRCodePainter(code, widget.originalCode),
                  ),
                ),
              ),
            ),
          );
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: theme.fontFamily,
        package: theme.fontPackage,
        color: theme.ink,
        fontSize: 14.4,
        height: 1.4,
      ),
      child: SizedBox(
        width: widget.size + 16 + theme.borderWidth * 2 + (card ? 36 : 0),
        child: card
            ? Transform.rotate(
                angle: -math.pi / 180,
                child: _frame(
                  context,
                  padding: const EdgeInsets.all(16),
                  color: widget.cardColor,
                  radii: const WelkCornerRadii(
                    topLeft: Radius.elliptical(12, 8),
                    topRight: Radius.elliptical(7, 14),
                    bottomRight: Radius.elliptical(15, 7),
                    bottomLeft: Radius.elliptical(9, 12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null) ...[
                        Text(
                          widget.title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.subtitle != null) ...[
                        Text(widget.subtitle!, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                      ],
                      body,
                    ],
                  ),
                ),
              )
            : body,
      ),
    );
  }
}

class _QRCodePainter extends CustomPainter {
  const _QRCodePainter(this.code, this.original);

  final QrImage code;
  final bool original;

  @override
  void paint(Canvas canvas, Size size) {
    // Keep finder/timing patterns square and a four-module white quiet zone.
    final module = size.shortestSide / (code.moduleCount + 8);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final paint = Paint()..color = const Color(0xFF242424);
    final path = Path();
    for (var row = 0; row < code.moduleCount; row++) {
      for (var col = 0; col < code.moduleCount; col++) {
        if (!code.isDark(row, col)) continue;
        final rect = Rect.fromLTWH(
          (col + 4) * module,
          (row + 4) * module,
          module,
          module,
        );
        final finder =
            (row < 8 && col < 8) ||
            (row < 8 && col >= code.moduleCount - 8) ||
            (row >= code.moduleCount - 8 && col < 8);
        if (original || finder || row == 6 || col == 6) {
          path.addRect(rect);
        } else {
          path.addRRect(
            RRect.fromRectAndRadius(
              rect.deflate(module * 0.045),
              Radius.circular(module * 0.22),
            ),
          );
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_QRCodePainter oldDelegate) =>
      oldDelegate.code != code || oldDelegate.original != original;
}
