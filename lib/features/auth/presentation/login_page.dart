import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  void showRootSnack(String msg) {
    Future.delayed(const Duration(milliseconds: 60), () {
      ScaffoldMessenger.of(
        Navigator.of(context).overlay!.context,
      ).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final username = email.text.trim();
      final pwd = password.text.trim();
      final user = ParseUser(username, pwd, username);
      final res = await user.login();

      if (res.success) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/tasks');
      } else {
        showRootSnack(res.error?.message ?? "Invalid email/password");
      }
    } catch (e) {
      showRootSnack("Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> signup() async {
    setState(() => loading = true);
    try {
      final user = ParseUser(
        email.text.trim(),
        password.text.trim(),
        email.text.trim(),
      );
      final res = await user.signUp();

      if (res.success) {
        showRootSnack("Account created. Now login.");
      } else {
        showRootSnack(res.error?.message ?? "Sign up failed");
      }
    } catch (e) {
      showRootSnack("Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetPassword() async {
    setState(() => loading = true);
    try {
      if (email.text.trim().isEmpty) {
        showRootSnack("Enter your email first.");
        return;
      }
      final res = await ParseUser(null, null, email.text.trim())
          .requestPasswordReset();

      if (res.success) {
        showRootSnack("Password reset link sent!");
      } else {
        showRootSnack(res.error?.message ?? "Failed");
      }
    } catch (e) {
      showRootSnack("Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Login"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.lock_shield,
                  size: 64, color: CupertinoColors.activeBlue),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: email,
                placeholder: "Email",
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(CupertinoIcons.mail),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: password,
                placeholder: "Password",
                obscureText: true,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(CupertinoIcons.lock),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: loading ? null : login,
                child: loading
                    ? const CupertinoActivityIndicator()
                    : const Text("Login"),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: loading ? null : signup,
                child: const Text("Sign Up"),
              ),
              CupertinoButton(
                onPressed: loading ? null : resetPassword,
                child: const Text("Forgot Password?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
