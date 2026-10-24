import 'package:flutter/material.dart';

import '../preview_mode.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 480;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreviewMode.of(context) ? null : AppBar(title: Text(title)),
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          isCompact(context) ? 16 : 20,
          12,
          isCompact(context) ? 16 : 20,
          32,
        ),
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
    padding: EdgeInsets.only(
      top: DemoPage.isCompact(context) ? 18 : 24,
      bottom: DemoPage.isCompact(context) ? 12 : 16,
    ),
    child: Text(
      title,
      style: TextStyle(
        fontSize: DemoPage.isCompact(context) ? 16 : 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
