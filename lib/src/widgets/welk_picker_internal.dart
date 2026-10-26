import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

const pickerRadii = WelkCornerRadii(
  topLeft: Radius.elliptical(16, 10),
  topRight: Radius.elliptical(9, 18),
  bottomRight: Radius.elliptical(20, 9),
  bottomLeft: Radius.elliptical(11, 16),
);

WelkCornerRadii pickerCircularRadii(double a, double b, double c, double d) =>
    WelkCornerRadii(
      topLeft: Radius.circular(a),
      topRight: Radius.circular(b),
      bottomRight: Radius.circular(c),
      bottomLeft: Radius.circular(d),
    );

TextStyle pickerTextStyle(BuildContext context, {double size = 16}) {
  final theme = WelkTheme.of(context).resolveColors(context);
  return TextStyle(
    color: theme.ink,
    fontFamily: theme.fontFamily,
    package: theme.fontPackage,
    fontSize: size,
    height: 1.5,
  );
}

class PickerSurface extends StatelessWidget {
  const PickerSurface({
    super.key,
    required this.child,
    this.radii = pickerRadii,
    this.color,
    this.shadow = true,
    this.shadowOffset,
    this.padding = EdgeInsets.zero,
    this.outlined = true,
    this.overRideDarkMode,
  });

  final Widget child;
  final WelkCornerRadii radii;
  final Color? color;
  final bool shadow;
  final Offset? shadowOffset;
  final EdgeInsetsGeometry padding;
  final bool outlined;
  final bool? overRideDarkMode;

  @override
  Widget build(BuildContext context) => WelkTheme.scope(
    context,
    overRideDarkMode: overRideDarkMode,
    child: Builder(builder: _build),
  );

  Widget _build(BuildContext context) {
    final theme = WelkTheme.of(context).resolveColors(context);
    final foreground = theme.isDark && color != null
        ? theme.onFill(color!)
        : theme.ink;
    final shape = WelkShapeBorder(
      radii: radii,
      strokeColor: outlined ? theme.outline : Colors.transparent,
      strokeWidth: theme.borderWidth,
    );
    return CustomPaint(
      painter: shadow
          ? WelkHardShadowPainter(
              shape: shape,
              color: theme.shadow,
              offset: shadowOffset ?? theme.cardShadowOffset,
            )
          : null,
      child: Container(
        decoration: ShapeDecoration(color: color ?? theme.paper, shape: shape),
        padding: padding,
        child: DefaultTextStyle(
          style: pickerTextStyle(context).copyWith(color: foreground),
          child: theme.isDark
              ? IconTheme.merge(
                  data: IconThemeData(color: foreground),
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}

/// Shared unstyled, keyboard-operable picker action.
class PickerButton extends StatefulWidget {
  const PickerButton({
    super.key,
    required this.child,
    required this.label,
    this.onPressed,
    this.selected,
    this.current = false,
    this.outlined = true,
    this.color,
    this.radii,
    this.focusNode,
    this.onKeyEvent,
    this.selectedShadow = true,
    this.rotation = 0,
    this.disabledOpacity = 0.45,
    this.minimumSize = const Size(48, 48),
    this.visualSize,
    this.overRideDarkMode,
  });

  final Widget child;
  final String label;
  final VoidCallback? onPressed;
  final bool? selected;
  final bool current;
  final bool outlined;
  final Color? color;
  final WelkCornerRadii? radii;
  final FocusNode? focusNode;
  final FocusOnKeyEventCallback? onKeyEvent;
  final bool selectedShadow;
  final double rotation;
  final double disabledOpacity;
  final Size minimumSize;
  final Size? visualSize;
  final bool? overRideDarkMode;

  @override
  State<PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends State<PickerButton> {
  bool _focused = false;
  bool _hovered = false;

  Widget _sizeSurface(Widget surface) => widget.visualSize == null
      ? surface
      : SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox.fromSize(size: widget.visualSize, child: surface),
          ),
        );

  @override
  Widget build(BuildContext context) => WelkTheme.scope(
    context,
    overRideDarkMode: widget.overRideDarkMode,
    child: Builder(builder: _build),
  );

  Widget _build(BuildContext context) {
    final theme = WelkTheme.of(context).resolveColors(context);
    final enabled = widget.onPressed != null;
    final radii = widget.radii ?? pickerCircularRadii(8, 5, 9, 6);
    final shape = WelkShapeBorder(
      radii: radii,
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
    );
    return Focus(
      canRequestFocus: enabled,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: widget.onKeyEvent,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: Semantics(
          button: true,
          enabled: enabled,
          selected: widget.selected,
          label: widget.label,
          onTap: widget.onPressed,
          child: ExcludeSemantics(
            child: GestureDetector(
              onTap: widget.onPressed,
              behavior: HitTestBehavior.opaque,
              child: _sizeSurface(
                Opacity(
                  opacity: enabled ? 1 : widget.disabledOpacity,
                  child: Transform.rotate(
                    angle: widget.rotation,
                    child: WelkFocusRing(
                      visible: _focused && enabled,
                      color: theme.focus,
                      shape: shape,
                      gap: 2,
                      child: PickerSurface(
                        color: _hovered && enabled
                            ? theme.accentHover
                            : widget.selected == true
                            ? theme.accent
                            : widget.color,
                        radii: radii,
                        outlined:
                            widget.outlined ||
                            widget.current ||
                            widget.selected == true,
                        shadow:
                            widget.selected == true && widget.selectedShadow,
                        shadowOffset: const Offset(2, 2),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: widget.minimumSize.width,
                            minHeight: widget.minimumSize.height,
                          ),
                          child: Center(child: widget.child),
                        ),
                      ),
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

class PickerEditor extends StatefulWidget {
  const PickerEditor({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    this.error,
    this.suffix,
    this.focusNode,
    this.autofocus = false,
    this.helperText,
    this.timeStyle = false,
    this.overRideDarkMode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String? error;
  final Widget? suffix;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? helperText;
  final bool timeStyle;
  final bool? overRideDarkMode;

  @override
  State<PickerEditor> createState() => _PickerEditorState();
}

class _PickerEditorState extends State<PickerEditor> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => WelkTheme.scope(
    context,
    overRideDarkMode: widget.overRideDarkMode,
    child: Builder(builder: _build),
  );

  Widget _build(BuildContext context) {
    final theme = WelkTheme.of(context).resolveColors(context);
    final radii = pickerCircularRadii(8, 12, 7, 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: pickerTextStyle(context).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Focus(
                skipTraversal: true,
                includeSemantics: false,
                onFocusChange: (value) => setState(() => _focused = value),
                child: WelkFocusRing(
                  // Keep the editor subtree stable when focus changes.
                  visible: true,
                  color: _focused ? theme.focus : Colors.transparent,
                  shape: WelkShapeBorder(radii: radii),
                  gap: 2,
                  child: Opacity(
                    opacity: widget.enabled
                        ? 1
                        : (widget.timeStyle ? 0.55 : 0.45),
                    child: PickerSurface(
                      radii: radii,
                      shadow: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Semantics(
                                label: widget.label,
                                child: TextField(
                                  controller: widget.controller,
                                  focusNode: widget.focusNode,
                                  autofocus: widget.autofocus,
                                  enabled: widget.enabled,
                                  style: pickerTextStyle(context),
                                  textDirection: TextDirection.ltr,
                                  keyboardType: TextInputType.datetime,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  cursorColor: theme.ink,
                                  onChanged: widget.onChanged,
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: widget.hint,
                                    hintStyle: pickerTextStyle(context)
                                        .copyWith(
                                          color: theme.ink.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (widget.suffix != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 4),
                              child: widget.suffix!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.timeStyle ? 8 : 6.4),
        Text(
          widget.helperText ?? widget.hint,
          style: pickerTextStyle(context, size: 12),
        ),
        if (widget.error != null) ...[
          SizedBox(height: widget.timeStyle ? 8 : 6.4),
          Semantics(
            liveRegion: true,
            child: PickerSurface(
              color: theme.error,
              radii: widget.timeStyle
                  ? pickerCircularRadii(8, 5, 9, 6)
                  : pickerCircularRadii(7, 10, 6, 8),
              shadow: false,
              padding: EdgeInsets.all(widget.timeStyle ? 8 : 6.4),
              child: Text(
                widget.error!,
                style: pickerTextStyle(
                  context,
                  size: 12,
                ).copyWith(color: theme.onFill(theme.error)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

DateTime pickerDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

String pickerFormatDate(DateTime? date) => date == null
    ? ''
    : '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

DateTime? pickerParseDate(String text) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return null;
  final parts = text.split('-').map(int.parse).toList();
  if (parts[0] < 1) return null;
  final date = DateTime(parts[0], parts[1], parts[2]);
  return pickerFormatDate(date) == text ? date : null;
}

void pickerValidateDates(DateTime? value, DateTime? min, DateTime? max) {
  for (final date in [value, min, max]) {
    if (date != null && (date.year < 1 || date.year > 9999)) {
      throw ArgumentError('Dates must have years from 1 through 9999.');
    }
  }
  if (min != null &&
      max != null &&
      pickerDateOnly(min).isAfter(pickerDateOnly(max))) {
    throw ArgumentError('minDate must not be after maxDate.');
  }
}
