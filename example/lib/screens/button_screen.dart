import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class ButtonScreen extends StatefulWidget {
  const ButtonScreen({super.key});

  @override
  State<ButtonScreen> createState() => _ButtonScreenState();
}

class _ButtonScreenState extends State<ButtonScreen> {
  int _activations = 0;

  void _activate() => setState(() => _activations++);

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkButton',
    children: [
      Text('Button activations: $_activations'),
      const DemoHeading('All variants'),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final variant in WelkButtonVariant.values)
            WelkButton(
              variant: variant,
              size: DemoPage.isCompact(context)
                  ? WelkButtonSize.small
                  : WelkButtonSize.medium,
              onPressed: _activate,
              child: Text(_label(variant.name)),
            ),
        ],
      ),
      const DemoHeading('All sizes'),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final size in WelkButtonSize.values)
            WelkButton(
              size: size,
              onPressed: _activate,
              child: Text(_label(size.name)),
            ),
        ],
      ),
      const DemoHeading('Disabled variants'),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final variant in WelkButtonVariant.values)
            WelkButton(
              variant: variant,
              size: DemoPage.isCompact(context)
                  ? WelkButtonSize.small
                  : WelkButtonSize.medium,
              child: Text(_label(variant.name)),
            ),
        ],
      ),
      const DemoHeading('Custom child'),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WelkButton(
          size: DemoPage.isCompact(context)
              ? WelkButtonSize.small
              : WelkButtonSize.medium,
          onPressed: _activate,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('New item'),
            ],
          ),
        ),
      ),
      const DemoHeading('Long label'),
      WelkButton(
        onPressed: _activate,
        child: const Text(
          'An action label that wraps on narrow mobile screens',
        ),
      ),
      const DemoHeading('Local theme overrides'),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          WelkButton(
            overRideDarkMode: true,
            variant: WelkButtonVariant.secondary,
            onPressed: _activate,
            child: const Text('Always dark'),
          ),
          WelkButton(
            overRideDarkMode: false,
            variant: WelkButtonVariant.secondary,
            onPressed: _activate,
            child: const Text('Always light'),
          ),
        ],
      ),
    ],
  );

  String _label(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
}
