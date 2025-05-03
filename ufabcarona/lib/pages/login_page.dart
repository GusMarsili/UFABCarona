import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widget/authgate.dart';

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
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    final User? user = userCredential.user;

    final List<String> extraAllowedEmails = [
      // coloque aqui outros e-mails com acesso
      "gustavo.marsiligm@gmail.com",
      "juliana.braga@ufabc.edu.br",
    ];

    // Verifica se o email pertence ao domínio permitido ou está na whitelist
    if (user != null && user.email != null) {
      final email = user.email!;
      final domainOk = email.endsWith("@aluno.ufabc.edu.br");
      final extraOk = extraAllowedEmails.contains(email);
      if (domainOk || extraOk) {
        return userCredential;
      }
    }
    
    // Se o email não for permitido, desloga e lança uma exceção
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    throw FirebaseAuthException(
      code: "email-domain-not-allowed",
      message: "Apenas emails institucionais são permitidos.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 0, 255, 98), Color(0xFFDAA520)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Image.asset(
                    'lib/images/logo-branco.png',
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Seja Bem Vindo ao',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'UFABCarona!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 50),

                // Botão de Login com Google
                SizedBox(
                  // width: 200,
                  // height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        UserCredential? userCredential =
                            await signInWithGoogle();
                        if (userCredential != null) {
                          // Após login com sucesso, redireciona para a tela principal (AuthGate)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthGate(),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message ?? "Erro de autenticação"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAA00),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Entrar com Google',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}