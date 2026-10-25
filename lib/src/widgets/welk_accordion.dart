import 'package:flutter/widgets.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

enum WelkAccordionVariant { vertical, horizontal, nested }

/// A controlled ([expanded]) or locally managed disclosure.
class WelkAccordion extends StatefulWidget {
  const WelkAccordion({
    super.key,
    required this.title,
    required this.child,
    this.variant = WelkAccordionVariant.vertical,
    this.expanded,
    this.initiallyExpanded = false,
    this.onChanged,
    this.enabled = true,
    this.closeOnOutsideClick = false,
    this.fixedWidth,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
         fixedWidth == null || (fixedWidth > 0 && fixedWidth < double.infinity),
       );

  final Widget title;
  final Widget child;
  final WelkAccordionVariant variant;
  final bool? expanded;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final bool closeOnOutsideClick;
  final double? fixedWidth;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<WelkAccordion> createState() => _WelkAccordionState();
}

class _WelkAccordionState extends State<WelkAccordion> {
  late bool _expanded = widget.initiallyExpanded;
  bool _focus = false;
  bool get _open => widget.expanded ?? _expanded;

  void _change(bool value) {
    if (!widget.enabled || value == _open) return;
    if (widget.expanded == null) setState(() => _expanded = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.circular(10.4),
        topRight: Radius.circular(10.4),
        bottomRight: Radius.circular(10.4),
        bottomLeft: Radius.circular(10.4),
      ),
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return TapRegion(
      onTapOutside: widget.closeOnOutsideClick && _open
          ? (_) => _change(false)
          : null,
      child: Opacity(
        opacity: widget.enabled ? 1 : .55,
        child: SizedBox(
          width: widget.fixedWidth,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: theme.ink,
              fontFamily: theme.fontFamily,
              package: theme.fontPackage,
              fontSize: 16,
              height: 1.5,
            ),
            child: CustomPaint(
              painter: widget.variant == WelkAccordionVariant.nested
                  ? null
                  : WelkHardShadowPainter(
                      shape: shape,
                      color: theme.ink,
                      offset: theme.cardShadowOffset,
                    ),
              child: DecoratedBox(
                decoration: ShapeDecoration(color: theme.paper, shape: shape),
                child: Padding(
                  padding: EdgeInsets.all(theme.borderWidth),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Avoid a one-word-wide summary on narrow phones or
                      // when accessibility text scaling needs more room.
                      final horizontal =
                          widget.variant == WelkAccordionVariant.horizontal &&
                          constraints.maxWidth >=
                              360 * MediaQuery.textScalerOf(context).scale(1);
                      final header = FocusableActionDetector(
                        enabled: widget.enabled,
                        focusNode: widget.focusNode,
                        autofocus: widget.autofocus,
                        onShowFocusHighlight: (value) =>
                            setState(() => _focus = value),
                        actions: {
                          ActivateIntent: CallbackAction<ActivateIntent>(
                            onInvoke: (_) {
                              _change(!_open);
                              return null;
                            },
                          ),
                        },
                        child: Semantics(
                          button: true,
                          enabled: widget.enabled,
                          expanded: _open,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.enabled
                                ? () => _change(!_open)
                                : null,
                            child: WelkFocusRing(
                              gap: 4,
                              visible: _focus && widget.enabled,
                              color: theme.focus,
                              shape: shape,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: ShapeDecoration(
                                  color: _open ? theme.accent : theme.paper,
                                  shape: shape,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ExcludeSemantics(
                                      child: Text(
                                        _open
                                            ? '▾'
                                            : Directionality.of(context) ==
                                                  TextDirection.rtl
                                            ? '◂'
                                            : '▸',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DefaultTextStyle.merge(
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        child: widget.title,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                      Widget content = Flex(
                        direction: horizontal ? Axis.horizontal : Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: horizontal
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            flex: horizontal ? (_open ? 1 : 4) : 0,
                            fit: horizontal ? FlexFit.tight : FlexFit.loose,
                            child: header,
                          ),
                          Flexible(
                            flex: horizontal && _open ? 3 : 0,
                            fit: horizontal ? FlexFit.tight : FlexFit.loose,
                            child: Offstage(
                              offstage: !_open,
                              child: ExcludeFocus(
                                excluding: !_open,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: horizontal
                                        ? BorderDirectional(
                                            start: BorderSide(
                                              color: theme.ink,
                                              width: theme.borderWidth,
                                            ),
                                          )
                                        : Border(
                                            top: BorderSide(
                                              color: theme.ink,
                                              width: theme.borderWidth,
                                            ),
                                          ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: widget.child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                      if (widget.variant == WelkAccordionVariant.nested) {
                        content = DecoratedBox(
                          decoration: BoxDecoration(
                            border: BorderDirectional(
                              start: BorderSide(color: theme.ink, width: 2),
                            ),
                          ),
                          child: content,
                        );
                      }
                      if (welkAnimationsDisabled(context)) return content;
                      return AnimatedSize(
                        alignment: AlignmentDirectional.topStart,
                        duration: const Duration(milliseconds: 240),
                        child: content,
                      );
                    },
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
