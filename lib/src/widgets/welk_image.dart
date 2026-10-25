import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// An image framed with WelkUI's asymmetric outline and solid shadow.
///
/// Network failures use [fallbackAsset], or a randomly chosen bundled comic
/// image. That selection remains stable until the source or fallback changes.
///
/// Defaults to a 4:3 frame when dimensions are not both supplied. Asset paths
/// belong to the consuming app unless [package] or [fallbackPackage] is set.
/// Fallback asset errors are surfaced rather than recursively replaced.
/// Android apps using network images need the INTERNET manifest permission.
class WelkImage extends StatefulWidget {
  const WelkImage.network(
    this.source, {
    super.key,
    this.fallbackAsset,
    this.fallbackPackage,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }) : _network = true,
       package = null;

  const WelkImage.asset(
    this.source, {
    super.key,
    this.package,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }) : _network = false,
       fallbackAsset = null,
       fallbackPackage = null;

  final String source;
  final String? package;

  /// A consumer asset path used instead of the bundled comic fallback.
  final String? fallbackAsset;
  final String? fallbackPackage;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool _network;

  @override
  State<WelkImage> createState() => _WelkImageState();
}

class _WelkImageState extends State<WelkImage> {
  static final _random = math.Random();
  AssetImage? _fallback;

  @override
  void didUpdateWidget(WelkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source != oldWidget.source ||
        widget._network != oldWidget._network ||
        widget.package != oldWidget.package ||
        widget.fallbackAsset != oldWidget.fallbackAsset ||
        widget.fallbackPackage != oldWidget.fallbackPackage) {
      _fallback = null;
    }
  }

  Widget _buildImage(
    ImageProvider provider, {
    ImageErrorWidgetBuilder? onError,
  }) => Image(
    image: provider,
    fit: widget.fit,
    alignment: widget.alignment,
    width: double.infinity,
    height: double.infinity,
    excludeFromSemantics: true,
    errorBuilder: onError,
  );

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final shape = WelkShapeBorder(
      radii: welkCardRadii,
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    final image = widget._network
        ? _buildImage(
            NetworkImage(widget.source),
            onError: (context, error, stackTrace) {
              _fallback ??= widget.fallbackAsset != null
                  ? AssetImage(
                      widget.fallbackAsset!,
                      package: widget.fallbackPackage,
                    )
                  : AssetImage(
                      'assets/fallbacks/comic_bg_0${_random.nextInt(5) + 1}.jpg',
                      package: 'welkui_flutter',
                    );
              // Fallback asset errors are deliberately surfaced by Image.
              return _buildImage(_fallback!);
            },
          )
        : _buildImage(AssetImage(widget.source, package: widget.package));

    return Semantics(
      image: !widget.excludeFromSemantics,
      label: widget.excludeFromSemantics ? null : widget.semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: CustomPaint(
            painter: WelkHardShadowPainter(
              shape: shape,
              color: theme.ink,
              offset: theme.cardShadowOffset,
            ),
            child: DecoratedBox(
              decoration: ShapeDecoration(shape: shape),
              position: DecorationPosition.foreground,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: shape),
                child: ColoredBox(color: theme.paper, child: image),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
