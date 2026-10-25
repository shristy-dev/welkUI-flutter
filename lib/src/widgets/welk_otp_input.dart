import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// One native text editor under a row of hand-drawn slots. Native selection,
/// backspace, paste, autofill and screen-reader editing remain available.
class WelkOTPInput extends StatefulWidget {
  const WelkOTPInput({
    super.key,
    required this.label,
    required this.value,
    this.length = 6,
    this.onChanged,
    this.onComplete,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.focusNode,
    this.autofocus = false,
  }) : assert(length > 0),
       assert(value.length <= length);

  final String label;
  final String value;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onComplete;
  final bool disabled;
  final bool readOnly;
  final bool invalid;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<WelkOTPInput> createState() => _WelkOTPInputState();
}

class _WelkOTPInputState extends State<WelkOTPInput> {
  late final TextEditingController _controller;
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _validate();
    _controller = TextEditingController(text: widget.value)
      ..addListener(_refresh);
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(_refresh);
  }

  void _validate() {
    if (widget.length < 1 ||
        !RegExp(r'^[0-9]*$').hasMatch(widget.value) ||
        widget.value.length > widget.length) {
      throw ArgumentError('OTP must contain only digits and fit its length.');
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _sync() {
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(
          offset: _controller.selection.extentOffset.clamp(
            0,
            widget.value.length,
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(WelkOTPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
    if (oldWidget.focusNode != widget.focusNode) {
      _node.removeListener(_refresh);
      if (oldWidget.focusNode == null) _node.dispose();
      _node = widget.focusNode ?? FocusNode();
      _node.addListener(_refresh);
    }
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.removeListener(_refresh);
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context);
    final textStyle = TextStyle(
      fontFamily: t.fontFamily,
      package: t.fontPackage,
      color: t.ink,
      fontSize: 16,
      height: 1.5,
    );
    final digitStyle = textStyle.copyWith(
      fontSize: 22.4,
      fontWeight: FontWeight.w700,
      height: 1,
    );
    final active = _controller.selection.baseOffset.clamp(0, widget.length - 1);
    return DefaultTextStyle(
      style: textStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: widget.disabled ? null : _node.requestFocus,
            child: Text(
              widget.label,
              style: textStyle.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 9.6),
          LayoutBuilder(
            builder: (context, constraints) {
              final ideal = widget.length * 44.0 + (widget.length - 1) * 8;
              final width = math.min(ideal, constraints.maxWidth);
              final gap = math.min(8.0, width / (widget.length * 3));
              final slotWidth =
                  (width - gap * (widget.length - 1)) / widget.length;
              final height = math.max(
                52.0,
                MediaQuery.textScalerOf(context).scale(22.4) + 20,
              );
              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    ExcludeSemantics(
                      child: Opacity(
                        opacity: widget.disabled ? 0.55 : 1,
                        child: Row(
                          children: [
                            for (var i = 0; i < widget.length; i++) ...[
                              if (i > 0) SizedBox(width: gap),
                              Transform.rotate(
                                angle: (i.isEven ? -2 : 2) * math.pi / 180,
                                child: CustomPaint(
                                  painter: WelkHardShadowPainter(
                                    shape: _shape(slotWidth, height, t),
                                    color: t.ink,
                                    offset: const Offset(3, 3),
                                  ),
                                  child: Container(
                                    width: slotWidth,
                                    height: height,
                                    decoration: ShapeDecoration(
                                      color: widget.invalid
                                          ? t.error
                                          : _node.hasFocus && i == active
                                          ? t.accent
                                          : t.paper,
                                      shape: _shape(slotWidth, height, t),
                                    ),
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        i < widget.value.length
                                            ? widget.value[i]
                                            : '',
                                        style: digitStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        alwaysIncludeSemantics: true,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Semantics(
                            label: widget.label,
                            hint: 'Enter ${widget.length} digits',
                            validationResult: widget.invalid
                                ? SemanticsValidationResult.invalid
                                : SemanticsValidationResult.none,
                            child: TextField(
                              controller: _controller,
                              focusNode: _node,
                              autofocus: widget.autofocus,
                              enabled: !widget.disabled,
                              readOnly:
                                  widget.readOnly || widget.onChanged == null,
                              keyboardType: TextInputType.number,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(widget.length),
                              ],
                              style: digitStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (next) {
                                if (next != widget.value) {
                                  widget.onChanged?.call(next);
                                  if (next.length == widget.length) {
                                    widget.onComplete?.call(next);
                                  }
                                }
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) _sync();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ExcludeSemantics(
            child: Text(
              'Enter ${widget.length} digits',
              style: textStyle.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  WelkShapeBorder _shape(double width, double height, WelkThemeData t) =>
      WelkShapeBorder(
        radii: WelkCornerRadii(
          topLeft: Radius.elliptical(width * .17, height * .12),
          topRight: Radius.elliptical(width * .10, height * .22),
          bottomRight: Radius.elliptical(width * .20, height * .14),
          bottomLeft: Radius.elliptical(width * .12, height * .18),
        ),
        strokeColor: t.ink,
        strokeWidth: t.borderWidth,
      );
}
