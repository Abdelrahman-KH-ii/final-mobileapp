import 'package:farmtec/features/auth/presentation/widgets/login_body.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String routeName = "login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginBody());
  }
}
