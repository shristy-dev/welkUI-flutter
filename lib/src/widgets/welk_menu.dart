import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// Whether menu items navigate directly or expose expandable child menus.
enum WelkMenuVariant { standard, nested }

/// A navigation destination. Use a unique [route] for each item in a menu.
@immutable
class WelkMenuItem {
  const WelkMenuItem({
    required this.title,
    required this.route,
    this.children = const [],
  });

  final String title;
  final String route;
  final List<WelkMenuItem> children;
}

/// An inline navigation menu. The parent handles navigation via [onSelected].
///
/// [activeRoute] controls the highlighted destination; expanding a branch does
/// not select it. A nested branch includes a separate "Go to" destination.
class WelkMenu extends StatefulWidget {
  const WelkMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.variant = WelkMenuVariant.standard,
    this.activeRoute,
    this.collapsible = false,
    this.semanticLabel = 'Main navigation',
  });

  final List<WelkMenuItem> items;

  /// Called once with the selected route. Null disables destination actions.
  final ValueChanged<String>? onSelected;
  final WelkMenuVariant variant;
  final String? activeRoute;
  final bool collapsible;
  final String semanticLabel;

  @override
  State<WelkMenu> createState() => _WelkMenuState();
}

class _WelkMenuState extends State<WelkMenu> {
  final Set<String> _open = {};
  final Map<String, FocusNode> _branchFocus = {};
  final FocusNode _toggleFocus = FocusNode();
  bool _expanded = true;

  void _closeBranches() {
    if (_open.isNotEmpty) setState(_open.clear);
  }

  void _select(String route) {
    _closeBranches();
    widget.onSelected?.call(route);
  }

  Iterable<String> _descendantRoutes(WelkMenuItem item) sync* {
    for (final child in item.children) {
      yield child.route;
      yield* _descendantRoutes(child);
    }
  }

  void _toggleBranch(WelkMenuItem item) {
    setState(() {
      if (!_open.add(item.route)) {
        _open.remove(item.route);
        _open.removeAll(_descendantRoutes(item));
      }
    });
  }

  void _dismiss() {
    if (_open.isNotEmpty) {
      final route = _open.last;
      setState(() => _open.remove(route));
      _branchFocus[route]?.requestFocus();
    } else if (widget.collapsible && _expanded) {
      setState(() => _expanded = false);
      _toggleFocus.requestFocus();
    }
  }

  @override
  void didUpdateWidget(WelkMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final routes = <String>{};
    void collect(List<WelkMenuItem> items) {
      for (final item in items) {
        routes.add(item.route);
        collect(item.children);
      }
    }

    collect(widget.items);
    _open.removeWhere((route) => !routes.contains(route));
    for (final route in _branchFocus.keys.toList()) {
      if (!routes.contains(route)) _branchFocus.remove(route)!.dispose();
    }
    if (widget.variant != WelkMenuVariant.nested) _open.clear();
  }

  @override
  void dispose() {
    _toggleFocus.dispose();
    for (final node in _branchFocus.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final visible = !widget.collapsible || _expanded;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: TapRegion(
        onTapOutside: (_) => _closeBranches(),
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) {
            if (!focused) _closeBranches();
          },
          child: Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
            },
            child: Actions(
              actions: {
                DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (_) {
                    _dismiss();
                    return null;
                  },
                ),
              },
              child: SizedBox(
                width: 288,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: theme.ink,
                    fontFamily: theme.fontFamily,
                    package: theme.fontPackage,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.collapsible) ...[
                        _buildToggle(theme, visible),
                        const SizedBox(height: 8),
                      ],
                      _MenuReveal(
                        visible: visible,
                        duration: visible
                            ? const Duration(milliseconds: 320)
                            : const Duration(milliseconds: 280),
                        child: _buildItems(widget.items, theme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(WelkThemeData theme, bool expanded) {
    final shape = _shape(theme, 8, 5, 10, 6);
    return _MenuAction(
      label: expanded ? 'Collapse menu' : 'Expand menu',
      expanded: expanded,
      focusNode: _toggleFocus,
      onPressed: () {
        setState(() {
          _expanded = !_expanded;
          _open.clear();
        });
      },
      toggleShape: shape,
      child: CustomPaint(
        painter: WelkHardShadowPainter(
          shape: shape,
          color: theme.ink,
          offset: theme.buttonShadowOffset,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: ShapeDecoration(color: theme.accent, shape: shape),
          alignment: Alignment.center,
          child: welkAnimationsDisabled(context)
              ? _MenuGlyph(
                  kind: expanded ? _GlyphKind.close : _GlyphKind.menu,
                  color: theme.ink,
                  size: 21,
                )
              : AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: const Cubic(0.2, 1.4, 0.4, 1),
                  child: _MenuGlyph(
                    kind: expanded ? _GlyphKind.close : _GlyphKind.menu,
                    color: theme.ink,
                    size: 21,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildItems(
    List<WelkMenuItem> items,
    WelkThemeData theme, {
    int depth = 0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0)
            SizedBox(
              height: theme.borderWidth,
              child: ColoredBox(color: theme.ink),
            ),
          _buildItem(items[index], theme, depth),
        ],
      ],
    );
  }

  Widget _buildItem(WelkMenuItem item, WelkThemeData theme, int depth) {
    final branch =
        widget.variant == WelkMenuVariant.nested && item.children.isNotEmpty;
    if (!branch) return _destination(item.title, item.route);
    final open = _open.contains(item.route);
    final shape = _shape(theme, 12, 7, 15, 9);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuAction(
          label: item.title,
          expanded: open,
          focusNode: _branchFocus.putIfAbsent(item.route, FocusNode.new),
          onPressed: () => _toggleBranch(item),
          child: _row(item.title, theme, down: true),
        ),
        _MenuReveal(
          visible: open,
          duration: const Duration(milliseconds: 180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 4, depth == 0 ? 3 : 0, 4),
            child: CustomPaint(
              painter: depth == 0
                  ? WelkHardShadowPainter(
                      shape: shape,
                      color: theme.ink,
                      offset: theme.cardShadowOffset,
                    )
                  : null,
              child: Container(
                padding: EdgeInsets.all(5.6 + theme.borderWidth),
                decoration: ShapeDecoration(color: theme.paper, shape: shape),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _destination('Go to ${item.title}', item.route),
                    SizedBox(
                      height: theme.borderWidth,
                      child: ColoredBox(color: theme.ink),
                    ),
                    _buildItems(item.children, theme, depth: depth + 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _destination(String title, String route) => _MenuAction(
    label: title,
    selected: widget.activeRoute == route,
    onPressed: widget.onSelected == null ? null : () => _select(route),
    child: _row(title, WelkTheme.of(context)),
  );

  Widget _row(String title, WelkThemeData theme, {bool down = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          const SizedBox(width: 10.4),
          Transform.rotate(
            angle: -3 * math.pi / 180,
            child: _MenuGlyph(
              kind: down ? _GlyphKind.down : _GlyphKind.arrow,
              color: theme.ink,
              rtl: Directionality.of(context) == TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  WelkShapeBorder _shape(
    WelkThemeData theme,
    double tl,
    double tr,
    double br,
    double bl,
  ) => WelkShapeBorder(
    radii: WelkCornerRadii(
      topLeft: Radius.circular(tl),
      topRight: Radius.circular(tr),
      bottomRight: Radius.circular(br),
      bottomLeft: Radius.circular(bl),
    ),
    strokeColor: theme.ink,
    strokeWidth: theme.borderWidth,
  );
}

class _MenuReveal extends StatelessWidget {
  const _MenuReveal({
    required this.visible,
    required this.duration,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (welkAnimationsDisabled(context)) {
      return visible ? child : const SizedBox(width: double.infinity);
    }
    return ExcludeFocus(
      excluding: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: visible ? 1 : 0, end: visible ? 1 : 0),
            duration: duration,
            curve: Curves.ease,
            builder: (context, progress, child) => ClipRect(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                heightFactor: progress,
                child: Offstage(
                  offstage: progress == 0,
                  child: Opacity(
                    opacity: progress,
                    child: Transform(
                      alignment: AlignmentDirectional.topStart,
                      transform: Matrix4.identity()
                        ..translateByDouble(0, -6 * (1 - progress), 0, 1)
                        ..rotateZ(-2 * math.pi / 180 * (1 - progress))
                        ..scaleByDouble(
                          0.96 + 0.04 * progress,
                          0.9 + 0.1 * progress,
                          1,
                          1,
                        ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MenuAction extends StatefulWidget {
  const _MenuAction({
    required this.label,
    required this.onPressed,
    required this.child,
    this.selected = false,
    this.expanded,
    this.focusNode,
    this.toggleShape,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  final bool selected;
  final bool? expanded;
  final FocusNode? focusNode;
  final ShapeBorder? toggleShape;

  @override
  State<_MenuAction> createState() => _MenuActionState();
}

class _MenuActionState extends State<_MenuAction> {
  bool _focusVisible = false;
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final enabled = widget.onPressed != null;
    final toggle = widget.toggleShape != null;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(7),
      topRight: const Radius.circular(4),
      bottomRight: const Radius.circular(9),
      bottomLeft: const Radius.circular(5),
    );
    final content = toggle
        ? WelkFocusRing(
            visible: _focusVisible && enabled,
            color: theme.focus,
            shape: widget.toggleShape!,
            gap: 3,
            child: widget.child,
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: widget.selected || (_hovered && enabled)
                  ? theme.accent
                  : Colors.transparent,
              borderRadius: radius,
            ),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: _focusVisible && enabled
                    ? Border.all(color: theme.focus, width: 3)
                    : null,
              ),
              child: widget.child,
            ),
          );
    return FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      includeFocusSemantics: false,
      onFocusChange: (value) => setState(() => _focused = value),
      onShowFocusHighlight: (value) => setState(() => _focusVisible = value),
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: Semantics(
        container: true,
        excludeSemantics: true,
        label: widget.label,
        button: true,
        enabled: enabled,
        focusable: enabled,
        focused: enabled && _focused,
        selected: toggle || widget.expanded != null ? null : widget.selected,
        expanded: widget.expanded,
        onTap: widget.onPressed,
        child: GestureDetector(
          excludeFromSemantics: true,
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: toggle
                ? Center(widthFactor: 1, heightFactor: 1, child: content)
                : content,
          ),
        ),
      ),
    );
  }
}

enum _GlyphKind { arrow, down, menu, close }

class _MenuGlyph extends StatelessWidget {
  const _MenuGlyph({
    required this.kind,
    required this.color,
    this.rtl = false,
    this.size = 17.6,
  });

  final _GlyphKind kind;
  final Color color;
  final bool rtl;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _MenuGlyphPainter(kind: kind, color: color, rtl: rtl),
    ),
  );
}

class _MenuGlyphPainter extends CustomPainter {
  const _MenuGlyphPainter({
    required this.kind,
    required this.color,
    required this.rtl,
  });

  final _GlyphKind kind;
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    if (rtl && kind == _GlyphKind.arrow) {
      canvas.translate(24, 0);
      canvas.scale(-1, 1);
    }
    final path = Path();
    switch (kind) {
      case _GlyphKind.arrow:
        path
          ..moveTo(4, 12)
          ..lineTo(19, 12)
          ..moveTo(13, 6)
          ..lineTo(19, 12)
          ..lineTo(13, 18);
      case _GlyphKind.down:
        path
          ..moveTo(5, 9)
          ..lineTo(12, 16)
          ..lineTo(19, 9);
      case _GlyphKind.menu:
        for (final y in [6.0, 12.0, 18.0]) {
          path
            ..moveTo(4, y)
            ..lineTo(20, y);
        }
      case _GlyphKind.close:
        path
          ..moveTo(6, 6)
          ..lineTo(18, 18)
          ..moveTo(18, 6)
          ..lineTo(6, 18);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MenuGlyphPainter oldDelegate) =>
      kind != oldDelegate.kind ||
      color != oldDelegate.color ||
      rtl != oldDelegate.rtl;
}
