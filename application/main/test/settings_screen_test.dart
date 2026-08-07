import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main/screens/settings_screen.dart';

void main() {
  testWidgets('settings ListTiles have a visible Material ancestor',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          darkMode: false,
          onDarkModeChanged: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Dark Mode'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
