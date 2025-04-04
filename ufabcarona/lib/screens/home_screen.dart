import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'list_rides_screen.dart';
import 'carona_forms.dart';
// import 'criarCarona_Uber.dart';
import 'uber_forms.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bem-vindo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
              radius: 40,
            ),
            const SizedBox(height: 10),
            Text("Olá, ${user.displayName}!"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                Navigator.pop(context);
              },
              child: const Text("Sair"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaronaForms(user: user),
                  ),
                );
              },
              child: Text("Criar Carona"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(                    
                    builder: (context) => UberForms(user: user),
                  ),
                );
              },
              child: Text("Criar Grupo Uber"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListRidesScreen()),
                );
              },
              child: Text("Ver Caronas"),
            ),
          ],
        ),
      ),
    );
  }
}