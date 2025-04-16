import 'package:flutter/material.dart';

class AppBarScreen {
  AppBar build() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      centerTitle: true,
      title: Row(
      
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/images/logo-degrade.png',
            height: 50,
          ),
          Text(
            "UFABCarona",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TextFieldElement {
  final String labelText;

  TextFieldElement({required this.labelText});

  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ), // Espaçamento interno
        ),
      ),
    );
  }
}
