import 'package:flutter/widgets.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

@immutable
class WelkBreadCrumbItem {
  const WelkBreadCrumbItem({
    required this.label,
    this.onPressed,
    this.enabled = true,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final bool enabled;
}

/// Wrapping navigation, with the final item marked as the current page.
class WelkBreadCrumbs extends StatelessWidget {
  const WelkBreadCrumbs({
    super.key,
    required this.items,
    this.separator = const Text('/'),
    this.semanticLabel = 'Breadcrumb',
    this.overRideDarkMode,
  });

  final List<WelkBreadCrumbItem> items;
  final Widget separator;
  final String semanticLabel;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  @override
  Widget build(BuildContext context) => WelkTheme.scope(
    context,
    overRideDarkMode: overRideDarkMode,
    child: Semantics(
      container: true,
      label: semanticLabel,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var index = 0; index < items.length; index++)
            _Crumb(
              item: items[index],
              current: index == items.length - 1,
              separator: index == 0 ? null : separator,
              overRideDarkMode: overRideDarkMode,
            ),
        ],
      ),
    ),
  );
}

class _Crumb extends StatefulWidget {
  const _Crumb({
    required this.item,
    required this.current,
    required this.separator,
    required this.overRideDarkMode,
  });
  final WelkBreadCrumbItem item;
  final bool current;
  final Widget? separator;
  final bool? overRideDarkMode;

  @override
  State<_Crumb> createState() => _CrumbState();
}

class _CrumbState extends State<_Crumb> {
  bool _focus = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: widget.overRideDarkMode);
    final enabled = widget.item.enabled && widget.item.onPressed != null;
    final color = widget.current
        ? theme.accent
        : _hover && enabled
        ? theme.accentHover
        : theme.paper;
    final foreground = theme.onFill(color);
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(8, 5),
        topRight: Radius.elliptical(5, 9),
        bottomRight: Radius.elliptical(10, 6),
        bottomLeft: Radius.elliptical(6, 8),
      ),
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
    );
    final surface = Transform.rotate(
      angle: widget.current ? -.0174533 : 0,
      child: WelkFocusRing(
        gap: 3,
        visible: _focus && enabled,
        color: theme.focus,
        shape: shape,
        child: CustomPaint(
          painter: widget.current
              ? WelkHardShadowPainter(
                  shape: shape,
                  color: theme.shadow,
                  offset: const Offset(2, 2),
                )
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.6 + theme.borderWidth,
              vertical: 4 + theme.borderWidth,
            ),
            decoration: ShapeDecoration(color: color, shape: shape),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: theme.fontFamily,
                package: theme.fontPackage,
                fontSize: 14.4,
                height: 1.5,
                fontWeight: widget.current ? FontWeight.w700 : FontWeight.w400,
                color: foreground,
              ),
              child: theme.isDark
                  ? IconTheme.merge(
                      data: IconThemeData(color: foreground),
                      child: widget.item.label,
                    )
                  : widget.item.label,
            ),
          ),
        ),
      ),
    );
    Widget crumb = Semantics(
      link: widget.item.onPressed != null,
      selected: widget.current,
      enabled: widget.item.onPressed != null ? enabled : null,
      child: surface,
    );
    if (widget.item.onPressed != null) {
      crumb = Opacity(
        opacity: enabled ? 1 : .55,
        child: FocusableActionDetector(
          enabled: enabled,
          onShowFocusHighlight: (value) => setState(() => _focus = value),
          onShowHoverHighlight: (value) => setState(() => _hover = value),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                if (enabled) widget.item.onPressed!();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? widget.item.onPressed : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(widthFactor: 1, heightFactor: 1, child: crumb),
            ),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.separator != null) ...[
            ExcludeSemantics(
              child: Transform.rotate(
                angle: .139626,
                // Separators sit on the page, so dark mode supplies readable
                // defaults; explicit separator colors still take precedence.
                child: theme.isDark
                    ? IconTheme.merge(
                        data: IconThemeData(color: theme.ink),
                        child: DefaultTextStyle.merge(
                          style: TextStyle(color: theme.ink),
                          child: widget.separator!,
                        ),
                      )
                    : widget.separator,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: crumb),
        ],
      ),
    );
  }
}
