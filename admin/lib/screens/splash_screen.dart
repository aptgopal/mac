import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF003580))),
          );
        }
        if (snapshot.hasData) {
          Future.microtask(() =>
              Navigator.of(context).pushReplacementNamed('/dashboard'));
        } else {
          Future.microtask(() =>
              Navigator.of(context).pushReplacementNamed('/login'));
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF003580))),
        );
      },
    );
  }
}
