import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkTabsVariant { defaultStyle, withBg }

@immutable
class WelkTabItem {
  const WelkTabItem({
    required this.label,
    required this.value,
    required this.content,
    this.disabled = false,
  });

  final Widget label;
  final String value;
  final Widget content;
  final bool disabled;
}

/// Accessible tabs with automatic arrow-key activation, Home/End navigation,
/// disabled-item skipping, and controlled or uncontrolled selection.
class WelkTabs extends StatefulWidget {
  const WelkTabs({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.variant = WelkTabsVariant.defaultStyle,
    this.orientation = Axis.horizontal,
  });

  final String label;
  final List<WelkTabItem> items;
  final String? value;
  final String? defaultValue;
  final ValueChanged<String>? onValueChange;
  final WelkTabsVariant variant;
  final Axis orientation;

  @override
  State<WelkTabs> createState() => _WelkTabsState();
}

class _WelkTabsState extends State<WelkTabs> {
  late String? _value = widget.defaultValue;
  final Map<String, FocusNode> _nodes = {};
  String? _focus;
  String? _hover;

  int get _activeIndex {
    final requested = widget.value ?? _value;
    final found = widget.items.indexWhere(
      (item) => item.value == requested && !item.disabled,
    );
    return found >= 0
        ? found
        : widget.items.indexWhere((item) => !item.disabled);
  }

  @override
  void didUpdateWidget(WelkTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final values = widget.items.map((item) => item.value).toSet();
    for (final value in _nodes.keys.toList()) {
      if (!values.contains(value)) _nodes.remove(value)!.dispose();
    }
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(int index) {
    if (index < 0 || widget.items[index].disabled || index == _activeIndex) {
      return;
    }
    final value = widget.items[index].value;
    if (widget.value == null) setState(() => _value = value);
    widget.onValueChange?.call(value);
  }

  KeyEventResult _key(int current, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final horizontal = widget.orientation == Axis.horizontal;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final previous = horizontal
        ? (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)
        : LogicalKeyboardKey.arrowUp;
    final next = horizontal
        ? (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowDown;
    int target = -1;
    if (key == LogicalKeyboardKey.home) {
      target = widget.items.indexWhere((item) => !item.disabled);
    } else if (key == LogicalKeyboardKey.end) {
      target = widget.items.lastIndexWhere((item) => !item.disabled);
    } else if (key == previous || key == next) {
      final direction = key == next ? 1 : -1;
      for (var offset = 1; offset <= widget.items.length; offset++) {
        final index = (current + offset * direction) % widget.items.length;
        if (!widget.items[index].disabled) {
          target = index;
          break;
        }
      }
    } else {
      return KeyEventResult.ignored;
    }
    if (target >= 0) {
      _nodes[widget.items[target].value]?.requestFocus();
      _select(target);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.items.map((item) => item.value).toSet().length ==
          widget.items.length,
      'Tab values must be unique.',
    );
    final theme = WelkTheme.of(context);
    final active = _activeIndex;
    final withBg = widget.variant == WelkTabsVariant.withBg;
    final panelShape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(7),
        bottomRight: Radius.circular(15),
        bottomLeft: Radius.circular(9),
      ),
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontFamily: theme.fontFamily,
        package: theme.fontPackage,
        color: theme.ink,
        fontSize: 16,
        height: 1.5,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical =
              widget.orientation == Axis.vertical &&
              constraints.maxWidth >=
                  360 * MediaQuery.textScalerOf(context).scale(1);
          final tabs = <Widget>[
            for (var index = 0; index < widget.items.length; index++)
              _tab(context, index, active, withBg, vertical),
          ];
          final tabList = Semantics(
            container: true,
            label: widget.label,
            child: Container(
              padding: withBg ? const EdgeInsets.all(8) : EdgeInsets.zero,
              decoration: withBg
                  ? ShapeDecoration(color: theme.muted, shape: panelShape)
                  : null,
              child: vertical
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < tabs.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          tabs[i],
                        ],
                      ],
                    )
                  : Wrap(spacing: 8, runSpacing: 8, children: tabs),
            ),
          );
          final panel = active < 0
              ? const SizedBox.shrink()
              : Focus(
                  child: Builder(
                    builder: (context) => WelkFocusRing(
                      gap: 3,
                      visible: Focus.of(context).hasPrimaryFocus,
                      color: theme.focus,
                      shape: panelShape,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: theme.paper,
                          shape: panelShape,
                        ),
                        child: Stack(
                          children: [
                            for (var i = 0; i < widget.items.length; i++)
                              Offstage(
                                key: ValueKey(widget.items[i].value),
                                offstage: i != active,
                                child: ExcludeFocus(
                                  excluding: i != active,
                                  child: TickerMode(
                                    enabled: i == active,
                                    child: widget.items[i].content,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
          if (vertical) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex: 2, child: tabList),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: panel),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              tabList,
              if (active >= 0) ...[const SizedBox(height: 12), panel],
            ],
          );
        },
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    int index,
    int active,
    bool withBg,
    bool vertical,
  ) {
    final theme = WelkTheme.of(context);
    final item = widget.items[index];
    final selected = index == active;
    final node = _nodes.putIfAbsent(
      item.value,
      () => FocusNode(debugLabel: 'WelkTabs ${item.value}'),
    );
    node.skipTraversal = !selected;
    final shape = WelkShapeBorder(
      radii: vertical
          ? const WelkCornerRadii(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(7),
              bottomLeft: Radius.circular(4),
            )
          : const WelkCornerRadii(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(9),
              bottomLeft: Radius.circular(5),
            ),
      strokeColor: withBg && !selected ? const Color(0x00000000) : theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return Opacity(
      opacity: item.disabled ? .55 : 1,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) => _key(index, event),
        child: FocusableActionDetector(
          focusNode: node,
          enabled: !item.disabled,
          onShowFocusHighlight: (value) =>
              setState(() => _focus = value ? item.value : null),
          onShowHoverHighlight: (value) =>
              setState(() => _hover = value ? item.value : null),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _select(index);
                return null;
              },
            ),
          },
          child: Semantics(
            button: true,
            selected: selected,
            enabled: !item.disabled,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: item.disabled
                  ? null
                  : () {
                      node.requestFocus();
                      _select(index);
                    },
              child: WelkFocusRing(
                gap: 3,
                visible: _focus == item.value,
                color: theme.focus,
                shape: shape,
                child: CustomPaint(
                  painter: withBg && selected
                      ? WelkHardShadowPainter(
                          shape: shape,
                          color: theme.ink,
                          offset: theme.buttonShadowOffset,
                        )
                      : null,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 + theme.borderWidth,
                      vertical: 8.8 + theme.borderWidth,
                    ),
                    decoration: ShapeDecoration(
                      shape: shape,
                      color: selected
                          ? theme.accent
                          : _hover == item.value && !item.disabled
                          ? theme.muted
                          : withBg
                          ? const Color(0x00000000)
                          : theme.paper,
                    ),
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      child: item.label,
                    ),
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
