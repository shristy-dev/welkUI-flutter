import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'reference avatar and sticker artwork is packaged and decodable',
    (tester) async {
      await tester.runAsync(() async {
        for (final path in [
          'portraits/male_user.png',
          'portraits/female_user.png',
          'portraits/male_admin.png',
          'portraits/female_admin.png',
          'stickers/superman.png',
          'stickers/batman.png',
        ]) {
          final data = await rootBundle.load(
            'packages/welkui_flutter/assets/$path',
          );
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, greaterThan(0));
          expect(frame.image.height, greaterThan(0));
          frame.image.dispose();
          codec.dispose();
        }
      });
    },
  );
}
