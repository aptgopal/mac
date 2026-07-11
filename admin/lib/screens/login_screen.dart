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
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 56),
                    const SizedBox(height: 8),
                    const Text('Admin Login',
                        style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Admin email'),
                      validator: (v) => v != null && v.contains('@')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration:
                          const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'Min 6 characters',
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: const Text('Login'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
