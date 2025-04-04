
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Suggested code may be subject to a license. Learn more: ~LicenseLog:596667873.

//import 'package:google_fonts/google_fonts.dart';

class CriarPage extends StatelessWidget {
  const CriarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _BodyScreen().build(context),
    );
  }
}


//ARRUMAR
class _BodyScreen {
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
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
            // style: TextStyle(
            //   fontFamily: "Poppins",
            //   fontSize: 24,
            //   color: Colors.black,
            // ),
          ),
          SizedBox(height: heigth * 0.05),
          ButtonElement(
            backgroundColor: Color(0xFFFFCC00),
            foregroundColor: Colors.black,
            text: "Criar carona",
          ).build(context),
          SizedBox(height: heigth * 0.015),
          ButtonElement(
            backgroundColor: Color(0xFF336600),
            foregroundColor: Colors.white,
            text: "Criar Grupo Uber",
          ).build(context),
        ],
      ),
    );
  }
}

class ButtonElement {
  final Color backgroundColor, foregroundColor;
  final String text; //screenDestination;

  ButtonElement({
    //required this.screenDestination,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20), // Bordas arredondadas
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(50, 0, 0, 0), // Cor da sombra
          blurRadius: 3, // Suavidade da sombra
          offset: Offset(0, 4), // Posição da sombra (X, Y)
        ),
      ],
    ),
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.1,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
}


  // Widget build(BuildContext context) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width * 0.8,
  //     height: MediaQuery.of(context).size.height * 0.1,

  //     child: ElevatedButton(
  //       onPressed: () {},
  //       style: ElevatedButton.styleFrom(
  //         foregroundColor: foregroundColor,
  //         backgroundColor: backgroundColor,
  //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //         textStyle: TextStyle(fontSize: 20),
  //       ),
  //       child: Text(
  //         text,
  //         style: GoogleFonts.montserrat(fontSize: 20),
  //         //style: TextStyle(fontFamily: "Poppins", fontSize: 20),
  //       ),
  //     ),
  //   );
  // }
}
