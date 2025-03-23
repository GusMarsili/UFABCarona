import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Realiza o login com o Firebase
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    // Verifica se o email pertence ao domínio permitido
    if (user != null &&
        user.email != null &&
        user.email!.endsWith("@aluno.ufabc.edu.br")) {
      return userCredential;
    } else {
      // Se o email não for permitido, desloga e lança uma exceção
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      throw FirebaseAuthException(
        code: "email-domain-not-allowed",
        message: "Apenas emails institucionais são permitidos.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login com Google")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              UserCredential? user = await signInWithGoogle();
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(user: user.user!)),
                );
              }
            } on FirebaseAuthException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? "Erro de autenticação")),
              );
            }
          },
          child: const Text("Entrar com Google"),
        ),
      ),
    );
  }
}