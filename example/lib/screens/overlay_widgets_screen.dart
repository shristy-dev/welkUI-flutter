import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class DialogScreen extends StatelessWidget {
  const DialogScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkDialog',
    children: [
      const DemoHeading('A little heads-up!'),
      const Text('Paper panels, contextual actions, and a mobile-safe modal.'),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final variant in WelkDialogVariant.values)
            WelkButton(
              onPressed: () => showWelkDialog<void>(
                context: context,
                builder: (_) => WelkDialog(
                  title: Text('${variant.name} adventure'),
                  variant: variant,
                  child: const Text('Your comic adventure continues here.'),
                ),
              ),
              child: Text(variant.name),
            ),
        ],
      ),
      const DemoHeading('Confirmation & custom labels'),
      WelkButton(
        onPressed: () async {
          final confirmed = await showWelkDialog<bool>(
            context: context,
            builder: (dialogContext) => WelkDialog(
              title: const Text('Continue your adventure?'),
              type: WelkDialogType.confirmation,
              yesText: 'Continue',
              noText: 'Go back',
              onYesPressed: () => Navigator.of(dialogContext).pop(true),
              onNoPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Your progress is saved before the next chapter.',
              ),
            ),
          );
          if (context.mounted && confirmed != null) {
            showWelkSnackBar(
              context: context,
              message: Text(
                confirmed ? 'Next chapter unlocked!' : 'Staying here.',
              ),
              autoHideDuration: const Duration(seconds: 3),
            );
          }
        },
        child: const Text('Choose your next chapter'),
      ),
      const DemoHeading('Optional outside dismissal'),
      WelkButton(
        onPressed: () => showWelkDialog<void>(
          context: context,
          closeOnTapOutside: true,
          builder: (_) => const WelkDialog(
            title: Text('Tap outside to close'),
            child: Text('Back and the close action also dismiss this panel.'),
          ),
        ),
        child: const Text('Open dismissible dialog'),
      ),
    ],
  );
}

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkDrawer',
    children: [
      const DemoHeading('Your next adventure'),
      const Text('Choose an edge. Each panel scrolls independently.'),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final position in WelkDrawerPosition.values)
            WelkButton(
              onPressed: () => showWelkDrawer<void>(
                context: context,
                position: position,
                builder: (drawerContext) => WelkDrawer(
                  title: Text('${position.name} mission panel'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Settings, navigation, or mission details.'),
                      const SizedBox(height: 16),
                      WelkButton(
                        onPressed: () => Navigator.of(drawerContext).pop(),
                        child: const Text('Start adventure'),
                      ),
                      const SizedBox(height: 16),
                      for (var chapter = 1; chapter <= 12; chapter++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Chapter $chapter: A heroic tale awaits!',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              child: Text('Open ${position.name}'),
            ),
        ],
      ),
      const DemoHeading('Outside dismissal'),
      WelkButton(
        onPressed: () => showWelkDrawer<void>(
          context: context,
          closeOnTapOutside: true,
          builder: (_) => const WelkDrawer(
            title: Text('Quick notes'),
            child: Text('Tap the backdrop to return to your adventure.'),
          ),
        ),
        child: const Text('Open dismissible drawer'),
      ),
    ],
  );
}

class TooltipScreen extends StatelessWidget {
  const TooltipScreen({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkTooltip',
    children: [
      const DemoHeading('Long press for a little guidance'),
      const Text(
        'Touch and hold, hover with a pointer, or use keyboard focus.',
      ),
      const SizedBox(height: 48),
      Wrap(
        spacing: 24,
        runSpacing: 48,
        children: [
          WelkTooltip(
            content: 'A brilliant idea is brewing…',
            child: WelkButton(
              onPressed: () {},
              child: const Text('Thought bubble'),
            ),
          ),
          WelkTooltip(
            variant: WelkTooltipVariant.speech,
            content: "Let's start the adventure!",
            child: WelkIconButton(
              label: 'Adventure hint',
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () {},
            ),
          ),
        ],
      ),
      const DemoHeading('Wrapping speech'),
      WelkTooltip(
        variant: WelkTooltipVariant.speech,
        content:
            'A longer comic hint wraps to fit the screen, even near its edges.',
        child: WelkButton(
          onPressed: () {},
          child: const Text('Hold for a longer hint'),
        ),
      ),
    ],
  );
}

class SnackBarScreen extends StatefulWidget {
  const SnackBarScreen({super.key});

  @override
  State<SnackBarScreen> createState() => _SnackBarScreenState();
}

class _SnackBarScreenState extends State<SnackBarScreen> {
  WelkSnackBarController? _notification;

  void _show({
    WelkSnackBarVariant variant = WelkSnackBarVariant.standard,
    WelkSnackBarPosition position = WelkSnackBarPosition.bottom,
    bool persistent = false,
    bool longMessage = false,
  }) {
    _notification?.close();
    _notification = showWelkSnackBar(
      context: context,
      variant: variant,
      position: position,
      autoHideDuration: persistent ? Duration.zero : const Duration(seconds: 5),
      message: Text(
        longMessage
            ? 'POW! A comic notification with a longer message wraps naturally '
                  'on smaller screens. Your next adventure is ready to begin.'
            : variant == WelkSnackBarVariant.error
            ? 'OOPS! Something went wrong.'
            : 'POW! Your changes are saved.',
      ),
    );
  }

  @override
  void dispose() {
    _notification?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkSnackBar',
    children: [
      const DemoHeading('Comic notifications'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final variant in WelkSnackBarVariant.values)
            WelkButton(
              onPressed: () => _show(variant: variant),
              child: Text(variant.name),
            ),
        ],
      ),
      const DemoHeading('Top and bottom'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final position in WelkSnackBarPosition.values)
            WelkButton(
              onPressed: () => _show(position: position),
              child: Text(position.name),
            ),
        ],
      ),
      const DemoHeading('Persistent & wrapping'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          WelkButton(
            onPressed: () => _show(persistent: true),
            child: const Text('Keep until dismissed'),
          ),
          WelkButton(
            onPressed: () => _show(longMessage: true),
            child: const Text('Long message'),
          ),
        ],
      ),
    ],
  );
}

class AttachmentScreen extends StatefulWidget {
  const AttachmentScreen({super.key});

  @override
  State<AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<AttachmentScreen> {
  final _form = GlobalKey<FormState>();
  String _selection = 'No files selected.';

  Future<List<WelkAttachmentFile>?> _select({bool single = false}) async {
    final choices = await showWelkDialog<List<String>>(
      context: context,
      builder: (dialogContext) => WelkDialog(
        title: const Text('Choose bundled artwork'),
        buttonText: 'Cancel',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('These are real packaged images. Nothing is uploaded.'),
            const SizedBox(height: 16),
            for (final name in [
              'portraits/male_user.png',
              'stickers/batman.png',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: WelkButton(
                  onPressed: () => Navigator.of(dialogContext).pop([name]),
                  child: Text(name.split('/').last),
                ),
              ),
            if (!single)
              WelkButton(
                onPressed: () => Navigator.of(dialogContext)
                    .pop(['portraits/male_user.png', 'stickers/batman.png']),
                child: const Text('Select both'),
              ),
          ],
        ),
      ),
    );
    if (choices == null) return null;
    return Future.wait(
      choices.map((name) async {
        final path = 'packages/welkui_flutter/assets/$name';
        final bytes = await rootBundle.load(path);
        return WelkAttachmentFile(
          name: name.split('/').last,
          size: bytes.lengthInBytes,
          mimeType: 'image/png',
          preview: Image.asset(path, fit: BoxFit.contain),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkAttachment',
    children: [
      const DemoHeading('App-owned selection, real previews'),
      const Text(
        'This demo chooses packaged artwork. Connect onSelectFiles to your '
        'application’s picker to select device files.',
      ),
      const SizedBox(height: 16),
      WelkAttachment(
        label: const Text('Attach your mission files'),
        onSelectFiles: _select,
        onFilesChange: (files) => setState(
          () => _selection = '${files.length} attachment(s) selected.',
        ),
      ),
      const SizedBox(height: 12),
      Text(_selection),
      const DemoHeading('Limited media'),
      WelkAttachment(
        label: const Text('Up to 3 images or PDFs'),
        accept: 'image/*,.pdf',
        maxFiles: 3,
        maxFileSize: 5 * 1024 * 1024,
        onSelectFiles: _select,
      ),
      const DemoHeading('Single file'),
      WelkAttachment(
        label: const Text('Choose one portrait'),
        multiple: false,
        onSelectFiles: () => _select(single: true),
      ),
      const DemoHeading('Required form field'),
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelkAttachment(
              label: const Text('Artwork is required'),
              isRequired: true,
              onSelectFiles: _select,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                WelkButton(
                  onPressed: () => _form.currentState!.validate(),
                  child: const Text('Validate'),
                ),
                WelkButton(
                  onPressed: () => _form.currentState!.reset(),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
      const DemoHeading('Disabled'),
      WelkAttachment(
        label: const Text('Attachments unavailable'),
        disabled: true,
      ),
    ],
  );
}

class IconButtonScreen extends StatefulWidget {
  const IconButtonScreen({super.key});

  @override
  State<IconButtonScreen> createState() => _IconButtonScreenState();
}

class _IconButtonScreenState extends State<IconButtonScreen> {
  int _items = 0;

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkIconButton',
    children: [
      const DemoHeading('Icon actions'),
      Text('Items added: $_items'),
      const SizedBox(height: 16),
      Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          WelkIconButton(
            label: 'Add item',
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _items++),
          ),
          WelkIconButton(
            label: 'Add item',
            icon: const Icon(Icons.add),
            variant: WelkIconButtonVariant.text,
            onPressed: () => setState(() => _items++),
          ),
        ],
      ),
      const DemoHeading('Disabled variants'),
      const Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          WelkIconButton(label: 'Add item', icon: Icon(Icons.add)),
          WelkIconButton(
            label: 'Add item',
            icon: Icon(Icons.add),
            variant: WelkIconButtonVariant.text,
          ),
        ],
      ),
    ],
  );
}
