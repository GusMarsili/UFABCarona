import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPage extends StatelessWidget {
  final User user;
  const PerfilPage({super.key, required this.user});

  String _getFirstTwoNames(String? fullName) {
  if (fullName == null || fullName.isEmpty) return '';
  List<String> parts = fullName.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0]} ${parts[1]}'; //pega apenas os 2 primeiros nomes do user
  } else {
    return parts[0]; // Retorna só o primeiro se não houver dois
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Perfil",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
              radius: 40,
            ),
            const SizedBox(height: 10),
            Text(
              "Olá, ${_getFirstTwoNames(user.displayName)}!",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(50, 0, 0, 0),
                    blurRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.08,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn().signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text("Sair"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
