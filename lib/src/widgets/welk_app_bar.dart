import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// Distinct silhouettes and title treatments for [WelkAppBar].
enum WelkAppBarLayout { comicStrip, sticker, bubble, split }

/// Logo placement. Left follows the leading edge in right-to-left locales.
enum WelkAppBarLogoPosition { left, center }

/// A comic-inspired toolbar for [Scaffold.appBar] or inline previews.
///
/// Supply either [title] or [titleWidget]. [floating] controls the card-like
/// appearance, not scroll behavior. Use [WelkSliverAppBar] in a
/// [CustomScrollView] to choose pinned or scroll-away behavior.
class WelkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WelkAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.logo,
    this.logoPosition = WelkAppBarLogoPosition.left,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions = const [],
    this.layout = WelkAppBarLayout.comicStrip,
    this.floating = false,
    this.centerTitle = false,
    this.primary = true,
    this.height = 72,
    this.margin = const EdgeInsets.fromLTRB(12, 8, 12, 8),
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.backgroundColor,
    this.foregroundColor,
    this.accentColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadowColor,
    this.shadowOffset,
    this.titleStyle,
    this.logoSize = 36,
    this.overRideDarkMode,
  }) : assert(title == null || titleWidget == null),
       assert(height >= 56),
       assert(logoSize > 0),
       assert(borderWidth == null || borderWidth >= 0),
       assert(borderRadius == null || borderRadius >= 0);

  final String? title;
  final Widget? titleWidget;
  final Widget? logo;
  final WelkAppBarLogoPosition logoPosition;
  final Widget? leading;

  /// Adds a back button for a poppable route, or a drawer button when present.
  final bool automaticallyImplyLeading;

  /// Up to three widgets at the trailing edge (right in left-to-right locales).
  final List<Widget> actions;
  final WelkAppBarLayout layout;

  /// Draws a detached card with [margin], rounded corners and a hard shadow.
  final bool floating;
  final bool centerTitle;

  /// Includes the status-bar safe area. Set false for inline previews.
  final bool primary;

  /// Toolbar height, excluding status-bar padding and floating margins.
  final double height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? accentColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Color? shadowColor;
  final Offset? shadowOffset;
  final TextStyle? titleStyle;
  final double logoSize;
  final bool? overRideDarkMode;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (floating ? margin.vertical : 0));

  @override
  Widget build(BuildContext context) {
    assert(actions.length <= 3, 'WelkAppBar supports at most three actions.');
    assert(margin.isNonNegative);
    assert(padding.isNonNegative);
    final colors = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: overRideDarkMode);
    final background = backgroundColor ?? colors.paper;
    final foreground = foregroundColor ?? colors.ink;
    final accent = accentColor ?? colors.accent;
    final outline = borderColor ?? colors.outline;
    final stroke = borderWidth ?? colors.borderWidth;
    final radius = borderRadius;
    final radii = radius != null
        ? WelkCornerRadii(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          )
        : switch (layout) {
            WelkAppBarLayout.bubble => WelkCornerRadii(
              topLeft: Radius.circular(height / 2),
              topRight: Radius.circular(height / 2),
              bottomRight: Radius.circular(height / 2),
              bottomLeft: Radius.circular(height / 2),
            ),
            WelkAppBarLayout.sticker => welkButtonRadii,
            _ => welkCardRadii,
          };
    final shape = WelkShapeBorder(
      radii: floating
          ? radii
          : const WelkCornerRadii(
              topLeft: Radius.zero,
              topRight: Radius.zero,
              bottomRight: Radius.zero,
              bottomLeft: Radius.zero,
            ),
      strokeColor: outline,
      strokeWidth: stroke,
    );
    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && automaticallyImplyLeading) {
      if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
        resolvedLeading = const DrawerButton();
      } else if (ModalRoute.of(context)?.canPop ?? false) {
        resolvedLeading = const BackButton();
      }
    }

    final titleContent = Semantics(
      header: true,
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: colors.fontFamily,
          package: colors.fontPackage,
          color:
              foregroundColor ??
              (layout == WelkAppBarLayout.sticker ||
                      layout == WelkAppBarLayout.bubble
                  ? colors.onFill(accent)
                  : foreground),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ).merge(titleStyle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: titleWidget ?? Text(title ?? ''),
      ),
    );
    final titleBadge = switch (layout) {
      WelkAppBarLayout.sticker => Transform.rotate(
        angle: -.025,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: ShapeDecoration(
            color: accent,
            shape: WelkShapeBorder(
              radii: welkButtonRadii,
              strokeColor: outline,
              strokeWidth: stroke,
            ),
            shadows: [
              BoxShadow(
                color: shadowColor ?? colors.shadow,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: titleContent,
        ),
      ),
      WelkAppBarLayout.bubble => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: outline, width: stroke),
        ),
        child: titleContent,
      ),
      _ => titleContent,
    };
    final logoWidget = logo == null
        ? null
        : SizedBox.square(
            dimension: logoSize,
            child: FittedBox(fit: BoxFit.contain, child: logo),
          );
    final centeredLogo = logoPosition == WelkAppBarLogoPosition.center;
    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logoWidget != null) ...[
          Flexible(child: logoWidget),
          if (title != null || titleWidget != null) const SizedBox(width: 8),
        ],
        if (title != null || titleWidget != null) Flexible(child: titleBadge),
      ],
    );
    final toolbar = LayoutBuilder(
      builder: (context, constraints) {
        // Keep branding centered on the bar, not just between unequal slots.
        // On narrow screens the title yields space before action targets do.
        final available = math.max(0.0, constraints.maxWidth);
        final leadingWidth = resolvedLeading == null ? 0.0 : 48.0;
        final actionsWidth = actions.length * 48.0;
        final wantsCenter = centerTitle || (logoWidget != null && centeredLogo);
        final center =
            wantsCenter &&
            available - 2 * math.max(leadingWidth, actionsWidth) >=
                logoSize + 32;
        final reserved = center
            ? math.max(leadingWidth, actionsWidth)
            : leadingWidth;
        return Stack(
          alignment: Alignment.center,
          children: [
            PositionedDirectional(
              start: reserved,
              end: center ? reserved : actionsWidth,
              top: 0,
              bottom: 0,
              child: ClipRect(
                child: Align(
                  alignment: center
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.max(
                        0,
                        available -
                            reserved -
                            (center ? reserved : actionsWidth),
                      ),
                    ),
                    child: brand,
                  ),
                ),
              ),
            ),
            if (resolvedLeading != null)
              PositionedDirectional(
                start: 0,
                child: SizedBox(width: 48, height: 48, child: resolvedLeading),
              ),
            PositionedDirectional(
              end: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final action in actions)
                    SizedBox(width: 48, height: 48, child: action),
                ],
              ),
            ),
          ],
        );
      },
    );
    final surface = CustomPaint(
      painter: floating
          ? WelkHardShadowPainter(
              shape: shape,
              color: shadowColor ?? colors.shadow,
              offset: shadowOffset ?? colors.cardShadowOffset,
            )
          : null,
      child: Container(
        height: height,
        decoration: ShapeDecoration(color: background, shape: shape),
        foregroundDecoration: ShapeDecoration(shape: shape),
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: shape),
          child: Stack(
            children: [
              if (layout == WelkAppBarLayout.split)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: 64,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent,
                      border: BorderDirectional(
                        end: BorderSide(color: outline, width: stroke),
                      ),
                    ),
                  ),
                ),
              if (layout == WelkAppBarLayout.comicStrip)
                Positioned(
                  left: stroke,
                  right: stroke,
                  bottom: stroke,
                  height: 5,
                  child: ColoredBox(color: accent),
                ),
              Positioned.fill(
                child: Padding(
                  padding: padding.add(EdgeInsets.all(stroke)),
                  child: IconTheme.merge(
                    data: IconThemeData(color: foreground, size: 24),
                    child: toolbar,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: overRideDarkMode,
      child: SafeArea(
        top: primary,
        bottom: false,
        child: Padding(
          padding: floating ? margin : EdgeInsets.zero,
          child: surface,
        ),
      ),
    );
  }
}

/// Places a [WelkAppBar] in a [CustomScrollView].
///
/// [pinned] keeps it visible while scrolling. When false it scrolls offscreen.
/// The app bar's `floating` property independently controls its card appearance.
class WelkSliverAppBar extends StatelessWidget {
  const WelkSliverAppBar({super.key, required this.appBar, this.pinned = true});

  final WelkAppBar appBar;
  final bool pinned;

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
    pinned: pinned,
    delegate: _AppBarDelegate(
      appBar,
      appBar.preferredSize.height +
          (appBar.primary ? MediaQuery.paddingOf(context).top : 0),
    ),
  );
}

class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  _AppBarDelegate(this.appBar, this.height);

  final WelkAppBar appBar;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => appBar;

  @override
  bool shouldRebuild(_AppBarDelegate oldDelegate) =>
      oldDelegate.appBar != appBar || oldDelegate.height != height;
}
