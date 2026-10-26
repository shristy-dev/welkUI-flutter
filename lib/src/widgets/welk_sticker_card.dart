import 'package:flutter/widgets.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_card.dart';
import 'welk_sticker.dart';

/// A responsive card with overhanging sticker art at the directional start.
class WelkStickerCard extends StatefulWidget {
  const WelkStickerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sticker,
    this.fallbackImage,
    this.icon,
    this.onPressed,
    this.enabled = true,
    this.growOnHover = true,
    this.outlineThickness = 6,
    this.outlineColor = const Color(0xFFFFFFFF),
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
  });

  final String title;
  final String subtitle;
  final ImageProvider sticker;
  final ImageProvider? fallbackImage;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool growOnHover;
  final double outlineThickness;
  final Color outlineColor;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  @override
  State<WelkStickerCard> createState() => _WelkStickerCardState();
}

class _WelkStickerCardState extends State<WelkStickerCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => WelkTheme.scope(
    context,
    overRideDarkMode: widget.overRideDarkMode,
    child: MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale:
            _hover &&
                widget.growOnHover &&
                widget.enabled &&
                !welkAnimationsDisabled(context)
            ? 1.03
            : 1,
        duration: welkAnimationsDisabled(context)
            ? Duration.zero
            : const Duration(milliseconds: 120),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 400;
            final stacked =
                constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.5;
            final artWidth = compact ? 128.0 : 176.0;
            final art = ExcludeSemantics(
              child: IgnorePointer(
                child: Opacity(
                  opacity: widget.enabled ? 1 : .55,
                  child: WelkSticker(
                    image: widget.sticker,
                    fallbackImage: widget.fallbackImage,
                    alt: '',
                    width: artWidth,
                    height: artWidth,
                    outlineThickness: widget.outlineThickness,
                    outlineColor: widget.outlineColor,
                    overRideDarkMode: widget.overRideDarkMode,
                  ),
                ),
              ),
            );
            final card = WelkCard(
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              onPressed: widget.onPressed,
              enabled: widget.enabled,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              overRideDarkMode: widget.overRideDarkMode,
            );
            if (stacked) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: art,
                    ),
                    Opacity(
                      opacity: !widget.enabled && widget.onPressed == null
                          ? .55
                          : 1,
                      child: card,
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: compact ? 32 : 48,
                    ),
                    child: _StickerCardSurface(
                      widget: widget,
                      leading: compact ? 96 : 128,
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: -28,
                    bottom: -28,
                    width: artWidth,
                    child: Center(child: art),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _StickerCardSurface extends StatefulWidget {
  const _StickerCardSurface({required this.widget, required this.leading});
  final WelkStickerCard widget;
  final double leading;

  @override
  State<_StickerCardSurface> createState() => _StickerCardSurfaceState();
}

class _StickerCardSurfaceState extends State<_StickerCardSurface> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.widget;
    final theme = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: card.overRideDarkMode);
    final enabled = card.enabled && card.onPressed != null;
    final shape = WelkShapeBorder(
      radii: welkCardRadii,
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
    );
    final surface = Opacity(
      opacity: card.enabled ? 1 : .55,
      child: WelkFocusRing(
        gap: 4,
        visible: _focus && enabled,
        color: theme.focus,
        shape: shape,
        child: CustomPaint(
          painter: WelkHardShadowPainter(
            shape: shape,
            color: theme.shadow,
            offset: theme.cardShadowOffset,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 112),
            padding: EdgeInsetsDirectional.fromSTEB(
              widget.leading,
              22,
              widget.leading <= 96 ? 40 : 64,
              22,
            ),
            decoration: ShapeDecoration(color: theme.paper, shape: shape),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: theme.fontFamily,
                package: theme.fontPackage,
                color: theme.ink,
                height: 1.5,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.subtitle,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                  if (card.icon != null)
                    PositionedDirectional(
                      end: -32,
                      top: 0,
                      width: 24,
                      height: 24,
                      child: ExcludeSemantics(
                        child: theme.isDark
                            ? IconTheme.merge(
                                data: IconThemeData(color: theme.ink),
                                child: card.icon!,
                              )
                            : card.icon!,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (card.onPressed == null) return surface;
    return FocusableActionDetector(
      enabled: enabled,
      focusNode: card.focusNode,
      autofocus: card.autofocus,
      onShowFocusHighlight: (value) => setState(() => _focus = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (enabled) card.onPressed!();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? card.onPressed : null,
          child: surface,
        ),
      ),
    );
  }
}
