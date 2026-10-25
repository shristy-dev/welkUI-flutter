import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';
import 'welk_icon_button.dart';

enum WelkDrawerPosition { left, right, top, bottom }

/// Opens a modal edge panel with Android back, Escape and focus restoration.
Future<T?> showWelkDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  WelkDrawerPosition position = WelkDrawerPosition.right,
  bool closeOnTapOutside = false,
  bool useRootNavigator = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final reduced = welkAnimationsDisabled(context);
  final offset = switch (position) {
    WelkDrawerPosition.left => const Offset(-1, 0),
    WelkDrawerPosition.right => const Offset(1, 0),
    WelkDrawerPosition.top => const Offset(0, -1),
    WelkDrawerPosition.bottom => const Offset(0, 1),
  };
  return navigator.push<T>(
    _WelkDrawerRoute<T>(
      reduced: reduced,
      barrierDismissible: closeOnTapOutside,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) => themes.wrap(
        SafeArea(
          child: Builder(
            builder: (context) =>
                _DrawerPosition(position: position, child: builder(context)),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (reduced) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: const Cubic(.2, .9, .3, 1.08),
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: offset, end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class _WelkDrawerRoute<T> extends RawDialogRoute<T> {
  _WelkDrawerRoute({
    required bool reduced,
    required super.pageBuilder,
    required super.transitionBuilder,
    required super.barrierDismissible,
    required super.barrierLabel,
  }) : _reduced = reduced,
       super(
         barrierColor: const Color(0x73000000),
         transitionDuration: reduced
             ? Duration.zero
             : const Duration(milliseconds: 320),
         traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
         requestFocus: true,
       );

  final bool _reduced;

  @override
  Duration get reverseTransitionDuration =>
      _reduced ? Duration.zero : const Duration(milliseconds: 200);
}

class _DrawerPosition extends InheritedWidget {
  const _DrawerPosition({required this.position, required super.child});
  final WelkDrawerPosition position;

  @override
  bool updateShouldNotify(_DrawerPosition oldWidget) =>
      oldWidget.position != position;
}

/// A scrollable drawer, normally presented using [showWelkDrawer].
class WelkDrawer extends StatelessWidget {
  const WelkDrawer({
    super.key,
    required this.title,
    required this.child,
    this.position = WelkDrawerPosition.right,
    this.onClose,
    this.closeLabel = 'Close drawer',
  });

  final Widget title;
  final Widget child;
  final WelkDrawerPosition position;
  final VoidCallback? onClose;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context);
    final edge =
        context
            .dependOnInheritedWidgetOfExactType<_DrawerPosition>()
            ?.position ??
        position;
    final horizontal =
        edge == WelkDrawerPosition.left || edge == WelkDrawerPosition.right;
    void close() => (onClose ?? () => Navigator.of(context).pop())();
    final radii = switch (edge) {
      WelkDrawerPosition.left => const WelkCornerRadii(
        topLeft: Radius.zero,
        topRight: Radius.elliptical(16, 12),
        bottomRight: Radius.elliptical(10, 18),
        bottomLeft: Radius.zero,
      ),
      WelkDrawerPosition.right => const WelkCornerRadii(
        topLeft: Radius.elliptical(14, 10),
        topRight: Radius.zero,
        bottomRight: Radius.zero,
        bottomLeft: Radius.elliptical(9, 17),
      ),
      WelkDrawerPosition.top => const WelkCornerRadii(
        topLeft: Radius.zero,
        topRight: Radius.zero,
        bottomRight: Radius.elliptical(16, 10),
        bottomLeft: Radius.elliptical(10, 18),
      ),
      WelkDrawerPosition.bottom => const WelkCornerRadii(
        topLeft: Radius.elliptical(16, 10),
        topRight: Radius.elliptical(10, 18),
        bottomRight: Radius.zero,
        bottomLeft: Radius.zero,
      ),
    };
    final shape = WelkShapeBorder(
      radii: radii,
      strokeColor: theme.ink,
      strokeWidth: theme.borderWidth,
    );
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              close();
              return null;
            },
          ),
        },
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: LayoutBuilder(
            builder: (context, constraints) => Align(
              alignment: switch (edge) {
                WelkDrawerPosition.left => Alignment.centerLeft,
                WelkDrawerPosition.right => Alignment.centerRight,
                WelkDrawerPosition.top => Alignment.topCenter,
                WelkDrawerPosition.bottom => Alignment.bottomCenter,
              },
              child: SizedBox(
                width: horizontal
                    ? math.min(384, math.max(0, constraints.maxWidth - 16))
                    : constraints.maxWidth,
                height: horizontal ? constraints.maxHeight : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: horizontal
                        ? constraints.maxHeight
                        : constraints.maxHeight * .8,
                  ),
                  child: Semantics(
                    scopesRoute: true,
                    explicitChildNodes: true,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        package: theme.fontPackage,
                        fontSize: 16,
                        height: 1.5,
                        color: theme.ink,
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        textStyle: TextStyle(
                          fontFamily: theme.fontFamily,
                          package: theme.fontPackage,
                          fontSize: 16,
                          height: 1.5,
                          color: theme.ink,
                        ),
                        child: CustomPaint(
                          painter: WelkHardShadowPainter(
                            shape: shape,
                            color: theme.ink,
                            offset: const Offset(6, 6),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(theme.borderWidth),
                            decoration: ShapeDecoration(
                              color: theme.paper,
                              shape: shape,
                            ),
                            child: ClipPath(
                              clipper: ShapeBorderClipper(shape: shape),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.accent,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: theme.ink,
                                            width: theme.borderWidth,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Semantics(
                                              namesRoute: true,
                                              header: true,
                                              child: DefaultTextStyle.merge(
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                child: title,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          WelkTheme(
                                            data: theme.copyWith(
                                              accent: theme.paper,
                                              accentHover: theme.muted,
                                            ),
                                            child: WelkIconButton.close(
                                              autofocus: true,
                                              label: closeLabel,
                                              onPressed: close,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: child,
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
            ),
          ),
        ),
      ),
    );
  }
}
