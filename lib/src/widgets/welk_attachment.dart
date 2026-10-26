import 'package:flutter/material.dart';

import '../painting/welk_focus_ring.dart';
import '../painting/welk_shape_border.dart';
import '../theme/welk_theme.dart';

/// Metadata and an optional app-owned media preview. No upload is performed.
@immutable
class WelkAttachmentFile {
  const WelkAttachmentFile({
    required this.name,
    required this.size,
    this.mimeType = '',
    this.preview,
  }) : assert(size >= 0);

  final String name;
  final int size;
  final String mimeType;

  /// Supply an image or your application's audio/video player.
  final Widget? preview;
}

/// File selection and validation UI, independent of any platform picker.
///
/// [onSelectFiles] invokes the application's picker. Return null to cancel.
/// Accepts comma-separated extensions, MIME types and MIME wildcards.
class WelkAttachment extends FormField<List<WelkAttachmentFile>> {
  WelkAttachment({
    super.key,
    required this.label,
    this.onSelectFiles,
    this.onFilesChange,
    this.multiple = true,
    this.accept,
    this.maxFileSize,
    this.maxFiles,
    this.disabled = false,
    bool isRequired = false,
    List<WelkAttachmentFile> initialFiles = const [],
    FormFieldValidator<List<WelkAttachmentFile>>? validator,
    super.onSaved,
    super.autovalidateMode,
    this.overRideDarkMode,
  }) : assert(maxFileSize == null || maxFileSize > 0),
       assert(maxFiles == null || maxFiles > 0),
       super(
         initialValue: List.unmodifiable(initialFiles),
         enabled: !disabled,
         validator: (files) {
           if (isRequired && (files == null || files.isEmpty)) {
             return 'Choose at least one file.';
           }
           return validator?.call(files);
         },
         builder: (state) => (state as _WelkAttachmentState)._build(),
       );

  final Widget label;
  final Future<List<WelkAttachmentFile>?> Function()? onSelectFiles;
  final ValueChanged<List<WelkAttachmentFile>>? onFilesChange;
  final bool multiple;
  final String? accept;
  final int? maxFileSize;
  final int? maxFiles;
  final bool disabled;

  /// Overrides [WelkThemeData.darkMode] for this widget.
  ///
  /// Null inherits the global preference, falling back to Flutter's [Theme].
  final bool? overRideDarkMode;

  @override
  FormFieldState<List<WelkAttachmentFile>> createState() =>
      _WelkAttachmentState();
}

class _WelkAttachmentState extends FormFieldState<List<WelkAttachmentFile>> {
  String? _selectionError;
  bool _selecting = false;
  int _selectionGeneration = 0;

  WelkAttachment get attachment => widget as WelkAttachment;

  bool _accepts(WelkAttachmentFile file) {
    final accept = attachment.accept;
    if (accept == null || accept.trim().isEmpty) return true;
    return accept.split(',').any((entry) {
      final rule = entry.trim().toLowerCase();
      if (rule.startsWith('.')) {
        return file.name.toLowerCase().endsWith(rule);
      }
      if (rule.endsWith('/*')) {
        return file.mimeType.toLowerCase().startsWith(
          rule.substring(0, rule.length - 1),
        );
      }
      return file.mimeType.toLowerCase() == rule;
    });
  }

  Future<void> _select() async {
    if (_selecting || attachment.disabled || attachment.onSelectFiles == null) {
      return;
    }
    final generation = ++_selectionGeneration;
    setState(() => _selecting = true);
    try {
      final selected = await attachment.onSelectFiles!();
      if (!mounted ||
          generation != _selectionGeneration ||
          attachment.disabled ||
          selected == null) {
        return;
      }
      final limit = attachment.multiple ? attachment.maxFiles : 1;
      String? problem;
      if (limit != null && selected.length > limit) {
        problem = 'Choose no more than $limit file${limit == 1 ? '' : 's'}.';
      } else {
        for (final file in selected) {
          if (attachment.maxFileSize != null &&
              file.size > attachment.maxFileSize!) {
            problem =
                '${file.name} exceeds the ${attachment.maxFileSize}-byte limit.';
            break;
          }
        }
        if (problem == null) {
          for (final file in selected) {
            if (!_accepts(file)) {
              problem = '${file.name} is not an accepted file type.';
              break;
            }
          }
        }
      }
      setState(() => _selectionError = problem);
      final next = List<WelkAttachmentFile>.unmodifiable(
        problem == null ? selected : const [],
      );
      didChange(next);
      attachment.onFilesChange?.call(next);
    } catch (_) {
      if (mounted && generation == _selectionGeneration) {
        setState(() => _selectionError = 'Unable to select files. Try again.');
      }
    } finally {
      if (mounted && generation == _selectionGeneration) {
        setState(() => _selecting = false);
      }
    }
  }

  @override
  void reset() {
    _invalidateSelection();
    super.reset();
    setState(() => _selectionError = null);
  }

  void _invalidateSelection() {
    _selectionGeneration++;
    _selecting = false;
  }

  Widget _build() {
    final theme = WelkTheme.of(context)
        .resolveColors(context, overRideDarkMode: attachment.overRideDarkMode);
    final shape = WelkShapeBorder(
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
      radii: const WelkCornerRadii(
        topLeft: Radius.elliptical(15, 9),
        topRight: Radius.elliptical(8, 17),
        bottomRight: Radius.elliptical(18, 8),
        bottomLeft: Radius.elliptical(10, 14),
      ),
    );
    final error = _selectionError ?? errorText;
    final hint = StringBuffer(
      attachment.multiple ? 'Choose one or more files.' : 'Choose one file.',
    );
    if (attachment.maxFiles != null) {
      hint.write(' Up to ${attachment.maxFiles} files.');
    }
    if (attachment.maxFileSize != null) {
      hint.write(' Maximum ${attachment.maxFileSize} bytes per file.');
    }
    if (attachment.accept != null) {
      hint.write(' Accepted: ${attachment.accept}.');
    }
    final field = DefaultTextStyle(
      style: TextStyle(
        fontFamily: theme.fontFamily,
        package: theme.fontPackage,
        fontSize: 16,
        color: theme.ink,
        height: 1.5,
      ),
      child: CustomPaint(
        painter: WelkHardShadowPainter(
          shape: shape,
          color: theme.shadow,
          offset: const Offset(3, 3),
        ),
        child: Container(
          width: double.infinity,
          decoration: ShapeDecoration(color: theme.paper, shape: shape),
          padding: EdgeInsets.all(16 + theme.borderWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle.merge(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: attachment.label,
              ),
              const SizedBox(height: 12),
              _AttachmentAction(
                onPressed:
                    attachment.disabled ||
                        _selecting ||
                        attachment.onSelectFiles == null
                    ? null
                    : _select,
                label: _selecting
                    ? 'Selecting files…'
                    : attachment.multiple
                    ? 'Choose files'
                    : 'Choose file',
              ),
              const SizedBox(height: 12),
              Text(hint.toString(), style: const TextStyle(fontSize: 12.8)),
              if (error != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.error,
                      border: Border.all(
                        color: theme.outline,
                        width: theme.borderWidth,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(6),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      error,
                      style: TextStyle(
                        fontSize: 12.8,
                        color: theme.onFill(theme.error),
                      ),
                    ),
                  ),
                ),
              ],
              if (value?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Semantics(
                  label: 'Selected files',
                  container: true,
                  explicitChildNodes: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final file in value!)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.muted,
                            border: Border.all(
                              color: theme.outline,
                              width: theme.borderWidth,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(9),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (file.preview != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Semantics(
                                    container: true,
                                    label: 'Preview of ${file.name}',
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            file.mimeType.startsWith('audio/')
                                            ? 256
                                            : 128,
                                        maxHeight:
                                            file.mimeType.startsWith('audio/')
                                            ? 64
                                            : 96,
                                      ),
                                      child: file.preview!,
                                    ),
                                  ),
                                ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Text(file.name),
                                  Text(
                                    '${file.size} bytes',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                _AttachmentAction(
                  onPressed: attachment.disabled
                      ? null
                      : () {
                          _invalidateSelection();
                          setState(() => _selectionError = null);
                          didChange(const []);
                          attachment.onFilesChange?.call(const []);
                        },
                  label: 'Clear attachments',
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return WelkTheme.scope(
      context,
      overRideDarkMode: attachment.overRideDarkMode,
      child: field,
    );
  }
}

class _AttachmentAction extends StatefulWidget {
  const _AttachmentAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<_AttachmentAction> createState() => _AttachmentActionState();
}

class _AttachmentActionState extends State<_AttachmentAction> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = WelkTheme.of(context).resolveColors(context);
    final enabled = widget.onPressed != null;
    final fill = _hovered && enabled ? theme.accentHover : theme.accent;
    final shape = WelkShapeBorder(
      radii: const WelkCornerRadii(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(10),
        bottomLeft: Radius.circular(6),
      ),
      strokeColor: theme.outline,
      strokeWidth: theme.borderWidth,
    );
    return FocusableActionDetector(
      enabled: enabled,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Opacity(
                opacity: enabled ? 1 : .55,
                child: WelkFocusRing(
                  visible: _focused && enabled,
                  color: theme.focus,
                  shape: shape,
                  gap: 3,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 + theme.borderWidth,
                      vertical: 9.6 + theme.borderWidth,
                    ),
                    decoration: ShapeDecoration(color: fill, shape: shape),
                    child: Text(
                      widget.label,
                      style: TextStyle(color: theme.onFill(fill)),
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
