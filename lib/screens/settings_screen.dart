import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/login.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<AuthUser> _user;

  @override
  void initState() {
    super.initState();
    _user = context.read<ApiClient>().me();
  }

  void _reloadUser() {
    setState(() => _user = context.read<ApiClient>().me());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          FutureBuilder<AuthUser>(
            future: _user,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final error = snapshot.error;
                return ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(error is ApiException ? error.userMessage : 'Could not load your profile.'),
                  trailing: TextButton(onPressed: _reloadUser, child: const Text('Retry')),
                );
              }
              final user = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user?.name ?? 'Loading…'),
                subtitle: user == null ? null : Text(user.email),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }
}
