import 'package:flutter/material.dart';

import '../preview_mode.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreviewMode.of(context) ? null : AppBar(title: Text(title)),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: children,
      ),
    ),
  );
}

class DemoHeading extends StatelessWidget {
  const DemoHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 16),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
}
