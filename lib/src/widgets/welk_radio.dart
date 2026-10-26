import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// A controlled radio. Activating an already selected radio is a no-op.
class WelkRadio extends StatefulWidget {
  const WelkRadio({
    super.key,
    required this.selected,
    required this.label,
    this.onChanged,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
  });

  final bool selected;
  final String label;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  @override
  State<WelkRadio> createState() => _WelkRadioState();
}

class _WelkRadioState extends State<WelkRadio> {
  late FocusNode _node;
  bool _focus = false;
  bool get _enabled => !widget.disabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(WelkRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) _node.dispose();
      _node = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  void _activate() {
    if (!_enabled) return;
    _node.requestFocus();
    if (!widget.selected) widget.onChanged!(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: widget.overRideDarkMode);
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(9.2, 10.8),
        topRight: Radius.elliptical(10.8, 9),
        bottomRight: Radius.elliptical(9.6, 11),
        bottomLeft: Radius.elliptical(10.4, 9.2),
      ),
      strokeColor: t.outline,
      strokeWidth: t.borderWidth,
    );
    final radio = Opacity(
      opacity: _enabled ? 1 : 0.55,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: _node,
        autofocus: widget.autofocus,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: Semantics(
          container: true,
          label: widget.label,
          checked: widget.selected,
          inMutuallyExclusiveGroup: true,
          enabled: _enabled,
          onTap: _enabled ? _activate : null,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _enabled ? _activate : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: -4 * math.pi / 180,
                      child: WelkFocusRing(
                        visible: _focus && _enabled,
                        color: t.focus,
                        shape: shape,
                        gap: 3,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: ShapeDecoration(
                            color: widget.selected ? t.accent : t.paper,
                            shape: shape,
                          ),
                          alignment: Alignment.center,
                          child: widget.selected
                              ? Container(
                                  width: 8.8,
                                  height: 8.8,
                                  decoration: BoxDecoration(
                                    color: t.onFill(t.accent),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(3.872),
                                      topRight: Radius.circular(4.928),
                                      bottomRight: Radius.circular(4.224),
                                      bottomLeft: Radius.circular(4.576),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.4),
                    Flexible(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          package: t.fontPackage,
                          color: t.ink,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: widget.overRideDarkMode,
      child: radio,
    );
  }
}
