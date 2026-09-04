import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/common/alert_banner.dart';
import 'package:forest_park_reports/provider/auth_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Lets a user with an existing, verified account establish a session in
/// the app (e.g. after verifying their email via the link sent at signup).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAlertBanner(
        key: const Key("login-error"),
        color: Colors.red,
        child: Text(authErrorMessage(e)),
      );
      return;
    }

    if (!mounted) return;
    showAlertBanner(
      key: const Key("login-success"),
      color: Colors.green,
      child: const Text("Logged in"),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Log in to your account",
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "You'll need to verify your email (check the link we sent "
                  "when you signed up) before you can log in.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter your email";
                    }
                    if (!value.contains("@")) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Enter your password"
                      : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Log In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
