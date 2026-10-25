import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_icon_button.dart';

enum WelkSnackBarVariant { standard, info, success, warning, error }

enum WelkSnackBarPosition { top, bottom }

/// Handle for dismissing an overlay notification without a modal route.
class WelkSnackBarController {
  WelkSnackBarController._(this.close, this.closed);
  final VoidCallback close;
  final Future<void> closed;
}

/// Shows a non-modal notification above content and the on-screen keyboard.
WelkSnackBarController showWelkSnackBar({
  required BuildContext context,
  required Widget message,
  WelkSnackBarVariant variant = WelkSnackBarVariant.standard,
  WelkSnackBarPosition position = WelkSnackBarPosition.bottom,
  Duration autoHideDuration = Duration.zero,
  String closeLabel = 'Dismiss notification',
}) {
  assert(!autoHideDuration.isNegative);
  final key = GlobalKey<_SnackOverlayState>();
  final overlay = Overlay.of(context, rootOverlay: true);
  final themes = InheritedTheme.capture(from: context, to: overlay.context);
  final reduced = welkAnimationsDisabled(context);
  final completion = Completer<void>();
  var closing = false;
  var finalized = false;
  late OverlayEntry entry;
  void remove() {
    if (finalized) return;
    finalized = true;
    closing = true;
    // Owner teardown can call this while the widget tree is locked.
    scheduleMicrotask(() {
      try {
        entry.remove();
        entry.dispose();
      } finally {
        if (!completion.isCompleted) completion.complete();
      }
    });
  }

  void close() {
    if (closing) return;
    closing = true;
    if (key.currentState == null) {
      remove();
    } else {
      key.currentState!.close();
    }
  }

  entry = OverlayEntry(
    builder: (overlayContext) => themes.wrap(
      _SnackOverlay(
        key: key,
        reduced: reduced,
        position: position,
        onRemoved: remove,
        child: MediaQuery(
          data: MediaQuery.of(overlayContext)
              .copyWith(disableAnimations: reduced),
          child: WelkSnackBar(
            message: message,
            variant: variant,
            autoHideDuration: autoHideDuration,
            closeLabel: closeLabel,
            onClose: close,
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  return WelkSnackBarController._(close, completion.future);
}

/// An inline notification surface. Use [showWelkSnackBar] for overlay placement.
class WelkSnackBar extends StatefulWidget {
  WelkSnackBar({
    super.key,
    required this.message,
    required this.onClose,
    this.variant = WelkSnackBarVariant.standard,
    this.autoHideDuration = Duration.zero,
    this.closeLabel = 'Dismiss notification',
  }) : assert(!autoHideDuration.isNegative);

  final Widget message;
  final VoidCallback onClose;
  final WelkSnackBarVariant variant;
  final Duration autoHideDuration;
  final String closeLabel;

  @override
  State<WelkSnackBar> createState() => _WelkSnackBarState();
}

class _WelkSnackBarState extends State<WelkSnackBar> {
  Timer? _timer;
  bool _hovered = false;
  bool _focused = false;

  void _restartTimer() {
    _timer?.cancel();
    if (_hovered ||
        _focused ||
        widget.autoHideDuration == Duration.zero ||
        MediaQuery.accessibleNavigationOf(context)) {
      return;
    }
    _timer = Timer(widget.autoHideDuration, () => widget.onClose());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartTimer();
  }

  @override
  void didUpdateWidget(WelkSnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoHideDuration != widget.autoHideDuration) _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final color = switch (widget.variant) {
      WelkSnackBarVariant.standard => theme.accent,
      WelkSnackBarVariant.info => theme.info,
      WelkSnackBarVariant.success => theme.success,
      WelkSnackBarVariant.warning => theme.warning,
      WelkSnackBarVariant.error => theme.error,
    };
    final shape = WelkShapeBorder(
      strokeColor: theme.ink,
      strokeWidth: 3,
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(16, 10),
        topRight: Radius.elliptical(8, 16),
        bottomRight: Radius.elliptical(18, 8),
        bottomLeft: Radius.elliptical(10, 14),
      ),
    );
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              widget.onClose();
              return null;
            },
          ),
        },
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (value) {
            _focused = value;
            _restartTimer();
          },
          child: MouseRegion(
            onEnter: (_) {
              _hovered = true;
              _restartTimer();
            },
            onExit: (_) {
              _hovered = false;
              _restartTimer();
            },
            child: Transform.rotate(
              angle: welkAnimationsDisabled(context) ? 0 : -math.pi / 180,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CustomPaint(
                  painter: WelkHardShadowPainter(
                    shape: shape,
                    color: theme.ink,
                    offset: const Offset(5, 5),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(19, 15, 15, 15),
                    decoration: ShapeDecoration(color: color, shape: shape),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(40, 40),
                          painter: _BurstPainter(
                            ink: theme.ink,
                            paper: theme.paper,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Semantics(
                            liveRegion: true,
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontFamily: theme.fontFamily,
                                package: theme.fontPackage,
                                color: theme.ink,
                                fontSize: 15.2,
                                height: 1.5,
                              ),
                              child: widget.message,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        WelkTheme(
                          data: theme.copyWith(
                            accent: theme.paper,
                            accentHover: theme.muted,
                          ),
                          child: WelkIconButton.close(
                            label: widget.closeLabel,
                            onPressed: widget.onClose,
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
    );
  }
}

class _SnackOverlay extends StatefulWidget {
  const _SnackOverlay({
    super.key,
    required this.position,
    required this.onRemoved,
    required this.child,
    required this.reduced,
  });

  final WelkSnackBarPosition position;
  final VoidCallback onRemoved;
  final Widget child;
  final bool reduced;

  @override
  State<_SnackOverlay> createState() => _SnackOverlayState();
}

class _SnackOverlayState extends State<_SnackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 200),
  );
  bool _started = false;
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (widget.reduced) {
        _animation.value = 1;
      } else {
        _animation.forward();
      }
    }
  }

  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    setState(() {});
    if (!widget.reduced) {
      await _animation.reverse().orCancel.catchError((Object _) {});
    }
    if (mounted) widget.onRemoved();
  }

  @override
  void dispose() {
    _animation.dispose();
    widget.onRemoved();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = switch (widget.position) {
      WelkSnackBarPosition.top => Alignment.topCenter,
      WelkSnackBarPosition.bottom => Alignment.bottomCenter,
    };
    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Align(
          alignment: alignment,
          child: IgnorePointer(
            ignoring: _closing,
            child: ExcludeSemantics(
              excluding: _closing,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  if (widget.reduced) return child!;
                  final t = Curves.easeOutBack.transform(_animation.value);
                  return Opacity(
                    opacity: _animation.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * (alignment.y < 0 ? -32 : 32)),
                      child: Transform.rotate(
                        angle: (1 - t) * -7 * math.pi / 180,
                        child: Transform.scale(
                          scaleX: .65 + .35 * t,
                          scaleY: .8 + .2 * t,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.ink, required this.paper});
  final Color ink;
  final Color paper;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 32, size.height / 32);
    final burst = Path()
      ..moveTo(17, 1)
      ..lineTo(19, 10)
      ..lineTo(28, 5)
      ..lineTo(24, 15)
      ..lineTo(31, 19)
      ..lineTo(20, 21)
      ..lineTo(19, 31)
      ..lineTo(13, 23)
      ..lineTo(2, 27)
      ..lineTo(7, 17)
      ..lineTo(1, 10)
      ..lineTo(12, 11)
      ..close();
    canvas.drawPath(burst, Paint()..color = paper);
    canvas.drawPath(
      burst,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    final bolt = Path()
      ..moveTo(17, 8)
      ..lineTo(11, 18)
      ..lineTo(16, 18)
      ..lineTo(15, 25)
      ..lineTo(22, 13)
      ..lineTo(16, 13)
      ..close();
    canvas.drawPath(bolt, Paint()..color = ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      ink != oldDelegate.ink || paper != oldDelegate.paper;
}
