import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class ReportarPage extends StatelessWidget {
  const ReportarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportar Usuário"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(IconlyBold.setting, color: Colors.grey, size: 100),
          const SizedBox(height: 10),
          Text(
            "Página em Manutenção",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Em breve, você poderá reportar usuários diretamente por aqui.",
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        ),
      ),
    );
  }
}
