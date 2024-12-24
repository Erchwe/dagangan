import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<void> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        print('Login berhasil!');
      } else {
        throw Exception('Login gagal: Kredensial salah atau akun belum diverifikasi.');
      }
    } catch (e) {
      print('Login gagal: $e');
      throw Exception('Login gagal: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      print('Logout berhasil!');
    } catch (e) {
      print('Logout gagal: $e');
      throw Exception('Logout gagal: $e');
    }
  }
}
