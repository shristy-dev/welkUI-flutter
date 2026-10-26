import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:welkui_flutter/welkui_flutter.dart';

void main() {
  Future<void> pumpAvatar(
    WidgetTester tester, {
    bool darkMode = false,
    bool? override,
    WelkAvatarVariant variant = WelkAvatarVariant.user,
    Widget? icon,
    ImageProvider? image,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelkTheme(
          data: WelkThemeData(darkMode: darkMode),
          child: Center(
            child: WelkAvatar(
              alt: 'Profile',
              variant: variant,
              overRideDarkMode: override,
              icon: icon,
              image: image,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String assetName(WidgetTester tester) =>
      (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName;

  testWidgets('built-in portraits select white and black theme assets', (
    tester,
  ) async {
    final assets = {
      WelkAvatarVariant.user: ('male_user', 'male_user_white'),
      WelkAvatarVariant.maleUser: ('male_user', 'male_user_white'),
      WelkAvatarVariant.femaleUser: ('female_user', 'female_user_white'),
      WelkAvatarVariant.maleAdmin: ('male_admin', 'male_admin_white'),
      WelkAvatarVariant.femaleAdmin: ('female_admin', 'female_admin_white'),
    };
    for (final entry in assets.entries) {
      await pumpAvatar(tester, darkMode: true, variant: entry.key);
      final image = tester.widget<Image>(find.byType(Image));
      expect(assetName(tester), 'assets/icons/person/${entry.value.$2}.png');
      expect(image.color, isNull);
      expect(find.byType(ColorFiltered), findsNothing);
      await pumpAvatar(tester, variant: entry.key);
      expect(assetName(tester), 'assets/icons/person/${entry.value.$1}.png');
      expect(tester.widget<Image>(find.byType(Image)).color, isNull);
    }
  });

  testWidgets('portrait asset honors local overrides in both directions', (
    tester,
  ) async {
    await pumpAvatar(tester, override: true);
    expect(assetName(tester), 'assets/icons/person/male_user_white.png');
    await pumpAvatar(tester, darkMode: true, override: false);
    expect(assetName(tester), 'assets/icons/person/male_user.png');
  });

  testWidgets('custom icon colors are not filtered in either mode', (
    tester,
  ) async {
    const icon = Icon(Icons.person, color: Colors.black);
    await pumpAvatar(tester, darkMode: true, icon: icon);
    expect(find.byType(ColorFiltered), findsNothing);
    expect(tester.widget<Icon>(find.byIcon(Icons.person)).color, Colors.black);
    await pumpAvatar(tester, icon: icon);
    expect(find.byType(ColorFiltered), findsNothing);
    expect(tester.widget<Icon>(find.byIcon(Icons.person)).color, Colors.black);
  });

  testWidgets('custom profile images keep their original colors', (
    tester,
  ) async {
    await pumpAvatar(
      tester,
      darkMode: true,
      image: const AssetImage(
        'assets/portraits/female_user.png',
        package: 'welkui_flutter',
      ),
    );
    expect(tester.widget<Image>(find.byType(Image)).color, isNull);
    expect(find.byType(ColorFiltered), findsNothing);
  });
}
