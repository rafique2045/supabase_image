import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_image/pages/auth_page.dart';
import 'package:supabase_image/pages/blogs_page.dart';
import 'package:supabase_image/login_page.dart';
import 'package:supabase_image/test_hash.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://nebmyulcbqmsmjcackym.supabase.co',
    anonKey:
        'xeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lYm15dWxjYnFtc21qY2Fja3ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyNzQyMTYsImV4cCI6MjA2MTg1MDIxNn0.24ne9tUSEC-vEhkh2ieY0wxTTV9QbNQeJVbyat5NrjQ',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),

      // FirebaseAuth.instance.currentUser != null
      //     ? UploadPage()
      //     : LoginPage(),
    );
  }
}

/***************************** */
