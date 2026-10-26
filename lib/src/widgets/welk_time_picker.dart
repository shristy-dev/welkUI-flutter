import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_picker_internal.dart';

/// A 24-hour wall-clock time with real, independent seconds.
///
/// Unlike [TimeOfDay], this value can represent seconds without using an
/// arbitrary date or time zone.
@immutable
class WelkTime {
  const WelkTime({required this.hour, required this.minute, this.second = 0})
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60),
      assert(second >= 0 && second < 60);

  factory WelkTime.fromTimeOfDay(TimeOfDay time, {int second = 0}) =>
      WelkTime(hour: time.hour, minute: time.minute, second: second);

  final int hour;
  final int minute;
  final int second;

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  WelkTime copyWith({int? hour, int? minute, int? second}) => WelkTime(
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    second: second ?? this.second,
  );

  String format({bool showSeconds = false}) =>
      '${_pad(hour)}:${_pad(minute)}${showSeconds ? ':${_pad(second)}' : ''}';

  @override
  bool operator ==(Object other) =>
      other is WelkTime &&
      other.hour == hour &&
      other.minute == minute &&
      other.second == second;

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() => format(showSeconds: true);
}

String _pad(int number) => number.toString().padLeft(2, '0');

/// A controlled time editor with scrollable, keyboard-operable time columns.
///
/// Invalid drafts are displayed with an error but never emitted. Clearing emits
/// null unless [isRequired]. Seconds are preserved when [showSeconds] is false.
/// A null [onChanged] disables the editor and every column.
class WelkTimePicker extends StatefulWidget {
  const WelkTimePicker({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.showSeconds = false,
    this.isRequired = false,
    this.validator,
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
  });

  final String label;
  final WelkTime? value;
  final ValueChanged<WelkTime?>? onChanged;
  final bool showSeconds;
  final bool isRequired;
  final String? Function(WelkTime?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? overRideDarkMode;

  @override
  State<WelkTimePicker> createState() => _WelkTimePickerState();
}

class _WelkTimePickerState extends State<WelkTimePicker> {
  late final TextEditingController _controller;

  String get _format => widget.showSeconds ? 'HH:mm:ss' : 'HH:mm';
  String _text(WelkTime? value) =>
      value?.format(showSeconds: widget.showSeconds) ?? '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _text(widget.value));
  }

  @override
  void didUpdateWidget(WelkTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value ||
        widget.showSeconds != oldWidget.showSeconds) {
      _controller.text = _text(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  WelkTime? _parse(String text) {
    final pattern = widget.showSeconds
        ? r'^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$'
        : r'^([01]\d|2[0-3]):[0-5]\d$';
    if (!RegExp(pattern).hasMatch(text)) return null;
    final parts = text.split(':').map(int.parse).toList();
    return WelkTime(
      hour: parts[0],
      minute: parts[1],
      second: widget.showSeconds ? parts[2] : widget.value?.second ?? 0,
    );
  }

  String? _error(String text) {
    if (text.isEmpty) {
      return widget.isRequired
          ? 'Choose a time.'
          : widget.validator?.call(null);
    }
    final time = _parse(text);
    if (time == null) return 'Enter a valid time in $_format format (24-hour).';
    return widget.validator?.call(time);
  }

  void _edit(String text) {
    setState(() {});
    if (_error(text) == null) widget.onChanged?.call(_parse(text));
  }

  void _select(int part, int value) {
    if (widget.onChanged == null) return;
    final current = widget.value ?? const WelkTime(hour: 0, minute: 0);
    final next = switch (part) {
      0 => current.copyWith(hour: value),
      1 => current.copyWith(minute: value),
      _ => current.copyWith(second: value),
    };
    setState(() => _controller.text = _text(next));
    if (_error(_controller.text) == null) widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) => WelkTheme.scope(
    context,
    overRideDarkMode: widget.overRideDarkMode,
    child: Builder(builder: _build),
  );

  Widget _build(BuildContext context) {
    final time = widget.value ?? const WelkTime(hour: 0, minute: 0);
    final enabled = widget.onChanged != null;
    return SizedBox(
      width: 336,
      child: PickerSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PickerEditor(
              controller: _controller,
              label: widget.label,
              hint: _format,
              helperText: '$_format · 24-hour',
              timeStyle: true,
              enabled: enabled,
              onChanged: _edit,
              error: _error(_controller.text),
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
                final count = widget.showSeconds ? 3 : 2;
                final minimum =
                    count * 72.0 * scale.clamp(1.0, 2.5) + (count - 1) * 12;
                final width = constraints.maxWidth < minimum
                    ? minimum
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var part = 0; part < count; part++) ...[
                          if (part > 0) const SizedBox(width: 12),
                          Expanded(
                            child: _TimeColumn(
                              label: const [
                                'Hours',
                                'Minutes',
                                'Seconds',
                              ][part],
                              count: part == 0 ? 24 : 60,
                              value: [
                                time.hour,
                                time.minute,
                                time.second,
                              ][part],
                              onChanged: enabled
                                  ? (value) => _select(part, value)
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeColumn extends StatefulWidget {
  const _TimeColumn({
    required this.label,
    required this.count,
    required this.value,
    this.onChanged,
  });

  final String label;
  final int count;
  final int value;
  final ValueChanged<int>? onChanged;

  @override
  State<_TimeColumn> createState() => _TimeColumnState();
}

class _TimeColumnState extends State<_TimeColumn> {
  late final ScrollController _scroll;
  double _extent = 48;
  bool _focused = false;

  double get _offset =>
      ((widget.value - 1) * _extent).clamp(0.0, (widget.count - 3) * _extent);

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(initialScrollOffset: _offset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extent = MediaQuery.textScalerOf(context).scale(16) * 1.5 + 24;
    if (extent != _extent) {
      _extent = extent;
      _reveal();
    }
  }

  @override
  void didUpdateWidget(_TimeColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _reveal();
  }

  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(_offset);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _step(int amount) =>
      widget.onChanged?.call((widget.value + amount) % widget.count);

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context).resolveColors(context);
    return Column(
      children: [
        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: pickerTextStyle(
            context,
            size: 12.8,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: widget.label,
          value: _pad(widget.value),
          increasedValue: widget.onChanged == null
              ? null
              : _pad((widget.value + 1) % widget.count),
          decreasedValue: widget.onChanged == null
              ? null
              : _pad((widget.value - 1) % widget.count),
          enabled: widget.onChanged != null,
          onIncrease: widget.onChanged == null ? null : () => _step(1),
          onDecrease: widget.onChanged == null ? null : () => _step(-1),
          child: Focus(
            canRequestFocus: widget.onChanged != null,
            onFocusChange: (value) => setState(() => _focused = value),
            onKeyEvent: (_, event) {
              if (widget.onChanged == null ||
                  (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
                return KeyEventResult.ignored;
              }
              switch (event.logicalKey) {
                case LogicalKeyboardKey.arrowDown:
                  _step(1);
                case LogicalKeyboardKey.arrowUp:
                  _step(-1);
                case LogicalKeyboardKey.home:
                  widget.onChanged!(0);
                case LogicalKeyboardKey.end:
                  widget.onChanged!(widget.count - 1);
                default:
                  return KeyEventResult.ignored;
              }
              return KeyEventResult.handled;
            },
            child: WelkFocusRing(
              visible: true,
              color: _focused ? theme.focus : Colors.transparent,
              shape: WelkShapeBorder(radii: pickerCircularRadii(12, 8, 15, 9)),
              gap: 2,
              child: Opacity(
                opacity: widget.onChanged == null ? 0.55 : 1,
                child: PickerSurface(
                  color: theme.muted,
                  radii: pickerCircularRadii(12, 8, 15, 9),
                  shadowOffset: const Offset(2, 2),
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    height: _extent * 3,
                    child: ClipRect(
                      child: ListView.builder(
                        key: ValueKey('time-${widget.label}'),
                        controller: _scroll,
                        primary: false,
                        padding: EdgeInsets.zero,
                        itemExtent: _extent,
                        itemCount: widget.count,
                        itemBuilder: (context, index) => PickerButton(
                          key: ValueKey('${widget.label}-$index'),
                          label: '${widget.label} ${_pad(index)}',
                          selected: index == widget.value,
                          selectedShadow: false,
                          disabledOpacity: 0.55,
                          radii: WelkCornerRadii(
                            topLeft: Radius.elliptical(10, _extent * .12),
                            topRight: Radius.elliptical(7, _extent * .08),
                            bottomRight: Radius.elliptical(13, _extent * .16),
                            bottomLeft: Radius.elliptical(8, _extent * .10),
                          ),
                          outlined: false,
                          color: theme.muted,
                          onPressed: widget.onChanged == null
                              ? null
                              : () => widget.onChanged!(index),
                          child: Text(_pad(index)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
