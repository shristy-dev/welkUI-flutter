import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// A controlled, single-thumb range input (not a two-ended interval slider).
class WelkRangeSlider extends StatefulWidget {
  const WelkRangeSlider({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticFormatter,
  }) : assert(min < max),
       assert(step > 0),
       assert(value >= min && value <= max);

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final double step;
  final bool disabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final String Function(double)? semanticFormatter;

  @override
  State<WelkRangeSlider> createState() => _WelkRangeSliderState();
}

class _WelkRangeSliderState extends State<WelkRangeSlider> {
  late FocusNode _node;
  bool _focus = false;
  double? _lastRequested;
  bool get _enabled => !widget.disabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(WelkRangeSlider oldWidget) {
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

  double _snap(double value) {
    final steps =
        ((value.clamp(widget.min, widget.max) - widget.min) / widget.step)
            .round();
    // Match HTML ranges: the upper bound need not itself lie on the step grid.
    final maxSteps = ((widget.max - widget.min) / widget.step + 1e-10).floor();
    return (widget.min + math.min(steps, maxSteps) * widget.step).clamp(
      widget.min,
      widget.max,
    );
  }

  void _emit(double value, {bool dragging = false}) {
    if (!_enabled) return;
    final next = _snap(value);
    if (next == widget.value || (dragging && next == _lastRequested)) return;
    _lastRequested = next;
    widget.onChanged!(next);
  }

  void _adjust(double amount) => _emit(widget.value + amount);

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final focusShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.4),
    );
    final valueLabel =
        widget.semanticFormatter?.call(widget.value) ??
        '${widget.value == widget.value.roundToDouble() ? widget.value.toInt() : widget.value}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: t.fontFamily,
            package: t.fontPackage,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.5,
            color: t.ink,
          ),
        ),
        const SizedBox(height: 4),
        Opacity(
          opacity: _enabled ? 1 : 0.55,
          child: FocusableActionDetector(
            enabled: _enabled,
            focusNode: _node,
            autofocus: widget.autofocus,
            onShowFocusHighlight: (v) => setState(() => _focus = v),
            mouseCursor: _enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            shortcuts: {
              const SingleActivator(LogicalKeyboardKey.arrowRight):
                  _SliderIntent(rtl ? -1 : 1),
              const SingleActivator(LogicalKeyboardKey.arrowLeft):
                  _SliderIntent(rtl ? 1 : -1),
              const SingleActivator(LogicalKeyboardKey.arrowUp):
                  const _SliderIntent(1),
              const SingleActivator(LogicalKeyboardKey.arrowDown):
                  const _SliderIntent(-1),
              const SingleActivator(LogicalKeyboardKey.home):
                  const _SliderIntent(-2),
              const SingleActivator(LogicalKeyboardKey.end):
                  const _SliderIntent(2),
              const SingleActivator(LogicalKeyboardKey.pageUp):
                  const _SliderIntent(10),
              const SingleActivator(LogicalKeyboardKey.pageDown):
                  const _SliderIntent(-10),
            },
            actions: {
              _SliderIntent: CallbackAction<_SliderIntent>(
                onInvoke: (intent) {
                  if (intent.direction.abs() == 2) {
                    _emit(intent.direction < 0 ? widget.min : widget.max);
                  } else {
                    _adjust(widget.step * intent.direction);
                  }
                  return null;
                },
              ),
            },
            child: Semantics(
              container: true,
              label: widget.label,
              slider: true,
              value: valueLabel,
              enabled: _enabled,
              increasedValue:
                  widget.semanticFormatter?.call(
                    _snap(widget.value + widget.step),
                  ) ??
                  '${_snap(widget.value + widget.step)}',
              decreasedValue:
                  widget.semanticFormatter?.call(
                    _snap(widget.value - widget.step),
                  ) ??
                  '${_snap(widget.value - widget.step)}',
              onIncrease:
                  _enabled && _snap(widget.value + widget.step) > widget.value
                  ? () => _adjust(widget.step)
                  : null,
              onDecrease: _enabled && widget.value > widget.min
                  ? () => _adjust(-widget.step)
                  : null,
              child: ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 300.0;
                    final travel = math.max(0.0, width - 24);
                    final fraction =
                        (widget.value - widget.min) / (widget.max - widget.min);
                    final track = WelkShapeBorder(
                      radii: WelkCornerRadii(
                        topLeft: Radius.elliptical(width * .45, 2.8),
                        topRight: Radius.elliptical(width * .12, 4.4),
                        bottomRight: Radius.elliptical(width * .40, 2.4),
                        bottomLeft: Radius.elliptical(width * .15, 4.8),
                      ),
                      strokeColor: t.ink,
                      strokeWidth: t.borderWidth,
                    );
                    void seek(Offset local) {
                      if (travel <= 0) return;
                      var f = ((local.dx - 12) / travel).clamp(0.0, 1.0);
                      if (rtl) f = 1 - f;
                      _emit(
                        widget.min + f * (widget.max - widget.min),
                        dragging: true,
                      );
                    }

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: _enabled
                          ? (details) {
                              _node.requestFocus();
                              _lastRequested = null;
                              seek(details.localPosition);
                            }
                          : null,
                      onHorizontalDragStart: _enabled
                          ? (details) {
                              _node.requestFocus();
                              seek(details.localPosition);
                            }
                          : null,
                      onHorizontalDragUpdate: _enabled
                          ? (details) => seek(details.localPosition)
                          : null,
                      onHorizontalDragEnd: _enabled
                          ? (_) => _lastRequested = null
                          : null,
                      child: WelkFocusRing(
                        visible: _focus && _enabled,
                        color: t.focus,
                        shape: focusShape,
                        gap: 3,
                        child: SizedBox(
                          width: width,
                          height: 48,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 20,
                                left: 0,
                                right: 0,
                                height: 8,
                                child: CustomPaint(
                                  painter: WelkHardShadowPainter(
                                    shape: track,
                                    color: t.ink,
                                    offset: const Offset(1, 2),
                                  ),
                                  child: DecoratedBox(
                                    decoration: ShapeDecoration(
                                      color: t.paper,
                                      shape: track,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: (rtl ? 1 - fraction : fraction) * travel,
                                top: 12,
                                child: Transform.rotate(
                                  angle: -6 * math.pi / 180,
                                  child: _thumb(t),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thumb(WelkThemeData t) {
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(10.8, 13.2),
        topRight: Radius.elliptical(13.2, 10.08),
        bottomRight: Radius.elliptical(10.08, 13.92),
        bottomLeft: Radius.elliptical(13.92, 10.8),
      ),
      strokeColor: t.ink,
      strokeWidth: t.borderWidth,
    );
    return CustomPaint(
      painter: WelkHardShadowPainter(
        shape: shape,
        color: t.ink,
        offset: const Offset(2, 2),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: ShapeDecoration(color: t.accent, shape: shape),
      ),
    );
  }
}

class _SliderIntent extends Intent {
  const _SliderIntent(this.direction);
  final int direction;
}
