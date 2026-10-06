import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_fund/api/api_client.dart';
import 'package:flutter_fund/api/token_storage.dart';
import 'package:flutter_fund/providers/auth_provider.dart';
import 'package:flutter_fund/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Future<AuthProvider> pumpLogin(WidgetTester tester, MockClient client) async {
  final auth = AuthProvider(ApiClient(
    baseUrl: 'http://test',
    tokenStorage: InMemoryTokenStorage(),
    httpClient: client,
  ));
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: auth,
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  return auth;
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('validates email and password before calling the server', (tester) async {
    var calls = 0;
    await pumpLogin(tester, MockClient((_) async {
      calls++;
      return http.Response('{}', 500);
    }));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('shows the server message for wrong credentials', (tester) async {
    final auth = await pumpLogin(tester, MockClient((_) async => http.Response(
          jsonEncode({
            'error': {'code': 'invalid_credentials', 'message': 'Email or password is incorrect.'},
          }),
          401,
        )));

    await tester.enterText(field('Email'), 'demo@flutterfund.test');
    await tester.enterText(field('Password'), 'wrong');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(auth.status, isNot(AuthStatus.signedIn));
  });

  testWidgets('a successful login signs the user in', (tester) async {
    final auth = await pumpLogin(tester, MockClient((_) async => http.Response(
          jsonEncode({
            'accessToken': 'a',
            'refreshToken': 'r',
            'expiresIn': 20,
            'user': {'id': 'u1', 'name': 'Demo Saver', 'email': 'demo@flutterfund.test'},
          }),
          200,
        )));

    await tester.enterText(field('Email'), 'demo@flutterfund.test');
    await tester.enterText(field('Password'), 'Passw0rd!');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(auth.status, AuthStatus.signedIn);
    expect(auth.user?.name, 'Demo Saver');
  });
}
