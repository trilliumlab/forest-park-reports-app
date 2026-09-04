import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/model/onboarding.dart';
import 'package:forest_park_reports/page/common/alert_banner.dart';
import 'package:forest_park_reports/provider/auth_provider.dart';
import 'package:forest_park_reports/provider/onboarding_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// First-launch page asking for basic account info and account tier.
/// Can be skipped, in which case the user stays on tier 1 (no account).
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AccountTier _tier = AccountTier.hiker;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _skip() {
    ref.read(onboardingProvider.notifier).complete(null);
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).signUp(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            tier: _tier,
          );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAlertBanner(
        key: const Key("signup-error"),
        color: Colors.red,
        child: Text(signUpErrorMessage(e)),
      );
      return;
    }

    await ref.read(onboardingProvider.notifier).complete(_tier);
    if (!mounted) return;
    showAlertBanner(
      key: const Key("signup-verify-email"),
      color: Colors.grey,
      child: const Text("Check your email to verify your account"),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome to Trail Eyes",
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Create an account to help us track who's reporting hazards, "
                  "or skip for now and report anonymously.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "Enter your name"
                      : null,
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => (value == null || value.length < 8)
                      ? "Password must be at least 8 characters"
                      : null,
                ),
                const SizedBox(height: 24),
                Text("Account Type", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...AccountTier.values.map(
                  (tier) => RadioListTile<AccountTier>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tier.displayName),
                    subtitle: Text(switch (tier) {
                      AccountTier.hiker =>
                        "For everyday trail users reporting hazards",
                      AccountTier.staff =>
                        "For Forest Park Conservancy staff",
                    }),
                    value: tier,
                    groupValue: _tier,
                    onChanged: (value) => setState(() => _tier = value!),
                  ),
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
                      : const Text("Create Account"),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _submitting ? null : _skip,
                  child: const Text("Skip for now"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
