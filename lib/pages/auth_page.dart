import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_image/profile_page.dart';

import 'blogs_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isLogin = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('student_id');
    if (savedId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BlogsPage()),
      );
    }


  }

  Future<void> handleAuth() async {
    String id = idController.text.trim();
    String pass = passController.text.trim();
    String hashedPass = hashPassword(pass);

    if (id.isEmpty || pass.isEmpty) return;

    final supabase = Supabase.instance.client;

    if (isLogin) {
      final response = await supabase
          .from('students_auth')
          .select()
          .eq('student_id', id)
          .eq('password', hashedPass)
          .maybeSingle();

      if (response != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_id', id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BlogsPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid ID or Password")),
        );
      }
    } else {
      await supabase.from('students_auth').insert({
        'student_id': id,
        'password': hashedPass,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful! Please log in.")),
      );
      setState(() {
        isLogin = true;
      });
    }
    passController.clear();
    idController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? 'Login' : 'Signup'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin
                  ? "Don't have an account? Signup"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
