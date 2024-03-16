import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wilson_campus_scene/services/user.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  WilsonUserStoreService userStoreService = WilsonUserStoreService();
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(forceCodeForRefreshToken: true);

  signInWithGoogle(context) async {
    await _googleSignIn.signOut();

    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      if (googleUser.email.endsWith('@wilsoncollege.edu') ||
          googleUser.email.endsWith('jayg5338@gmail.com')) {
        GoogleSignInAuthentication? googleAuth =
            await googleUser.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        // print(userCredential.user?.displayName);
        await userStoreService.create(
          user: WilsonUser(
            userID: userCredential.user?.uid,
            name: userCredential.user?.displayName,
            email: userCredential.user?.email,
            role: WilsonUserRole.student,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please use your Wilson College email to sign in'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/wilson_logo.png', height: 300),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                color: Colors.black,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/google_logo.png',
                      height: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                onPressed: () => {signInWithGoogle(context)},
              ),
            )
          ]),
    );
  }
}
