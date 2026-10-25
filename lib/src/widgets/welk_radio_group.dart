import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/welk_theme.dart';
import 'welk_radio.dart';

@immutable
class WelkRadioOption {
  const WelkRadioOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
  final String value;
  final String label;
  final bool disabled;
}

/// A controlled, labelled radio group with wrapping arrow-key navigation.
class WelkRadioGroup extends StatefulWidget {
  const WelkRadioGroup({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    this.onChanged,
    this.disabled = false,
    this.isRequired = false,
  });

  final String label;
  final List<WelkRadioOption> options;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool disabled;
  final bool isRequired;

  @override
  State<WelkRadioGroup> createState() => _WelkRadioGroupState();
}

class _WelkRadioGroupState extends State<WelkRadioGroup> {
  final Map<String, FocusNode> _nodes = {};
  bool get _enabled => !widget.disabled && widget.onChanged != null;

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(WelkRadioGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final values = widget.options.map((o) => o.value).toSet();
    for (final value in _nodes.keys.toList()) {
      if (!values.contains(value)) _nodes.remove(value)!.dispose();
    }
  }

  void _move(String from, int direction, {bool edge = false}) {
    if (!_enabled) return;
    final enabled = widget.options.where((o) => !o.disabled).toList();
    if (enabled.isEmpty) return;
    final i = enabled.indexWhere((o) => o.value == from);
    final next =
        enabled[edge
            ? (direction > 0 ? 0 : enabled.length - 1)
            : (i + direction) % enabled.length];
    _nodes[next.value]?.requestFocus();
    if (next.value != widget.value) widget.onChanged!(next.value);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.options.map((o) => o.value).toSet().length ==
          widget.options.length,
      'Radio option values must be unique.',
    );
    final t = WelkTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final enabledOptions = widget.options.where((o) => !o.disabled);
    final tabValue = enabledOptions.any((o) => o.value == widget.value)
        ? widget.value
        : enabledOptions.firstOrNull?.value;
    for (final option in widget.options) {
      _nodes
              .putIfAbsent(
                option.value,
                () => FocusNode(debugLabel: option.label),
              )
              .skipTraversal =
          option.value != tabValue;
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.isRequired ? '${widget.label}, required' : widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: t.fontFamily,
                package: t.fontPackage,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: t.ink,
              ),
            ),
          ),
          for (final option in widget.options)
            Focus(
              canRequestFocus: false,
              onKeyEvent: (_, event) {
                if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                  return KeyEventResult.ignored;
                }
                final key = event.logicalKey;
                int? direction;
                if (key == LogicalKeyboardKey.arrowDown) direction = 1;
                if (key == LogicalKeyboardKey.arrowUp) direction = -1;
                if (key == LogicalKeyboardKey.arrowRight) {
                  direction = rtl ? -1 : 1;
                }
                if (key == LogicalKeyboardKey.arrowLeft) {
                  direction = rtl ? 1 : -1;
                }
                if (key == LogicalKeyboardKey.home) direction = 1;
                if (key == LogicalKeyboardKey.end) direction = -1;
                if (direction == null) return KeyEventResult.ignored;
                _move(
                  option.value,
                  direction,
                  edge:
                      key == LogicalKeyboardKey.home ||
                      key == LogicalKeyboardKey.end,
                );
                return KeyEventResult.handled;
              },
              child: WelkRadio(
                label: option.label,
                selected: widget.value == option.value,
                disabled: !_enabled || option.disabled,
                focusNode: _nodes[option.value],
                onChanged: (_) => widget.onChanged?.call(option.value),
              ),
            ),
        ],
      ),
    );
  }
}
