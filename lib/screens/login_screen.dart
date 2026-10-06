import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_exception.dart';
import '../design_system/app_button.dart';
import '../design_system/app_text_field.dart';
import '../design_system/design_constants.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final bool sessionExpired;

  const LoginScreen({super.key, this.sessionExpired = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _fieldErrors = const {};
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().login(
            emailController.text.trim(),
            passwordController.text,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _fieldErrors = e.fields;
        _errorMessage = e.fields.isEmpty ? e.userMessage : null;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (widget.sessionExpired)
            TextButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text('Log out'),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DesignConstants.padding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.sessionExpired) ...[
                    Text(
                      'Your session expired. Log in again to continue.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    SizedBox(height: DesignConstants.formFieldSpacing),
                  ],
                  AppTextField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    errorText: _fieldErrors['email'],
                  ),
                  SizedBox(height: DesignConstants.formFieldSpacing),
                  AppTextField(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: _validatePassword,
                    errorText: _fieldErrors['password'],
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: DesignConstants.formFieldSpacing),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  SizedBox(height: DesignConstants.formFieldSpacing * 2),
                  AppButton(
                    isLoading: _isLoading,
                    label: 'Login',
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
