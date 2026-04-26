import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cominsign_new/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        isDarkMode: false,
        language: 'English',
      ),
    );

    // نتأكد إن التطبيق اشتغل
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}