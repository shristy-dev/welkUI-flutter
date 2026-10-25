import 'package:flutter/material.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

import 'demo_page.dart';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) => const DemoPage(
    title: 'WelkQRCode',
    children: [
      DemoHeading('Website'),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WelkQRCode(url: 'https://ui.welkdock.com', size: 160),
      ),
      DemoHeading('Card'),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WelkQRCode(
          url: 'https://ui.welkdock.com/flutter',
          variant: WelkQRCodeVariant.card,
          title: 'Visit WelkUI',
          subtitle: 'Scan to explore the library.',
          cardColor: Color(0xFFFFDA57),
          size: 160,
        ),
      ),
      DemoHeading('Original square code'),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: WelkQRCode(
          url: 'https://ui.welkdock.com',
          originalCode: true,
          size: 160,
        ),
      ),
      DemoHeading('Invalid URL'),
      WelkQRCode(url: 'welkdock.com'),
    ],
  );
}
