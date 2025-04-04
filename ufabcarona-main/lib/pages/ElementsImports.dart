import 'package:flutter/material.dart';

class AppBarScreen {
  AppBar build() {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/imgs/logoUFABCarona.png', height: 60),
          SizedBox(width: 1),
          Text(
            "UFABCarona",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
          labelStyle: TextStyle(color: Colors.grey), // Cor da label
          filled: true,
          fillColor: Colors.grey[200], // Cor de fundo do TextField
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Arredondamento da borda
            borderSide: BorderSide.none, // Remove a borda
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