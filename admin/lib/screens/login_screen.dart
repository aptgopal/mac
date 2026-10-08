import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Row(
            children: [
                  if (isWide)
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: const Color(0xFF003580),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_rounded, size: 48, color: Colors.white),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Admin Panel',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lodge Booking Management',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: isWide ? 2 : 1,
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 64 : 24,
                            vertical: 24,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!isWide) ...[
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003580).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.admin_panel_settings_rounded, size: 36, color: Color(0xFF003580)),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                Text(
                                  'Welcome back',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: const Color(0xFF1A1A2E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to manage properties',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          hintText: 'admin@example.com',
                                          prefixIcon: Icon(Icons.email_outlined),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) =>
                                            v != null && v.contains('@') ? null : 'Enter a valid email',
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          hintText: 'Enter your password',
                                          prefixIcon: const Icon(Icons.lock_outlined),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() => _obscurePassword = !_obscurePassword);
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        obscureText: _obscurePassword,
                                        validator: (v) =>
                                            v != null && v.length >= 6 ? null : 'Min 6 characters',
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _loading ? null : _submit,
                                          child: _loading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text('Sign In'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
