import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Allows only sparse, low-amplitude rasterization differences.
bool matchesRasterizationNoise(Uint8List actual, Uint8List expected) {
  if (actual.length != expected.length || actual.length % 4 != 0) return false;
  final pixelCount = actual.length ~/ 4;
  var changedPixels = 0;
  for (var pixel = 0; pixel < actual.length; pixel += 4) {
    var changed = false;
    for (var channel = 0; channel < 4; channel++) {
      final delta = (actual[pixel + channel] - expected[pixel + channel]).abs();
      if (delta > (channel == 3 ? 0 : 16)) return false;
      changed |= delta != 0;
    }
    if (changed) changedPixels++;
    if (changedPixels > pixelCount * 0.0005) return false;
  }
  return true;
}

class RasterizationGoldenComparator extends LocalFileComparator {
  RasterizationGoldenComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final expectedBytes = Uint8List.fromList(await getGoldenBytes(golden));
    final actualCodec = await ui.instantiateImageCodec(imageBytes);
    try {
      final expectedCodec = await ui.instantiateImageCodec(expectedBytes);
      try {
        final actual = (await actualCodec.getNextFrame()).image;
        try {
          final expected = (await expectedCodec.getNextFrame()).image;
          try {
            if (actual.width == expected.width &&
                actual.height == expected.height) {
              final actualData = await actual.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              );
              final expectedData = await expected.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              );
              if (actualData != null &&
                  expectedData != null &&
                  matchesRasterizationNoise(
                    actualData.buffer.asUint8List(),
                    expectedData.buffer.asUint8List(),
                  )) {
                return true;
              }
            }
          } finally {
            expected.dispose();
          }
        } finally {
          actual.dispose();
        }
      } finally {
        expectedCodec.dispose();
      }
    } finally {
      actualCodec.dispose();
    }
    // Preserve Flutter's expected/actual/difference artifacts on real failures.
    return super.compare(imageBytes, golden);
  }
}
