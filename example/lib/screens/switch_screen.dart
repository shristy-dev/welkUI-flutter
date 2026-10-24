import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool _notifications = true;
  bool _summary = false;
  bool _longLabel = false;
  bool _rtl = true;

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'WelkSwitch',
    children: [
      const DemoHeading('On and off'),
      WelkSwitch(
        value: _notifications,
        label: 'Notifications',
        onChanged: (value) => setState(() => _notifications = value),
      ),
      Text('Notifications: ${_notifications ? 'on' : 'off'}'),
      const SizedBox(height: 16),
      WelkSwitch(
        value: _summary,
        label: 'Weekly summary',
        onChanged: (value) => setState(() => _summary = value),
      ),
      Text('Weekly summary: ${_summary ? 'on' : 'off'}'),
      const DemoHeading('Disabled states'),
      const WelkSwitch(value: true, label: 'Disabled on'),
      const SizedBox(height: 8),
      const WelkSwitch(value: false, label: 'Disabled off'),
      const DemoHeading('Long label'),
      WelkSwitch(
        value: _longLabel,
        label: 'Send helpful updates about the workspace and its members',
        onChanged: (value) => setState(() => _longLabel = value),
      ),
      const DemoHeading('Right to left'),
      Directionality(
        textDirection: TextDirection.rtl,
        child: WelkSwitch(
          value: _rtl,
          label: 'Right-to-left layout',
          onChanged: (value) => setState(() => _rtl = value),
        ),
      ),
    ],
  );
}
