import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// Visual layouts available for [WelkBottomNavBar] and [WelkBottomNavScaffold].
enum WelkBottomNavLayout {
  /// The middle destination is an enlarged circle that pops above the bar.
  popCircle,

  /// The middle destination is a larger square block built into the bar.
  blockCenter,

  /// The middle destination is a larger square that protrudes above the bar.
  popBlock,

  /// Rounded, bold-bordered dock with raised comic tiles for the active item.
  comicDock,

  /// Pill-shaped rail with a bubble indicator that glides between items.
  bubbleRail,
}

/// Where the navigation bar is placed.
enum WelkBottomNavMode {
  /// Anchored to the bottom edge, extending into the bottom safe area.
  defaultMode,

  /// Floats above the bottom edge with margins, elevation, and rounded corners.
  floating,
}

/// How [WelkBottomNavScaffold] shows and hides the bar.
enum WelkBottomNavVisibility {
  /// Visible while scrolling. Still honors `hideOnSubpages`.
  sticky,

  /// Hides when scrolling down and reveals when scrolling up.
  /// Still honors `hideOnSubpages`.
  hideOnScrollDown,

  /// Never hides: ignores scrolling, subpages, and the on-screen keyboard.
  alwaysVisible,
}

/// When item labels are displayed.
enum WelkBottomNavLabelBehavior { alwaysShow, selectedOnly, hidden }

/// Transition used by [WelkBottomNavScaffold] when switching destinations.
enum WelkBottomNavTransition {
  none,
  fade,
  fadeThrough,
  slideUp,
  slideHorizontal,
}

/// A single bottom navigation destination.
@immutable
class WelkBottomNavItem {
  const WelkBottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.builder,
    this.onGenerateRoute,
    this.semanticLabel,
    this.badge,
  });

  final Widget icon;

  /// Icon shown while selected. Defaults to [icon].
  final Widget? activeIcon;
  final String label;

  /// Builds the destination's root page. Required by [WelkBottomNavScaffold].
  final WidgetBuilder? builder;

  /// Resolves named routes pushed on this destination's nested navigator.
  final RouteFactory? onGenerateRoute;
  final String? semanticLabel;

  /// Optional small widget (for example a count) drawn over the icon corner.
  final Widget? badge;
}

/// Visual configuration shared by [WelkBottomNavBar] and
/// [WelkBottomNavScaffold]. Null colors resolve from [WelkTheme] for light and
/// dark modes.
@immutable
class WelkBottomNavStyle {
  const WelkBottomNavStyle({
    this.backgroundColor,
    this.selectedItemColor,
    this.selectedForegroundColor,
    this.unselectedForegroundColor,
    this.featuredItemColor,
    this.borderColor,
    this.borderWidth,
    this.shadowColor,
    this.shadowOffset,
    this.elevation,
    this.height = 64,
    this.width,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
    this.borderRadius,
    this.iconSize = 24,
    this.activeItemSize = 60,
    this.labelStyle,
    this.selectedLabelStyle,
    this.labelBehavior = WelkBottomNavLabelBehavior.alwaysShow,
    this.animationDuration = const Duration(milliseconds: 320),
    this.animationCurve = Curves.easeOutBack,
  }) : assert(height >= 48),
       assert(activeItemSize >= 40),
       assert(iconSize > 0);

  /// Bar surface color. Defaults to the theme paper.
  final Color? backgroundColor;

  /// Fill for active indicators. Defaults to the theme accent.
  final Color? selectedItemColor;

  /// Icon and label color drawn on [selectedItemColor].
  final Color? selectedForegroundColor;
  final Color? unselectedForegroundColor;

  /// Fill of the enlarged middle destination while it is not selected.
  final Color? featuredItemColor;
  final Color? borderColor;

  /// Outline width. Defaults to the theme border width (+1 for comicDock).
  final double? borderWidth;

  /// Hard (unblurred) comic shadow color.
  final Color? shadowColor;

  /// Hard shadow offset for floating bars and active indicators.
  final Offset? shadowOffset;

  /// Soft shadow depth. Defaults to 3 when floating and 0 otherwise.
  final double? elevation;

  /// Height of the bar surface, excluding safe area and pop-out items.
  final double height;

  /// Maximum width of the bar surface. Null fills the available width.
  final double? width;

  /// Outer spacing of the bar in floating mode.
  final EdgeInsetsGeometry margin;

  /// Inner spacing around the items.
  final EdgeInsetsGeometry padding;

  /// Uniform corner radius. Null uses the layout's hand-drawn default.
  /// In default mode only the top corners are rounded.
  final double? borderRadius;
  final double iconSize;

  /// Size of the enlarged middle destination for popCircle, blockCenter and
  /// popBlock.
  final double activeItemSize;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;
  final WelkBottomNavLabelBehavior labelBehavior;
  final Duration animationDuration;
  final Curve animationCurve;

  WelkBottomNavStyle copyWith({
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? selectedForegroundColor,
    Color? unselectedForegroundColor,
    Color? featuredItemColor,
    Color? borderColor,
    double? borderWidth,
    Color? shadowColor,
    Offset? shadowOffset,
    double? elevation,
    double? height,
    double? width,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? iconSize,
    double? activeItemSize,
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
    WelkBottomNavLabelBehavior? labelBehavior,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return WelkBottomNavStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      unselectedForegroundColor:
          unselectedForegroundColor ?? this.unselectedForegroundColor,
      featuredItemColor: featuredItemColor ?? this.featuredItemColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      elevation: elevation ?? this.elevation,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      iconSize: iconSize ?? this.iconSize,
      activeItemSize: activeItemSize ?? this.activeItemSize,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      labelBehavior: labelBehavior ?? this.labelBehavior,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}

/// Geometry shared by the bar and the scaffold that hosts it.
@immutable
class _NavMetrics {
  const _NavMetrics({
    required this.margin,
    required this.surfaceHeight,
    required this.bottomGap,
    required this.protrusion,
    required this.featuredIndex,
  });

  factory _NavMetrics.resolve(
    BuildContext context,
    WelkBottomNavLayout layout,
    WelkBottomNavMode mode,
    WelkBottomNavStyle style,
    int count,
  ) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final floating = mode == WelkBottomNavMode.floating;
    final margin = floating
        ? style.margin.resolve(Directionality.maybeOf(context))
        : EdgeInsets.zero;
    final featuredIndex =
        count.isOdd &&
            (layout == WelkBottomNavLayout.popCircle ||
                layout == WelkBottomNavLayout.blockCenter ||
                layout == WelkBottomNavLayout.popBlock)
        ? count ~/ 2
        : null;
    final protrusion = featuredIndex == null
        ? 0.0
        : switch (layout) {
            WelkBottomNavLayout.popCircle => style.activeItemSize * .42,
            WelkBottomNavLayout.popBlock => style.activeItemSize * .38,
            _ => 0.0,
          };
    return _NavMetrics(
      margin: margin,
      surfaceHeight: style.height + (floating ? 0 : safeBottom),
      bottomGap: floating ? margin.bottom + safeBottom : 0,
      protrusion: protrusion,
      featuredIndex: featuredIndex,
    );
  }

  final EdgeInsets margin;
  final double surfaceHeight;
  final double bottomGap;
  final double protrusion;
  final int? featuredIndex;

  /// Space reserved at the bottom of the screen, excluding pop-out items.
  double get extent => margin.top + surfaceHeight + bottomGap;

  /// Full painted height, including pop-out items above the surface.
  double get totalHeight => extent + math.max(0, protrusion - margin.top);
}

/// Colors and strokes resolved from [WelkTheme] and [WelkBottomNavStyle].
class _NavPalette {
  _NavPalette(
    WelkColors colors,
    this.style,
    this.layout,
    WelkBottomNavMode mode,
  ) : floating = mode == WelkBottomNavMode.floating,
      background = style.backgroundColor ?? colors.paper,
      selected = style.selectedItemColor ?? colors.accent,
      featured = style.featuredItemColor ?? colors.muted,
      hover = colors.muted,
      border = style.borderColor ?? colors.outline,
      shadow = style.shadowColor ?? colors.shadow,
      focus = colors.focus,
      ink = colors.ink,
      fontFamily = colors.fontFamily,
      fontPackage = colors.fontPackage,
      borderWidth =
          style.borderWidth ??
          (layout == WelkBottomNavLayout.comicDock
              ? colors.borderWidth + 1
              : colors.borderWidth),
      hardShadow =
          style.shadowOffset ??
          (layout == WelkBottomNavLayout.comicDock
              ? const Offset(4, 4)
              : colors.cardShadowOffset),
      elevation =
          style.elevation ?? (mode == WelkBottomNavMode.floating ? 3 : 0) {
    selectedForeground =
        style.selectedForegroundColor ?? colors.onFill(selected);
    unselectedForeground =
        style.unselectedForegroundColor ?? ink.withValues(alpha: .72);
    featuredForeground = colors.onFill(featured);
  }

  final WelkBottomNavStyle style;
  final WelkBottomNavLayout layout;
  final bool floating;
  final Color background;
  final Color selected;
  final Color featured;
  final Color hover;
  final Color border;
  final Color shadow;
  final Color focus;
  final Color ink;
  final String fontFamily;
  final String? fontPackage;
  final double borderWidth;
  final Offset hardShadow;
  final double elevation;
  late final Color selectedForeground;
  late final Color unselectedForeground;
  late final Color featuredForeground;

  BorderSide get side => BorderSide(color: border, width: borderWidth);

  BoxShadow hardBoxShadow([double scale = 1]) =>
      BoxShadow(color: shadow, offset: hardShadow * scale, blurRadius: 0);

  TextStyle labelStyle(bool isSelected, Color color) => TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 12,
    height: 1.2,
    color: color,
    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
  ).merge(style.labelStyle).merge(isSelected ? style.selectedLabelStyle : null);

  WelkCornerRadii surfaceRadii(double height) {
    WelkCornerRadii radii;
    final custom = style.borderRadius;
    if (custom != null) {
      final r = Radius.circular(math.min(custom, height / 2));
      radii = WelkCornerRadii(
        topLeft: r,
        topRight: r,
        bottomRight: r,
        bottomLeft: r,
      );
    } else {
      radii = switch (layout) {
        WelkBottomNavLayout.bubbleRail => WelkCornerRadii(
          topLeft: Radius.circular(height / 2),
          topRight: Radius.circular(height / 2),
          bottomRight: Radius.circular(height / 2),
          bottomLeft: Radius.circular(height / 2),
        ),
        WelkBottomNavLayout.comicDock => const WelkCornerRadii(
          topLeft: Radius.elliptical(26, 18),
          topRight: Radius.elliptical(18, 28),
          bottomRight: Radius.elliptical(28, 18),
          bottomLeft: Radius.elliptical(18, 26),
        ),
        _ => welkCardRadii,
      };
    }
    if (floating) return radii;
    return WelkCornerRadii(
      topLeft: radii.topLeft,
      topRight: radii.topRight,
      bottomRight: Radius.zero,
      bottomLeft: Radius.zero,
    );
  }
}

const _smallRadius = BorderRadius.only(
  topLeft: Radius.elliptical(12, 8),
  topRight: Radius.elliptical(7, 12),
  bottomRight: Radius.elliptical(13, 7),
  bottomLeft: Radius.elliptical(8, 11),
);

const _blockRadius = BorderRadius.only(
  topLeft: Radius.elliptical(18, 12),
  topRight: Radius.elliptical(10, 18),
  bottomRight: Radius.elliptical(20, 10),
  bottomLeft: Radius.elliptical(11, 16),
);

/// A comic-styled bottom navigation bar for up to five destinations.
///
/// This is the stateless bar. Use [WelkBottomNavScaffold] for built-in page
/// management, per-destination navigators, and visibility behaviors. When
/// placed in [Scaffold.bottomNavigationBar] with a pop-out layout, set
/// [Scaffold.extendBody] so the pop-out area does not shorten the body.
class WelkBottomNavBar extends StatelessWidget {
  const WelkBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.layout = WelkBottomNavLayout.popCircle,
    this.mode = WelkBottomNavMode.defaultMode,
    this.style = const WelkBottomNavStyle(),
    this.semanticLabel = 'Bottom navigation',
    this.enableHapticFeedback = true,
    this.overRideDarkMode,
  }) : assert(items.length >= 2 && items.length <= 5),
       assert(currentIndex >= 0 && currentIndex < items.length);

  /// Two to five destinations. For popCircle, blockCenter and popBlock an
  /// odd count (3 or 5) features the middle destination; even counts render
  /// every destination at the regular size.
  final List<WelkBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final WelkBottomNavLayout layout;
  final WelkBottomNavMode mode;
  final WelkBottomNavStyle style;
  final String semanticLabel;
  final bool enableHapticFeedback;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  /// Height reserved at the bottom of the screen (excluding pop-out items).
  static double layoutExtent(
    BuildContext context, {
    required int itemCount,
    WelkBottomNavLayout layout = WelkBottomNavLayout.popCircle,
    WelkBottomNavMode mode = WelkBottomNavMode.defaultMode,
    WelkBottomNavStyle style = const WelkBottomNavStyle(),
  }) => _NavMetrics.resolve(context, layout, mode, style, itemCount).extent;

  @override
  Widget build(BuildContext context) {
    final colors = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: overRideDarkMode);
    final palette = _NavPalette(colors, style, layout, mode);
    final metrics = _NavMetrics.resolve(
      context,
      layout,
      mode,
      style,
      items.length,
    );
    final duration = welkAnimationsDisabled(context)
        ? Duration.zero
        : style.animationDuration;
    final padding = style.padding.resolve(Directionality.of(context));
    final protrusion = metrics.protrusion;
    final rowHeight = protrusion + style.height;

    void handleTap(int index) {
      if (enableHapticFeedback) HapticFeedback.selectionClick();
      onTap?.call(index);
    }

    final row = LayoutBuilder(
      builder: (context, constraints) {
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final children = <Widget>[];
        for (var i = 0; i < items.length; i++) {
          final item = _NavItem(
            // Decorations can't be lerped across layouts (circle vs. block).
            key: ValueKey((layout, i == metrics.featuredIndex)),
            item: items[i],
            index: i,
            count: items.length,
            selected: i == currentIndex,
            featured: i == metrics.featuredIndex,
            palette: palette,
            duration: duration,
            onTap: () => handleTap(i),
          );
          if (i == metrics.featuredIndex) {
            final width = layout == WelkBottomNavLayout.blockCenter
                ? style.activeItemSize
                : style.activeItemSize + 12;
            children.add(
              SizedBox(width: width, height: rowHeight, child: item),
            );
          } else {
            children.add(
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: protrusion + padding.top,
                    bottom: padding.bottom,
                  ),
                  child: item,
                ),
              ),
            );
          }
        }
        final itemRow = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
        if (layout != WelkBottomNavLayout.bubbleRail) return itemRow;
        final itemWidth = constraints.maxWidth / items.length;
        final visual = rtl ? items.length - 1 - currentIndex : currentIndex;
        final bubbleHeight = (style.height - padding.vertical - 12).clamp(
          32.0,
          48.0,
        );
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: duration,
              curve: style.animationCurve,
              left: visual * itemWidth + 2,
              width: math.max(0, itemWidth - 4),
              top:
                  padding.top +
                  (style.height - padding.vertical) / 2 -
                  bubbleHeight / 2,
              height: bubbleHeight,
              child: _Bubble(
                key: ValueKey(currentIndex),
                palette: palette,
                duration: duration,
              ),
            ),
            Positioned.fill(child: itemRow),
          ],
        );
      },
    );

    final bar = SizedBox(
      height: metrics.totalHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          metrics.margin.left,
          0,
          metrics.margin.right,
          metrics.bottomGap,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: style.width ?? double.infinity,
            ),
            child: SizedBox(
              width: double.infinity,
              height: protrusion + metrics.surfaceHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: metrics.surfaceHeight,
                    child: CustomPaint(
                      painter: _SurfacePainter(
                        color: palette.background,
                        borderColor: palette.border,
                        borderWidth: palette.borderWidth,
                        radii: palette.surfaceRadii(style.height),
                        anchored: !palette.floating,
                        hardShadow: palette.floating
                            ? palette.hardShadow
                            : null,
                        shadowColor: palette.shadow,
                        elevation: palette.elevation,
                      ),
                    ),
                  ),
                  Positioned(
                    left: padding.left,
                    right: padding.right,
                    top: 0,
                    height: rowHeight,
                    child: row,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return WelkTheme.scope(
      context,
      overRideDarkMode: overRideDarkMode,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: bar,
        ),
      ),
    );
  }
}

class _SurfacePainter extends CustomPainter {
  const _SurfacePainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.radii,
    required this.anchored,
    required this.hardShadow,
    required this.shadowColor,
    required this.elevation,
  });

  final Color color;
  final Color borderColor;
  final double borderWidth;
  final WelkCornerRadii radii;
  final bool anchored;
  final Offset? hardShadow;
  final Color shadowColor;
  final double elevation;

  @override
  void paint(Canvas canvas, Size size) {
    // Anchored bars push side and bottom strokes off-screen, keeping the top.
    final rect = anchored
        ? Rect.fromLTRB(
            -borderWidth,
            0,
            size.width + borderWidth,
            size.height + borderWidth,
          )
        : Offset.zero & size;
    final shape = WelkShapeBorder(
      radii: radii,
      strokeColor: borderColor,
      strokeWidth: borderWidth,
    );
    final path = shape.getOuterPath(rect);
    if (elevation > 0) {
      canvas.drawShadow(path, const Color(0x66000000), elevation, false);
    }
    final shadow = hardShadow;
    if (shadow != null && shadow != Offset.zero) {
      canvas.drawPath(path.shift(shadow), Paint()..color = shadowColor);
    }
    canvas.drawPath(path, Paint()..color = color);
    shape.paint(canvas, rect);
  }

  @override
  bool shouldRepaint(_SurfacePainter old) =>
      color != old.color ||
      borderColor != old.borderColor ||
      borderWidth != old.borderWidth ||
      radii != old.radii ||
      anchored != old.anchored ||
      hardShadow != old.hardShadow ||
      shadowColor != old.shadowColor ||
      elevation != old.elevation;
}

/// The bubbleRail indicator with two decorative bubbles that pop in.
class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.palette, required this.duration});

  final _NavPalette palette;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    Widget dot(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.selected,
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.border,
          width: palette.borderWidth * .75,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.selected,
                borderRadius: BorderRadius.circular(constraints.maxHeight / 2),
                border: Border.fromBorderSide(palette.side),
                boxShadow: [palette.hardBoxShadow(.7)],
              ),
            ),
          ),
          Positioned(
            top: -7,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: duration * 1.4,
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: IgnorePointer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [dot(9), const SizedBox(width: 1), dot(6)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Short comic "action lines" that burst from the active comicDock tile.
class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.color, this.strokeWidth);

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final origin = Offset(0, size.height);
    for (final angle in [-0.25, -0.75, -1.25]) {
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        origin + direction * size.width * .35,
        origin + direction * size.width,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      color != old.color || strokeWidth != old.strokeWidth;
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    super.key,
    required this.item,
    required this.index,
    required this.count,
    required this.selected,
    required this.featured,
    required this.palette,
    required this.duration,
    required this.onTap,
  });

  final WelkBottomNavItem item;
  final int index;
  final int count;
  final bool selected;
  final bool featured;
  final _NavPalette palette;
  final Duration duration;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;
  bool _focus = false;
  bool _pressed = false;

  _NavPalette get p => widget.palette;
  WelkBottomNavStyle get s => widget.palette.style;
  bool get _selected => widget.selected;

  Curve get _curve => s.animationCurve;

  bool get _showLabel => switch (s.labelBehavior) {
    WelkBottomNavLabelBehavior.alwaysShow => true,
    WelkBottomNavLabelBehavior.selectedOnly => _selected,
    WelkBottomNavLabelBehavior.hidden => false,
  };

  Widget _icon(Color color, double size) {
    final item = widget.item;
    final icon = _selected ? (item.activeIcon ?? item.icon) : item.icon;
    Widget result = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: widget.duration,
      builder: (context, value, child) => IconTheme.merge(
        data: IconThemeData(color: value, size: size),
        child: child!,
      ),
      child: AnimatedSwitcher(
        duration: widget.duration,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: KeyedSubtree(key: ValueKey(_selected), child: icon),
      ),
    );
    if (item.badge != null) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          PositionedDirectional(top: -6, end: -10, child: item.badge!),
        ],
      );
    }
    return result;
  }

  Widget _label(Color color) {
    final style = p.labelStyle(_selected, color);
    return AnimatedSize(
      duration: widget.duration,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _showLabel
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AnimatedDefaultTextStyle(
                duration: widget.duration,
                style: style,
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : const SizedBox(height: 0),
    );
  }

  Widget _fit(Widget child) => Center(
    child: FittedBox(fit: BoxFit.scaleDown, child: child),
  );

  Widget _regular() {
    final icon = s.iconSize;
    final idle = _hover ? p.hover : p.background.withValues(alpha: 0);
    final idleBorder = p.border.withValues(alpha: 0);
    switch (p.layout) {
      case WelkBottomNavLayout.bubbleRail:
        final color = _selected ? p.selectedForeground : p.unselectedForeground;
        return _fit(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _selected ? 1.12 : 1,
                duration: widget.duration,
                curve: _curve,
                child: _icon(color, icon),
              ),
              _label(color),
            ],
          ),
        );
      case WelkBottomNavLayout.comicDock:
        final color = _selected ? p.selectedForeground : p.unselectedForeground;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
          child: AnimatedSlide(
            offset: _selected ? const Offset(0, -.06) : Offset.zero,
            duration: widget.duration,
            curve: _curve,
            child: AnimatedRotation(
              turns: _selected ? -.012 : 0,
              duration: widget.duration,
              curve: _curve,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: widget.duration,
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: _selected ? p.selected : idle,
                        borderRadius: _smallRadius,
                        border: Border.all(
                          color: _selected ? p.border : idleBorder,
                          width: p.borderWidth,
                        ),
                        boxShadow: _selected
                            ? [p.hardBoxShadow(.75)]
                            : [
                                BoxShadow(
                                  color: p.shadow.withValues(alpha: 0),
                                  blurRadius: 0,
                                ),
                              ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: _fit(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [_icon(color, icon), _label(color)],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: -10,
                    end: -8,
                    child: IgnorePointer(
                      child: AnimatedScale(
                        scale: _selected ? 1 : 0,
                        duration: widget.duration,
                        curve: _curve,
                        child: Transform.flip(
                          flipX:
                              Directionality.of(context) == TextDirection.rtl,
                          child: CustomPaint(
                            size: const Size(14, 14),
                            painter: _BurstPainter(p.ink, 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case WelkBottomNavLayout.popCircle:
      case WelkBottomNavLayout.blockCenter:
      case WelkBottomNavLayout.popBlock:
        final circle = p.layout == WelkBottomNavLayout.popCircle;
        final iconColor = _selected
            ? p.selectedForeground
            : p.unselectedForeground;
        final labelColor = _selected ? p.ink : p.unselectedForeground;
        return _fit(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: widget.duration,
                curve: Curves.easeOut,
                width: circle ? icon + 14 : icon + 24,
                height: icon + (circle ? 14 : 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selected ? p.selected : idle,
                  shape: circle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: circle ? null : _smallRadius,
                  border: Border.all(
                    color: _selected ? p.border : idleBorder,
                    width: p.borderWidth,
                  ),
                ),
                child: AnimatedScale(
                  scale: _selected ? 1.08 : 1,
                  duration: widget.duration,
                  curve: _curve,
                  child: _icon(iconColor, icon),
                ),
              ),
              _label(labelColor),
            ],
          ),
        );
    }
  }

  Widget _featured() {
    final size = s.activeItemSize;
    final fill = _selected ? p.selected : (_hover ? p.hover : p.featured);
    final fg = _selected ? p.selectedForeground : p.featuredForeground;
    final labelColor = _selected ? p.ink : p.unselectedForeground;
    final icon = _icon(fg, s.iconSize * 1.3);
    if (p.layout == WelkBottomNavLayout.blockCenter) {
      return AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: p.borderWidth,
          bottom: p.floating ? p.borderWidth : 0,
        ),
        decoration: BoxDecoration(
          color: fill,
          border: Border(left: p.side, right: p.side),
        ),
        child: _fit(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _selected ? 1.12 : 1,
                duration: widget.duration,
                curve: _curve,
                child: icon,
              ),
              _label(_selected ? p.selectedForeground : p.featuredForeground),
            ],
          ),
        ),
      );
    }
    final circle = p.layout == WelkBottomNavLayout.popCircle;
    final button = AnimatedSlide(
      offset: _selected ? const Offset(0, -.07) : Offset.zero,
      duration: widget.duration,
      curve: _curve,
      child: AnimatedRotation(
        turns: !circle && _selected ? -.015 : 0,
        duration: widget.duration,
        curve: _curve,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOut,
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle ? null : _blockRadius,
            border: Border.fromBorderSide(p.side),
            boxShadow: [p.hardBoxShadow(_selected ? 1 : .5)],
          ),
          child: AnimatedScale(
            scale: _selected ? 1.1 : 1,
            duration: widget.duration,
            curve: _curve,
            child: icon,
          ),
        ),
      ),
    );
    return Column(
      children: [
        button,
        Expanded(
          child: Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: _label(labelColor)),
          ),
        ),
      ],
    );
  }

  void _activate() => widget.onTap();

  @override
  Widget build(BuildContext context) {
    final content = widget.featured ? _featured() : _regular();
    final focusShape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      strokeColor: p.focus,
    );
    return Semantics(
      button: true,
      selected: _selected,
      inMutuallyExclusiveGroup: true,
      label: widget.item.semanticLabel ?? widget.item.label,
      hint: 'Tab ${widget.index + 1} of ${widget.count}',
      excludeSemantics: true,
      onTap: _activate,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) => setState(() => _focus = value),
        onShowHoverHighlight: (value) => setState(() => _hover = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: widget.featured
              ? HitTestBehavior.deferToChild
              : HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: _activate,
          child: WelkFocusRing(
            gap: 1,
            visible: _focus,
            color: p.focus,
            shape: focusShape,
            child: AnimatedScale(
              scale: _pressed ? .92 : 1,
              duration: const Duration(milliseconds: 100),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabObserver extends NavigatorObserver {
  _TabObserver(this.onChanged);

  final VoidCallback onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      onChanged();
}

/// A full-screen shell that pairs [WelkBottomNavBar] with one stateful page
/// per destination.
///
/// Every destination gets its own nested [Navigator], so pushing a route with
/// `Navigator.of(context)` from inside a page opens a subpage within that
/// destination. Page state is preserved while switching destinations, and the
/// bar can hide on subpages, on scroll, or while the keyboard is open.
class WelkBottomNavScaffold extends StatefulWidget {
  const WelkBottomNavScaffold({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.onReselect,
    this.layout = WelkBottomNavLayout.popCircle,
    this.mode = WelkBottomNavMode.defaultMode,
    this.style = const WelkBottomNavStyle(),
    this.visibility = WelkBottomNavVisibility.sticky,
    this.hideOnSubpages = true,
    this.hideWhenKeyboardVisible = true,
    this.scrollSensitivity = 12,
    this.transition = WelkBottomNavTransition.fade,
    this.transitionDuration,
    this.transitionCurve = Curves.easeOutCubic,
    this.lazyLoad = true,
    this.keepPagesAlive = true,
    this.popToRootOnReselect = true,
    this.extendBody,
    this.backgroundColor,
    this.semanticLabel = 'Bottom navigation',
    this.enableHapticFeedback = true,
    this.overRideDarkMode,
  }) : assert(items.length >= 2 && items.length <= 5),
       assert(scrollSensitivity >= 0);

  /// Two to five destinations; each must provide [WelkBottomNavItem.builder].
  final List<WelkBottomNavItem> items;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  /// Called when the already selected destination is tapped again.
  final ValueChanged<int>? onReselect;
  final WelkBottomNavLayout layout;
  final WelkBottomNavMode mode;
  final WelkBottomNavStyle style;
  final WelkBottomNavVisibility visibility;

  /// Hides the bar while a destination shows a pushed subpage and shows it
  /// again on that destination's root page. Ignored by `alwaysVisible`.
  final bool hideOnSubpages;

  /// Hides the bar while the on-screen keyboard is open. Ignored by
  /// `alwaysVisible`.
  final bool hideWhenKeyboardVisible;

  /// Logical pixels scrolled in one direction before `hideOnScrollDown`
  /// hides or reveals the bar.
  final double scrollSensitivity;
  final WelkBottomNavTransition transition;

  /// Defaults to [WelkBottomNavStyle.animationDuration].
  final Duration? transitionDuration;
  final Curve transitionCurve;

  /// Builds destinations on first visit instead of all at once.
  final bool lazyLoad;

  /// Keeps visited destinations (and their state) alive offstage.
  final bool keepPagesAlive;

  /// Pops a destination back to its root page when it is tapped again.
  final bool popToRootOnReselect;

  /// Lets pages draw behind the bar. Defaults to true in floating mode. The
  /// covered height is added to the pages' bottom [MediaQuery] padding.
  final bool? extendBody;

  /// Defaults to the [ThemeData.scaffoldBackgroundColor].
  final Color? backgroundColor;
  final String semanticLabel;
  final bool enableHapticFeedback;

  /// Overrides [WelkThemeData.darkMode] for this widget and its pages.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  /// The closest scaffold state, for example to switch destinations from a
  /// page with `WelkBottomNavScaffold.of(context).select(2)`.
  static WelkBottomNavScaffoldState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No WelkBottomNavScaffold found in context.');
    return state!;
  }

  static WelkBottomNavScaffoldState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<WelkBottomNavScaffoldState>();

  @override
  State<WelkBottomNavScaffold> createState() => WelkBottomNavScaffoldState();
}

class WelkBottomNavScaffoldState extends State<WelkBottomNavScaffold>
    with TickerProviderStateMixin {
  late int _index;
  late int _previous;
  final Set<int> _built = {};
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];
  final List<_TabObserver> _observers = [];
  final List<HeroController> _heroControllers = [];
  late final AnimationController _barController;
  late final CurvedAnimation _barAnimation;
  late final AnimationController _pageController;
  late final CurvedAnimation _pageAnimation;
  bool _onSubpage = false;
  bool _scrollHidden = false;
  double _scrollDelta = 0;
  bool? _barTarget;
  bool _subpageCheckScheduled = false;

  /// The selected destination.
  int get currentIndex => _index;

  /// Whether the bar is shown or animating in.
  bool get isBarVisible => _barTarget ?? true;

  /// The nested navigator of a destination, once it has been built.
  NavigatorState? navigatorOf(int index) =>
      index >= 0 && index < _navigatorKeys.length
      ? _navigatorKeys[index].currentState
      : null;

  Duration get _pageDuration =>
      widget.transitionDuration ?? widget.style.animationDuration;

  @override
  void initState() {
    super.initState();
    assert(
      widget.items.every((item) => item.builder != null),
      'Every WelkBottomNavScaffold item needs a builder.',
    );
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    _previous = _index;
    _syncTabs();
    _built.add(_index);
    if (!widget.lazyLoad) {
      _built.addAll(List.generate(widget.items.length, (i) => i));
    }
    _barController = AnimationController(
      vsync: this,
      value: 1,
      duration: widget.style.animationDuration,
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _pageController = AnimationController(
      vsync: this,
      value: 1,
      duration: _pageDuration,
    );
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: widget.transitionCurve,
    );
  }

  void _syncTabs() {
    final count = widget.items.length;
    while (_navigatorKeys.length > count) {
      _navigatorKeys.removeLast();
      _observers.removeLast();
      _heroControllers.removeLast().dispose();
    }
    while (_navigatorKeys.length < count) {
      final tab = _navigatorKeys.length;
      _navigatorKeys.add(GlobalKey<NavigatorState>(debugLabel: 'Tab $tab'));
      _observers.add(_TabObserver(_scheduleSubpageCheck));
      _heroControllers.add(MaterialApp.createMaterialHeroController());
    }
  }

  @override
  void didUpdateWidget(WelkBottomNavScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTabs();
    final count = widget.items.length;
    _built.removeWhere((i) => i >= count);
    if (_index >= count) {
      _index = count - 1;
      _built.add(_index);
    }
    _previous = _previous.clamp(0, count - 1);
    if (!widget.lazyLoad) _built.addAll(List.generate(count, (i) => i));
    if (!widget.keepPagesAlive) _built.retainWhere((i) => i == _index);
    _barController.duration = widget.style.animationDuration;
    _pageController.duration = _pageDuration;
    _pageAnimation.curve = widget.transitionCurve;
    if (widget.visibility != WelkBottomNavVisibility.hideOnScrollDown) {
      _scrollHidden = false;
    }
  }

  @override
  void dispose() {
    _barAnimation.dispose();
    _barController.dispose();
    _pageAnimation.dispose();
    _pageController.dispose();
    for (final controller in _heroControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Selects a destination, exactly as if its bar item was tapped.
  void select(int index) {
    if (index < 0 || index >= widget.items.length) return;
    if (index == _index) {
      if (widget.popToRootOnReselect) popToRoot(index);
      widget.onReselect?.call(index);
      return;
    }
    setState(() {
      _previous = _index;
      _index = index;
      if (!widget.keepPagesAlive) _built.clear();
      _built.add(index);
      _scrollHidden = false;
      _scrollDelta = 0;
      _onSubpage = navigatorOf(index)?.canPop() ?? false;
    });
    if (widget.transition == WelkBottomNavTransition.none ||
        welkAnimationsDisabled(context)) {
      _pageController.value = 1;
    } else {
      _pageController.forward(from: 0);
    }
    widget.onIndexChanged?.call(index);
  }

  /// Pops a destination (the current one by default) back to its root page.
  void popToRoot([int? index]) =>
      navigatorOf(index ?? _index)?.popUntil((route) => route.isFirst);

  void _setStateSafely(VoidCallback fn) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(fn);
      });
    } else {
      setState(fn);
    }
  }

  void _scheduleSubpageCheck() {
    if (_subpageCheckScheduled) return;
    _subpageCheckScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _subpageCheckScheduled = false;
      if (!mounted) return;
      final onSubpage = navigatorOf(_index)?.canPop() ?? false;
      if (onSubpage != _onSubpage) {
        setState(() {
          _onSubpage = onSubpage;
          _scrollHidden = false;
          _scrollDelta = 0;
        });
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  bool _handleScroll(ScrollNotification notification) {
    if (widget.visibility != WelkBottomNavVisibility.hideOnScrollDown ||
        notification.metrics.axis != Axis.vertical ||
        notification is! ScrollUpdateNotification) {
      return false;
    }
    final metrics = notification.metrics;
    if (metrics.pixels <= metrics.minScrollExtent) {
      _scrollDelta = 0;
      if (_scrollHidden) _setStateSafely(() => _scrollHidden = false);
      return false;
    }
    final delta = notification.scrollDelta ?? 0;
    // Ignore overscroll bounces at the end of the content.
    if (delta == 0 || metrics.outOfRange) return false;
    if ((delta > 0) != (_scrollDelta > 0)) _scrollDelta = 0;
    _scrollDelta += delta;
    if (_scrollDelta.abs() >= widget.scrollSensitivity) {
      final hide = _scrollDelta > 0;
      _scrollDelta = 0;
      if (hide != _scrollHidden) _setStateSafely(() => _scrollHidden = hide);
    }
    return false;
  }

  bool _wantsBar(BuildContext context) {
    if (widget.visibility == WelkBottomNavVisibility.alwaysVisible) {
      return true;
    }
    if (widget.hideWhenKeyboardVisible &&
        MediaQuery.viewInsetsOf(context).bottom > 0) {
      return false;
    }
    if (widget.hideOnSubpages && _onSubpage) return false;
    if (widget.visibility == WelkBottomNavVisibility.hideOnScrollDown &&
        _scrollHidden) {
      return false;
    }
    return true;
  }

  void _syncBar(BuildContext context) {
    final wants = _wantsBar(context);
    if (wants == _barTarget) return;
    final initial = _barTarget == null;
    _barTarget = wants;
    final instant = initial || welkAnimationsDisabled(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _barTarget != wants) return;
      if (instant) {
        _barController.value = wants ? 1 : 0;
      } else if (wants) {
        _barController.forward();
      } else {
        _barController.reverse();
      }
    });
  }

  Widget _transition(bool active, Widget child) {
    final animate =
        active &&
        widget.transition != WelkBottomNavTransition.none &&
        !welkAnimationsDisabled(context);
    final Animation<double> motion = animate
        ? _pageAnimation
        : kAlwaysCompleteAnimation;
    final Animation<double> opacity = animate
        ? _pageController.drive(CurveTween(curve: Curves.easeOut))
        : kAlwaysCompleteAnimation;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final direction = (_index >= _previous ? 1.0 : -1.0) * (rtl ? -1 : 1);
    final (slide, scale) = switch (widget.transition) {
      WelkBottomNavTransition.none ||
      WelkBottomNavTransition.fade => (Offset.zero, 1.0),
      WelkBottomNavTransition.fadeThrough => (Offset.zero, .94),
      WelkBottomNavTransition.slideUp => (const Offset(0, .04), 1.0),
      WelkBottomNavTransition.slideHorizontal => (
        Offset(.08 * direction, 0),
        1.0,
      ),
    };
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: Tween(begin: slide, end: Offset.zero).animate(motion),
        child: ScaleTransition(
          scale: Tween(begin: scale, end: 1.0).animate(motion),
          child: child,
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final item = widget.items[index];
    final active = index == _index;
    final navigatorKey = _navigatorKeys[index];
    return KeyedSubtree(
      key: ValueKey<int>(index),
      child: Offstage(
        offstage: !active,
        child: TickerMode(
          enabled: active,
          child: ExcludeFocus(
            excluding: !active,
            child: _transition(
              active,
              NavigatorPopHandler<Object?>(
                enabled: active,
                onPopWithResult: (_) => navigatorKey.currentState?.maybePop(),
                child: HeroControllerScope(
                  controller: _heroControllers[index],
                  child: Navigator(
                    key: navigatorKey,
                    observers: [_observers[index]],
                    onGenerateRoute: (settings) {
                      if (settings.name == Navigator.defaultRouteName) {
                        return MaterialPageRoute<void>(
                          settings: settings,
                          builder: item.builder!,
                        );
                      }
                      return item.onGenerateRoute?.call(settings);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncBar(context);
    final mediaQuery = MediaQuery.of(context);
    final metrics = _NavMetrics.resolve(
      context,
      widget.layout,
      widget.mode,
      widget.style,
      widget.items.length,
    );
    final extendBody =
        widget.extendBody ?? widget.mode == WelkBottomNavMode.floating;
    final hiddenOffset = metrics.totalHeight + 16;
    final pages = NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            if (_built.contains(i)) _tab(i),
        ],
      ),
    );
    final bar = WelkBottomNavBar(
      items: widget.items,
      currentIndex: _index,
      onTap: select,
      layout: widget.layout,
      mode: widget.mode,
      style: widget.style,
      semanticLabel: widget.semanticLabel,
      enableHapticFeedback: widget.enableHapticFeedback,
      overRideDarkMode: widget.overRideDarkMode,
    );
    final shell = AnimatedBuilder(
      animation: _barAnimation,
      child: pages,
      builder: (context, child) {
        final visible = _barAnimation.value.clamp(0.0, 1.0);
        final bodyInset = extendBody ? 0.0 : metrics.extent * visible;
        final overlap = extendBody ? metrics.extent * visible : 0.0;
        double bottom(double original) =>
            math.max(math.max(0.0, original - bodyInset), overlap);
        final data = mediaQuery.copyWith(
          padding: mediaQuery.padding.copyWith(
            bottom: bottom(mediaQuery.padding.bottom),
          ),
          viewPadding: mediaQuery.viewPadding.copyWith(
            bottom: bottom(mediaQuery.viewPadding.bottom),
          ),
          viewInsets: mediaQuery.viewInsets.copyWith(
            bottom: math.max(0.0, mediaQuery.viewInsets.bottom - bodyInset),
          ),
        );
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: bodyInset,
              child: MediaQuery(data: data, child: child!),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !isBarVisible,
                child: ExcludeSemantics(
                  excluding: visible == 0,
                  child: Transform.translate(
                    offset: Offset(0, (1 - visible) * hiddenOffset),
                    child: bar,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: widget.overRideDarkMode,
      child: Material(
        color:
            widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        child: shell,
      ),
    );
  }
}
