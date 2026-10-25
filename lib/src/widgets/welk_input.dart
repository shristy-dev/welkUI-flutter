import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkInputType { text, email, password, search, tel, url }

/// An independently labelled trailing action, such as clearing the field.
@immutable
class WelkInputAction {
  const WelkInputAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final bool disabled;
}

/// A controlled single-line editor with Welk's paper, outline and hard shadow.
///
/// [value] is the source of truth, including when a change is rejected.
class WelkInput extends StatefulWidget {
  const WelkInput({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.type = WelkInputType.text,
    this.placeholder,
    this.endAction,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.errorText,
    this.isRequired = false,
    this.focusNode,
    this.autofocus = false,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
  });

  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final WelkInputType type;
  final String? placeholder;
  final WelkInputAction? endAction;
  final bool disabled;
  final bool readOnly;
  final bool invalid;
  final String? errorText;
  final bool isRequired;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<WelkInput> createState() => _WelkInputState();
}

class _WelkInputState extends State<WelkInput> {
  late final TextEditingController _controller;
  late FocusNode _node;
  bool _hover = false;
  bool get _enabled => !widget.disabled;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  void _sync() {
    if (_controller.text == widget.value) return;
    final selection = _controller.selection;
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(
        offset: selection.extentOffset.clamp(0, widget.value.length),
      ),
    );
  }

  @override
  void didUpdateWidget(WelkInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _node.removeListener(_focusChanged);
      if (oldWidget.focusNode == null) _node.dispose();
      _node = widget.focusNode ?? FocusNode();
      _node.addListener(_focusChanged);
    }
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.removeListener(_focusChanged);
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  TextInputType get _keyboard => switch (widget.type) {
    WelkInputType.email => TextInputType.emailAddress,
    WelkInputType.tel => TextInputType.phone,
    WelkInputType.url => TextInputType.url,
    _ => TextInputType.text,
  };

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context);
    final error = widget.invalid || widget.errorText != null;
    final readOnly = widget.readOnly || widget.onChanged == null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.4),
      side: BorderSide(
        color: error ? t.errorHover : (_node.hasFocus ? t.focus : t.ink),
        width: _node.hasFocus ? 3 : t.borderWidth,
      ),
    );
    final style = TextStyle(
      fontFamily: t.fontFamily,
      package: t.fontPackage,
      color: t.ink,
      fontSize: 16,
      height: 1.5,
    );
    final action = widget.endAction;
    return DefaultTextStyle(
      style: style,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _enabled ? _node.requestFocus : null,
            child: Text(
              widget.label,
              style: style.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: _enabled ? 1 : 0.55,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: CustomPaint(
                painter: WelkHardShadowPainter(
                  shape: shape,
                  color: t.ink,
                  offset: const Offset(3, 3),
                ),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: !_enabled || readOnly || (_hover && !_node.hasFocus)
                        ? t.muted
                        : t.paper,
                    shape: shape,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            label: widget.label,
                            hint: widget.isRequired ? 'Required' : null,
                            validationResult: error
                                ? SemanticsValidationResult.invalid
                                : SemanticsValidationResult.none,
                            child: TextField(
                              controller: _controller,
                              focusNode: _node,
                              autofocus: widget.autofocus,
                              enabled: _enabled,
                              readOnly: readOnly,
                              style: style,
                              cursorColor: t.ink,
                              keyboardType: _keyboard,
                              obscureText:
                                  widget.type == WelkInputType.password,
                              autocorrect: widget.type == WelkInputType.text,
                              enableSuggestions:
                                  widget.type != WelkInputType.password,
                              textInputAction:
                                  widget.textInputAction ??
                                  (widget.type == WelkInputType.search
                                      ? TextInputAction.search
                                      : TextInputAction.done),
                              autofillHints: widget.autofillHints,
                              inputFormatters: widget.inputFormatters,
                              onSubmitted: widget.onSubmitted,
                              onChanged: (next) {
                                if (next != widget.value) {
                                  widget.onChanged?.call(next);
                                }
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) _sync();
                                });
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                filled: false,
                                hintText: widget.placeholder,
                                hintStyle: style.copyWith(
                                  color: t.ink.withValues(alpha: 0.65),
                                ),
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  18,
                                  14,
                                  action == null ? 18 : 8,
                                  14,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 52,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (action != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 2),
                            child: _InputEndAction(
                              action: action,
                              enabled: _enabled && !action.disabled,
                              dimmed: _enabled && action.disabled,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(widget.errorText!, style: style),
              ),
            ),
        ],
      ),
    );
  }
}

class _InputEndAction extends StatefulWidget {
  const _InputEndAction({
    required this.action,
    required this.enabled,
    required this.dimmed,
  });
  final WelkInputAction action;
  final bool enabled;
  final bool dimmed;

  @override
  State<_InputEndAction> createState() => _InputEndActionState();
}

class _InputEndActionState extends State<_InputEndAction> {
  final _node = FocusNode();
  bool _hover = false;
  bool _focus = false;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _activate() {
    if (!widget.enabled) return;
    _node.requestFocus();
    widget.action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context);
    return Tooltip(
      message: widget.action.label,
      excludeFromSemantics: true,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        focusNode: _node,
        mouseCursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
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
          label: widget.action.label,
          button: true,
          enabled: widget.enabled,
          onTap: widget.enabled ? _activate : null,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.enabled ? _activate : null,
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: Opacity(
                    opacity: widget.dimmed ? 0.55 : 1,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _hover && widget.enabled
                            ? t.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5.2),
                      ),
                      foregroundDecoration: _focus && widget.enabled
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(5.2),
                              border: Border.all(color: t.focus, width: 2),
                            )
                          : null,
                      child: IconTheme(
                        data: IconThemeData(color: t.ink, size: 24),
                        child: widget.action.icon,
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
