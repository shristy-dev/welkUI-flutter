import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

@immutable
class WelkDropDownOption {
  const WelkDropDownOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
  final String value;
  final String label;
  final bool disabled;
}

/// A controlled select with a viewport-clamped, dismissible popup on all
/// platforms. Search is performed locally and disabled options are skipped.
/// Changing the options, selection, or availability dismisses an open popup.
class WelkDropDown extends StatefulWidget {
  const WelkDropDown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    this.onChanged,
    this.searchable = false,
    this.placeholder = 'Select an option',
    this.disabled = false,
    this.isRequired = false,
    this.focusNode,
    this.autofocus = false,
    this.overRideDarkMode,
  });

  final String label;
  final List<WelkDropDownOption> options;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool searchable;
  final String placeholder;
  final bool disabled;
  final bool isRequired;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  @override
  State<WelkDropDown> createState() => _WelkDropDownState();
}

class _WelkDropDownState extends State<WelkDropDown> {
  final _anchor = GlobalKey();
  late FocusNode _node;
  bool _focus = false;
  bool _open = false;
  RawDialogRoute<String>? _popupRoute;
  List<WelkDropDownOption>? _popupOptions;
  bool get _enabled => !widget.disabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(WelkDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_popupRoute != null &&
        (oldWidget.value != widget.value ||
            oldWidget.disabled != widget.disabled ||
            (oldWidget.onChanged == null) != (widget.onChanged == null) ||
            oldWidget.searchable != widget.searchable ||
            oldWidget.label != widget.label ||
            oldWidget.isRequired != widget.isRequired ||
            oldWidget.overRideDarkMode != widget.overRideDarkMode ||
            !_sameOptions(_popupOptions!, widget.options))) {
      _dismissPopup();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) _node.dispose();
      _node = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    _dismissPopup();
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  bool _sameOptions(
    List<WelkDropDownOption> previous,
    List<WelkDropDownOption> next,
  ) {
    if (previous.length != next.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].value != next[i].value ||
          previous[i].label != next[i].label ||
          previous[i].disabled != next[i].disabled) {
        return false;
      }
    }
    return true;
  }

  void _dismissPopup() {
    final route = _popupRoute;
    _popupRoute = null;
    _popupOptions = null;
    if (route == null) return;
    // Updates and disposal can happen while Navigator is building/locked.
    // Remove only our route, even if another route has since covered it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (navigator != null && navigator.mounted && route.isActive) {
        navigator.removeRoute(route);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _show() async {
    if (!_enabled || _open) return;
    final box = _anchor.currentContext!.findRenderObject()! as RenderBox;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    // Only themes between the field and the root navigator (local WelkTheme,
    // Flutter Theme) are captured; providers above it stay live in the popup.
    final inheritedThemes = InheritedTheme.capture(
      from: context,
      to: navigator.context,
    );
    final overRideDarkMode = widget.overRideDarkMode;
    final options = List<WelkDropDownOption>.of(widget.options);
    final value = widget.value;
    final label = widget.label;
    final searchable = widget.searchable;
    bool? traverseBackwards;
    setState(() => _open = true);
    final route = RawDialogRoute<String>(
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: welkAnimationsDisabled(context)
          ? Duration.zero
          : const Duration(milliseconds: 120),
      pageBuilder: (context, _, _) => inheritedThemes.wrap(
        MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: Builder(
            builder: (context) => WelkTheme.scope(
              context,
              overRideDarkMode: overRideDarkMode,
              child: Directionality(
                textDirection: direction,
                child: _SelectPopup(
                  anchor: rect,
                  label: label,
                  options: options,
                  value: value,
                  searchable: searchable,
                  onTraverse: (backwards) => traverseBackwards = backwards,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _popupRoute = route;
    _popupOptions = options;
    final selected = await navigator.push<String>(route);
    final valid = identical(_popupRoute, route);
    if (valid) {
      _popupRoute = null;
      _popupOptions = null;
    }
    if (!mounted) return;
    setState(() => _open = false);
    if (!valid) return;
    if (selected != null &&
        _enabled &&
        selected != widget.value &&
        widget.options.any((o) => o.value == selected && !o.disabled)) {
      widget.onChanged!(selected);
    }
    if (_enabled) {
      _node.requestFocus();
      if (traverseBackwards != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_enabled) return;
          if (traverseBackwards!) {
            _node.previousFocus();
          } else {
            _node.nextFocus();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.options.map((o) => o.value).toSet().length ==
          widget.options.length,
      'Dropdown option values must be unique.',
    );
    final t = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: widget.overRideDarkMode);
    final style = TextStyle(
      fontFamily: t.fontFamily,
      package: t.fontPackage,
      color: t.ink,
      fontSize: 16,
      height: 1.5,
    );
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(12, 8),
        topRight: Radius.elliptical(7, 13),
        bottomRight: Radius.elliptical(14, 7),
        bottomLeft: Radius.elliptical(8, 12),
      ),
      strokeColor: t.outline,
      strokeWidth: t.borderWidth,
    );
    final matching = widget.options.where((o) => o.value == widget.value);
    final selected = matching.isEmpty ? null : matching.first.label;
    final field = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: style.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
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
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
                SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                SingleActivator(LogicalKeyboardKey.arrowDown): ActivateIntent(),
                SingleActivator(LogicalKeyboardKey.arrowUp): ActivateIntent(),
              },
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    _show();
                    return null;
                  },
                ),
              },
              child: Semantics(
                container: true,
                label: widget.label,
                value: selected ?? widget.placeholder,
                hint: widget.isRequired ? 'Required' : null,
                button: true,
                expanded: _open,
                enabled: _enabled,
                onTap: _enabled ? _show : null,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: _enabled ? _show : null,
                    behavior: HitTestBehavior.opaque,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: WelkFocusRing(
                        visible: _focus && _enabled,
                        shape: shape,
                        color: t.focus,
                        gap: 2,
                        child: CustomPaint(
                          key: _anchor,
                          painter: WelkHardShadowPainter(
                            shape: shape,
                            color: t.shadow,
                            offset: const Offset(3, 3),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              14,
                              12.4,
                              12,
                              12.4,
                            ),
                            decoration: ShapeDecoration(
                              color: t.paper,
                              shape: shape,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selected ?? widget.placeholder,
                                    style: style,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '▼',
                                  style: style.copyWith(fontSize: 11.2),
                                ),
                              ],
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
        ],
      ),
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: widget.overRideDarkMode,
      child: field,
    );
  }
}

class _SelectPopup extends StatefulWidget {
  const _SelectPopup({
    required this.anchor,
    required this.label,
    required this.options,
    required this.value,
    required this.searchable,
    required this.onTraverse,
  });

  final Rect anchor;
  final String label;
  final List<WelkDropDownOption> options;
  final String? value;
  final bool searchable;
  final ValueChanged<bool> onTraverse;

  @override
  State<_SelectPopup> createState() => _SelectPopupState();
}

class _SelectPopupState extends State<_SelectPopup> {
  final _scroll = ScrollController();
  final _keys = <String, GlobalKey>{};
  String _query = '';
  String? _active;
  String? _hovered;
  List<WelkDropDownOption> get _filtered => widget.options
      .where((o) => o.label.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    final enabled = widget.options.where((o) => !o.disabled);
    _active = enabled.any((o) => o.value == widget.value)
        ? widget.value
        : enabled.firstOrNull?.value;
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reveal() {
    if (!mounted) return;
    final context = _keys[_active]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: Duration.zero,
      );
    }
  }

  void _move(int direction, {bool edge = false}) {
    final enabled = _filtered.where((o) => !o.disabled).toList();
    if (enabled.isEmpty) return;
    final i = enabled.indexWhere((o) => o.value == _active);
    setState(() {
      _active =
          enabled[edge
                  ? (direction > 0 ? 0 : enabled.length - 1)
                  : i < 0
                  ? (direction > 0 ? 0 : enabled.length - 1)
                  : (i + direction) % enabled.length]
              .value;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  void _chooseActive() {
    final active = _filtered.where((o) => !o.disabled && o.value == _active);
    if (active.isNotEmpty) Navigator.of(context).pop(active.first.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = WelkTheme.of(context).resolveColors(context);
    final media = MediaQuery.of(context);
    final style = TextStyle(
      fontFamily: t.fontFamily,
      package: t.fontPackage,
      fontSize: 16,
      height: 1.5,
      color: t.ink,
    );
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.circular(9),
        topRight: Radius.circular(14),
        bottomRight: Radius.circular(7),
        bottomLeft: Radius.circular(12),
      ),
      strokeColor: t.outline,
      strokeWidth: t.borderWidth,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final topLimit = media.padding.top + 8;
        final bottomLimit =
            constraints.maxHeight -
            media.viewInsets.bottom -
            math.max(8.0, media.padding.bottom);
        final height = math.min(300.0, math.max(48.0, bottomLimit - topLimit));
        final width = math.min(
          widget.anchor.width,
          constraints.maxWidth - 16.0,
        );
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final left = (rtl ? widget.anchor.right - width : widget.anchor.left)
            .clamp(8.0, math.max(8.0, constraints.maxWidth - width - 8));
        final below = widget.anchor.bottom + 8;
        final top =
            (below + height <= bottomLimit
                    ? below
                    : widget.anchor.top - height - 8)
                .clamp(topLimit, math.max(topLimit, bottomLimit - height));
        return Stack(
          children: [
            Positioned(
              left: left.toDouble(),
              top: top.toDouble(),
              width: width,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                      _move(1),
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                      _move(-1),
                  const SingleActivator(LogicalKeyboardKey.home): () =>
                      _move(1, edge: true),
                  const SingleActivator(LogicalKeyboardKey.end): () =>
                      _move(-1, edge: true),
                  const SingleActivator(LogicalKeyboardKey.enter):
                      _chooseActive,
                  const SingleActivator(LogicalKeyboardKey.escape): () =>
                      Navigator.of(context).pop(),
                  const SingleActivator(LogicalKeyboardKey.tab): () {
                    widget.onTraverse(false);
                    Navigator.of(context).pop();
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.tab,
                    shift: true,
                  ): () {
                    widget.onTraverse(true);
                    Navigator.of(context).pop();
                  },
                },
                child: Focus(
                  autofocus: !widget.searchable,
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    label: widget.label,
                    explicitChildNodes: true,
                    child: CustomPaint(
                      painter: WelkHardShadowPainter(
                        shape: shape,
                        color: t.shadow,
                        offset: const Offset(3, 3),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: height),
                        decoration: ShapeDecoration(
                          color: t.paper,
                          shape: shape,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Material(
                          type: MaterialType.transparency,
                          child: DefaultTextStyle(
                            style: style,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.searchable)
                                  TextField(
                                    autofocus: true,
                                    style: style,
                                    cursorColor: t.ink,
                                    onChanged: (query) => setState(() {
                                      _query = query;
                                      _active = null;
                                    }),
                                    decoration: InputDecoration(
                                      hintText: 'Search ${widget.label}',
                                      hintStyle: t.isDark
                                          ? style.copyWith(
                                              color: t.ink.withValues(
                                                alpha: 0.65,
                                              ),
                                            )
                                          : null,
                                      contentPadding: const EdgeInsets.all(10),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: t.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                Flexible(
                                  child: _filtered.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Semantics(
                                            liveRegion: true,
                                            child: const Text(
                                              'No results found',
                                            ),
                                          ),
                                        )
                                      : SingleChildScrollView(
                                          controller: _scroll,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (final option in _filtered)
                                                _option(option, style, t),
                                            ],
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _option(WelkDropDownOption option, TextStyle style, WelkColors t) {
    final selected = option.value == widget.value;
    final fill = _active == option.value
        ? t.accentHover
        : selected
        ? t.accent
        : _hovered == option.value && !option.disabled
        ? t.accentHover
        : null;
    return Semantics(
      key: _keys.putIfAbsent(option.value, GlobalKey.new),
      selected: selected,
      enabled: !option.disabled,
      child: Opacity(
        opacity: option.disabled ? 0.5 : 1,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = option.value),
          onExit: (_) {
            if (_hovered == option.value) setState(() => _hovered = null);
          },
          child: InkWell(
            canRequestFocus: false,
            onTap: option.disabled
                ? null
                : () => Navigator.of(context).pop(option.value),
            hoverColor: t.accentHover,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(5),
              bottomLeft: Radius.circular(8),
            ),
            child: Ink(
              decoration: BoxDecoration(
                color: _active == option.value
                    ? t.accentHover
                    : selected
                    ? t.accent
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.all(10.4),
                  child: Text(
                    option.label,
                    style: style.copyWith(
                      color: fill == null ? t.ink : t.onFill(fill),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
