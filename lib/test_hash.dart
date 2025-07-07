import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';


class TestHash extends StatefulWidget {
  const TestHash({super.key});

  @override
  State<TestHash> createState() => _TestHashState();
}

class _TestHashState extends State<TestHash> {
  TextEditingController studentIdController = TextEditingController();
  TextEditingController studentPassController = TextEditingController();

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  Future<void> signUpWithSupabase(String id, String password) async {
    String hashed = hashPassword(password);

    final response = await Supabase.instance.client
        .from('students')
        .insert({
      'student_id': id,
      'password': hashed,
    })
        .select();

    print("✅ Signup complete");
  }
  Future<void> loginWithSupabase(String id, String password) async {
    String hashed = hashPassword(password); // hash the entered password

    final response = await Supabase.instance.client
        .from('students')
        .select()
        .eq('student_id', id)
        .eq('password', hashed)
        .maybeSingle();

    if (response != null) {
      print("✅ Login Successful");
      print("Welcome ${response}");
    } else {
      print("❌ Invalid ID or Password");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: studentIdController,
              decoration: InputDecoration(
                labelText: 'Student ID',
              ),
            ),
            TextField(
              controller: studentPassController,
              decoration: InputDecoration(
                labelText: 'password',
              ),
            ),
      
            ElevatedButton(
              onPressed: () async{
                String studentId = studentIdController.text.toString().trim();
                String studentPass = studentPassController.text.toString().trim();

               await loginWithSupabase(studentId, studentPass);

               },
              child: Text('Login'),

            ),

            ElevatedButton(
              onPressed: () async{
                String studentId = studentIdController.text.toString().trim();
                String studentPass = studentPassController.text.toString().trim();

                await signUpWithSupabase(studentId, studentId);

              },
              child: Text('Signup'),

            ),
          ],
        ),
      ),
    );
  }
}
