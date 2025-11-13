import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthRepo {
  Future<void> login(String email, String pwd) async {
    final user = ParseUser(email, pwd, email);
    final res = await user.login();
    if (!res.success) throw Exception(res.error?.message ?? "Invalid login");
  }

  Future<void> signup(String email, String pwd) async {
    final user = ParseUser(email, pwd, email);
    final res = await user.signUp();
    if (!res.success) throw Exception(res.error?.message ?? "Signup failed");
  }

  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) await user.logout();
  }
}
