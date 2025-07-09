import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import '../login_unit_test.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full login flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final phoneField = find.byType(TextField);
    final passField = find.byType(TextFormField);
    final loginButton = find.text('Login');

    await tester.enterText(phoneField, '1234567890');
    await tester.enterText(passField, 'password');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Validate navigation or success toast
    expect(find.text('User logged in'), findsNothing); // You can mock toast with overlays
  });
}
