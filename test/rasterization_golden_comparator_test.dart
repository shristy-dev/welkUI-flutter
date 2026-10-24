import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'support/rasterization_golden_comparator.dart';

void main() {
  test('accepts identical images and sparse low-amplitude RGB differences', () {
    final expected = Uint8List(2000 * 4);
    expect(matchesRasterizationNoise(expected, expected), isTrue);
    final actual = Uint8List.fromList(expected)..[0] = 16;
    expect(matchesRasterizationNoise(actual, expected), isTrue);
  });

  test('rejects excessive changed pixels even with tiny channel changes', () {
    final expected = Uint8List(2000 * 4);
    final actual = Uint8List.fromList(expected)
      ..[0] = 1
      ..[4] = 1;
    expect(matchesRasterizationNoise(actual, expected), isFalse);
  });

  test('rejects large channel changes, alpha changes, and size changes', () {
    final expected = Uint8List(2000 * 4);
    expect(
      matchesRasterizationNoise(
        Uint8List.fromList(expected)..[0] = 17,
        expected,
      ),
      isFalse,
    );
    expect(
      matchesRasterizationNoise(
        Uint8List.fromList(expected)..[3] = 1,
        expected,
      ),
      isFalse,
    );
    expect(matchesRasterizationNoise(Uint8List(4), expected), isFalse);
  });
}
