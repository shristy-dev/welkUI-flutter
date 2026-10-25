import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// A controlled checkbox. A null [onChanged] or [disabled] disables interaction.
///
/// [indeterminate] is a visual mixed state; activating it requests `true`.
class WelkCheckBox extends StatefulWidget {
  const WelkCheckBox({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.indeterminate = false,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;
  final bool indeterminate;
  final bool disabled;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<WelkCheckBox> createState() => _WelkCheckBoxState();
}

class _WelkCheckBoxState extends State<WelkCheckBox> {
  late FocusNode _node;
  bool _focus = false;
  bool get _enabled => !widget.disabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(WelkCheckBox oldWidget) {
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
    widget.onChanged!(widget.indeterminate || !widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context);
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(3.6, 2.4),
        topRight: Radius.elliptical(2.4, 4.4),
        bottomRight: Radius.elliptical(4, 2.8),
        bottomLeft: Radius.elliptical(2, 4),
      ),
      strokeColor: t.ink,
      strokeWidth: t.borderWidth,
    );
    return Opacity(
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
          checked: widget.indeterminate ? null : widget.value,
          mixed: widget.indeterminate,
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
                      angle: -3 * math.pi / 180,
                      child: WelkFocusRing(
                        visible: _focus && _enabled,
                        color: t.focus,
                        shape: shape,
                        gap: 3,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: ShapeDecoration(
                            color: widget.value ? t.accent : t.paper,
                            shape: shape,
                          ),
                          alignment: Alignment.center,
                          child: CustomPaint(
                            size: const Size(12, 12),
                            painter: _CheckMark(
                              color: t.ink,
                              visible: widget.value || widget.indeterminate,
                              mixed: widget.indeterminate,
                            ),
                          ),
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
  }
}

class _CheckMark extends CustomPainter {
  const _CheckMark({
    required this.color,
    required this.visible,
    required this.mixed,
  });
  final Color color;
  final bool visible;
  final bool mixed;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final path = mixed
        ? (Path()..addRect(Rect.fromLTWH(0.6, 4.8, 10.8, 2.4)))
        : (Path()
            ..moveTo(1.2, 5.4)
            ..lineTo(4.2, 7.8)
            ..lineTo(10.2, 1.2)
            ..lineTo(12, 3)
            ..lineTo(4.56, 11.4)
            ..lineTo(0, 7.2)
            ..close());
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CheckMark oldDelegate) =>
      color != oldDelegate.color ||
      visible != oldDelegate.visible ||
      mixed != oldDelegate.mixed;
}
