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

  test(
    'catalog allowance accepts measured CI noise but rejects its boundary',
    () {
      final expected = Uint8List(360 * 740 * 4);
      for (final count in [141, 144, 362, 399, 400]) {
        final actual = Uint8List.fromList(expected);
        for (var pixel = 0; pixel < count; pixel++) {
          actual[pixel * 4] = 14;
        }
        expect(matchesRasterizationNoise(actual, expected), isFalse);
        expect(
          matchesRasterizationNoise(
            actual,
            expected,
            maxChangedPixelFraction: 0.0015,
          ),
          count <= 399,
        );
      }
    },
  );

  test('catalog allowance retains strict RGB, alpha, and length limits', () {
    final expected = Uint8List(2000 * 4);
    for (final channel in [0, 1, 2, 3]) {
      final actual = Uint8List.fromList(expected)
        ..[channel] = channel == 3 ? 1 : 17;
      expect(
        matchesRasterizationNoise(
          actual,
          expected,
          maxChangedPixelFraction: 0.0015,
        ),
        isFalse,
      );
    }
    expect(
      matchesRasterizationNoise(
        Uint8List(4),
        expected,
        maxChangedPixelFraction: 0.0015,
      ),
      isFalse,
    );
  });

  test('rejects invalid changed-pixel allowances', () {
    for (final fraction in [-0.1, 1.1, double.nan, double.infinity]) {
      expect(
        () => matchesRasterizationNoise(
          Uint8List(4),
          Uint8List(4),
          maxChangedPixelFraction: fraction,
        ),
        throwsArgumentError,
      );
    }
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
