import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  int _activations = 0;

  void _activate() => setState(() => _activations++);

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkCard',
    children: [
      Text('Card activations: $_activations'),
      const DemoHeading('Action with icon'),
      WelkCard(
        title: 'Your workspace',
        subtitle: 'Tap to open workspace details.',
        icon: const Icon(Icons.arrow_forward, size: 24),
        onPressed: _activate,
      ),
      const DemoHeading('Action without icon'),
      WelkCard(
        title: 'Quick action',
        subtitle: 'Tap to get started.',
        onPressed: _activate,
      ),
      const DemoHeading('Feedback disabled'),
      WelkCard(
        title: 'No tap animation',
        subtitle: 'An action without tap motion.',
        enableFeedback: false,
        onPressed: _activate,
      ),
      const DemoHeading('Informational'),
      const WelkCard(
        title: 'A useful note',
        subtitle: 'Fully opaque and not announced as a button.',
      ),
      const DemoHeading('Disabled action'),
      WelkCard(
        title: 'Temporarily unavailable',
        subtitle: 'This action is disabled.',
        icon: const Icon(Icons.lock_outline, size: 24),
        enabled: false,
        onPressed: _activate,
      ),
      const DemoHeading('Long content'),
      const WelkCard(
        title:
            'A longer title demonstrates wrapping inside a narrow mobile card',
        subtitle: 'Long supporting copy wraps on small screens and retains the reserved trailing space without overlapping the optional icon.',
        icon: Icon(Icons.notes, size: 24),
      ),
      const DemoHeading('Right to left'),
      const Directionality(
        textDirection: TextDirection.rtl,
        child: WelkCard(
          title: 'Directional layout',
          subtitle: 'The icon follows the trailing edge.',
          icon: Icon(Icons.info_outline, size: 24),
        ),
      ),
    ],
  );
}
