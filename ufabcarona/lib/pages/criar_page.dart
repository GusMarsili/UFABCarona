import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carona_forms.dart';
import 'uber_forms.dart';

class CriarPage extends StatelessWidget {
  final User user;
  const CriarPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _BodyScreen(user: user).build(context),
    );
  }
}

class _BodyScreen {
  final User user;
  _BodyScreen({required this.user});

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Você Deseja",
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: height * 0.05),
          ButtonElement(
            backgroundColor: const Color(0xFFFFCC00),
            foregroundColor: Colors.black,
            text: "Criar carona",
            screenDestination: CaronaForms(user: user),
          ).build(context),
          SizedBox(height: height * 0.015),
          ButtonElement(
            backgroundColor: const Color(0xFF336600),
            foregroundColor: Colors.white,
            text: "Criar Grupo Uber",
            screenDestination: UberForms(user: user),
          ).build(context),
        ],
      ),
    );
  }
}

class ButtonElement {
  final Color backgroundColor, foregroundColor;
  final String text;
  final Widget screenDestination;

  ButtonElement({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.screenDestination,
  });

  Widget build(BuildContext context) {
    return Container(
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
        height: MediaQuery.of(context).size.height * 0.1,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => screenDestination,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(fontSize: 20),
          ),
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}