import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        
        child: Container(
          height: double.infinity, // Faz o Container ocupar todo o espaço possível
          width: double.infinity, // Garante que o Container cubra a largura da tela
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFCC00), Color(0xFF336600)], // Cores do degradê
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Image.asset('lib/images/logo-branco.png'))
          ),
        ),
      ),
      
    );
  }
}
