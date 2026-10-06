import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Shows login or home based on [AuthProvider]. When the session expires
/// mid-use, login is pushed on top so the user lands back where they were.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthProvider _auth;
  late AuthStatus _lastStatus;
  Route<void>? _reLoginRoute;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _lastStatus = _auth.status;
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final status = _auth.status;
    final navigator = Navigator.of(context);

    if (status == AuthStatus.sessionExpired && _reLoginRoute == null) {
      final route = MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const PopScope(
          canPop: false,
          child: LoginScreen(sessionExpired: true),
        ),
      );
      _reLoginRoute = route;
      navigator.push(route);
    } else if (status == AuthStatus.signedIn && _reLoginRoute != null) {
      navigator.removeRoute(_reLoginRoute!);
      _reLoginRoute = null;
    } else if (status == AuthStatus.signedOut && _lastStatus != AuthStatus.signedOut) {
      navigator.popUntil((route) => route.isFirst);
      _reLoginRoute = null;
    }
    _lastStatus = status;
  }

  @override
  Widget build(BuildContext context) {
    return switch (context.watch<AuthProvider>().status) {
      AuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.signedOut => const LoginScreen(),
      AuthStatus.signedIn || AuthStatus.sessionExpired => const HomeScreen(),
    };
  }
}
