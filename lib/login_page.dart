import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_image/pages/blogs_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              bool isLogged = await login();
              if (isLogged) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => BlogsPage()));
              }
            },
            child: Text(
              "Login With Google",
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> login() async {
    final GoogleSignInAccount? user = await GoogleSignIn().signIn();
    GoogleSignInAuthentication userAuth = await user!.authentication;

    // if (user == null) {
    //   return null;
    // }
    final credential = GoogleAuthProvider.credential(
      accessToken: userAuth.accessToken,
      idToken: userAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    return FirebaseAuth.instance.currentUser != null;
  }
}

// Function to handle the Google Sign-In process
// Future<UserCredential?> signInWithGoogle() async {
//   try {
//     // Trigger the authentication flow
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//     // If the user cancelled the sign-in, googleUser will be null
//     if (googleUser == null) {
//       return null;
//     }
//
//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication googleAuth =
//     await googleUser.authentication;
//
//     // Create a new credential for Firebase
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//
//     // Sign in to Firebase with the Google credential
//     return await FirebaseAuth.instance.signInWithCredential(credential);
//   } catch (e) {
//     // Handle errors here (e.g., network issues, configuration problems)
//     print("Error during Google Sign-In: $e");
//     return null; // Or rethrow the error, depending on your needs
//   }
// }
