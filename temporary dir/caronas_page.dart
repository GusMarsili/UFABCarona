import 'package:demo/pages/elements_imports.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'carona_detail_page.dart';

class CaronasPage extends StatelessWidget {
  final User user;
  const CaronasPage({super.key, required this.user});

  // Função para deletar uma carona com confirmação
  /*Future<void> _deleteRide(
    DocumentSnapshot document,
    BuildContext context,
  ) async {
    bool confirm = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirmar Deleção"),
            content: const Text("Deseja deletar esta carona?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: const Text("Deletar"),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );
    if (confirm) {
      await document.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carona deletada com sucesso!")),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    CollectionReference rides = FirebaseFirestore.instance.collection('rides');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Grupos Caronas",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: rides.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma carona encontrada.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  // Verifica se a carona foi criada pelo usuário atual
                  bool isOwner = data['creatorId'] == user.uid;
                  return CaronaCard(
                    data: data,
                  ).build(isOwner, user, document.id, context);
                }).toList(),
          );
        },
      ),
    );
  }
}
