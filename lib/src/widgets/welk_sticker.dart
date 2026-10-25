import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/welk_theme.dart';

/// An alpha-contoured sticker with a real dilated outline, not a rectangular
/// image border. A failed primary image is retried once with [fallbackImage].
class WelkSticker extends StatefulWidget {
  const WelkSticker({
    super.key,
    required this.image,
    required this.alt,
    this.fallbackImage,
    this.width = 160,
    this.height = 160,
    this.outlineThickness = 6,
    this.outlineColor = const Color(0xFFFFFFFF),
    this.elevateOnHover = false,
    this.onLoad,
    this.onError,
  }) : assert(outlineThickness >= 0 && outlineThickness < double.infinity),
       assert(width > 0 && width < double.infinity),
       assert(height > 0 && height < double.infinity);

  final ImageProvider image;
  final String alt;
  final ImageProvider? fallbackImage;
  final double width;
  final double height;
  final double outlineThickness;
  final Color outlineColor;
  final bool elevateOnHover;
  final VoidCallback? onLoad;
  final ValueChanged<Object>? onError;

  @override
  State<WelkSticker> createState() => _WelkStickerState();
}

class _WelkStickerState extends State<WelkSticker> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageInfo? _info;
  bool _fallback = false;
  bool _failed = false;
  bool _hovered = false;
  int _request = 0;
  int _subscription = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(WelkSticker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image ||
        widget.fallbackImage != oldWidget.fallbackImage) {
      // A fallback update must not discard an already loaded primary image.
      if (widget.image == oldWidget.image && !_fallback && _info != null) {
        return;
      }
      _request++;
      _detach();
      _fallback = false;
      _failed = false;
      _info?.dispose();
      _info = null;
      _resolve();
    }
  }

  void _resolve() {
    final provider = _fallback ? widget.fallbackImage! : widget.image;
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _detach();
    final subscription = _subscription;
    final request = _request;
    _stream = stream;
    _listener = ImageStreamListener(
      (info, synchronousCall) {
        if (!mounted || subscription != _subscription) {
          info.dispose();
          return;
        }
        setState(() {
          _info?.dispose();
          _info = info;
          _failed = false;
        });
        _notify(request, () => widget.onLoad?.call());
      },
      onError: (Object error, StackTrace? stack) {
        if (!mounted || subscription != _subscription) return;
        _notify(request, () => widget.onError?.call(error));
        if (!_fallback &&
            widget.fallbackImage != null &&
            widget.fallbackImage != widget.image) {
          _fallback = true;
          _resolve();
        } else {
          setState(() => _failed = true);
        }
      },
    );
    stream.addListener(_listener!);
  }

  void _notify(int request, VoidCallback callback) {
    // Cached streams can notify synchronously while ancestors are building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && request == _request) callback();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _detach() {
    _subscription++;
    if (_listener != null) _stream?.removeListener(_listener!);
    _listener = null;
    _stream = null;
  }

  @override
  void dispose() {
    _detach();
    _info?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final reduced = welkAnimationsDisabled(context);
    final padding = widget.outlineThickness + 4;
    return Semantics(
      image: !_failed,
      label: widget.alt,
      liveRegion: _failed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(
            0,
            _hovered && widget.elevateOnHover && !reduced ? -6 : 0,
            0,
          ),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_info != null),
            tween: Tween(
              begin: reduced ? 1 : 0,
              end: reduced || _info != null ? 1 : 0,
            ),
            duration: reduced
                ? Duration.zero
                : const Duration(milliseconds: 650),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Opacity(
              opacity: _failed ? 1 : value.clamp(0, 1),
              child: Transform.translate(
                offset: _failed
                    ? Offset.zero
                    : Offset((1 - value) * 12, (1 - value) * -24),
                child: Transform.rotate(
                  angle: (_failed ? -4 : -16 + 12 * value) * math.pi / 180,
                  child: Transform.scale(
                    scale: _failed ? 1 : 1.18 - .18 * value,
                    child: child,
                  ),
                ),
              ),
            ),
            child: _failed
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.paper,
                      border: Border.all(
                        color: theme.ink,
                        width: theme.borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unable to load sticker',
                      style: TextStyle(
                        color: theme.ink,
                        fontFamily: theme.fontFamily,
                        package: theme.fontPackage,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.width + padding * 2,
                      maxHeight: widget.height + padding * 2,
                    ),
                    child: AspectRatio(
                      aspectRatio:
                          (widget.width + padding * 2) /
                          (widget.height + padding * 2),
                      child: CustomPaint(
                        painter: _StickerPainter(
                          _info?.image,
                          widget.outlineThickness,
                          widget.outlineColor,
                          padding,
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

class _StickerPainter extends CustomPainter {
  const _StickerPainter(this.image, this.thickness, this.color, this.padding);
  final ui.Image? image;
  final double thickness;
  final Color color;
  final double padding;

  void _draw(Canvas canvas, Rect rect) {
    paintImage(
      canvas: canvas,
      rect: rect,
      image: image!,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    final rect = (Offset.zero & size).deflate(
      math.min(padding, math.min(size.width, size.height) / 2),
    );
    if (rect.isEmpty) return;
    final layer = (Offset.zero & size).inflate(thickness + 8);
    canvas.save();
    canvas.translate(2, 3);
    canvas.saveLayer(
      layer,
      Paint()
        ..colorFilter = const ColorFilter.mode(
          Color(0x66242424),
          BlendMode.srcIn,
        )
        ..imageFilter = ui.ImageFilter.compose(
          outer: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          inner: ui.ImageFilter.dilate(radiusX: thickness, radiusY: thickness),
        ),
    );
    _draw(canvas, rect);
    canvas.restore();
    canvas.restore();
    if (thickness > 0) {
      canvas.saveLayer(
        layer,
        Paint()
          ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn)
          ..imageFilter = ui.ImageFilter.dilate(
            radiusX: thickness,
            radiusY: thickness,
          ),
      );
      _draw(canvas, rect);
      canvas.restore();
    }
    _draw(canvas, rect);
  }

  @override
  bool shouldRepaint(_StickerPainter oldDelegate) =>
      image != oldDelegate.image ||
      thickness != oldDelegate.thickness ||
      color != oldDelegate.color ||
      padding != oldDelegate.padding;
}
