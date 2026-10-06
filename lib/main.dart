import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/api_client.dart';
import 'api/token_storage.dart';
import 'design_system/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_gate.dart';
import 'utils/constants.dart';

void main() {
  final apiClient = ApiClient(
    baseUrl: Constants.baseUrl,
    tokenStorage: SharedPrefsTokenStorage(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(apiClient)..restoreSession(),
        ),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      extensions: [AppColors.fromScheme(scheme)],
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: context.watch<ThemeProvider>().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}
