import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carona_detail_page.dart';

class CaronasPage extends StatelessWidget {
  final User user;
  const CaronasPage({super.key, required this.user});

  // Função para deletar uma carona com confirmação
  Future<void> _deleteRide(DocumentSnapshot document, BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
  }

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
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
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
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              // Verifica se a carona foi criada pelo usuário atual
              bool isOwner = data['creatorId'] == user.uid;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaronaDetailPage(
                          user: user,              
                          rideId: document.id,
                          isOwner: isOwner,
                        ),
                      ),
                    );
                  },
                  trailing: isOwner
                      ? SizedBox(
                          height: 40,
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                _deleteRide(document, context);
                              },
                            ),
                          ),
                        )
                      : null,
                  title: Text(
                    "Destino: ${data['destino'] ?? 'N/I'}",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Origem: ${data['origem'] ?? 'N/I'}",
                        style: GoogleFonts.montserrat(color: Colors.black87),
                      ),
                      Text(
                        "Horário: ${data['horario'] ?? 'N/I'}",
                        style: GoogleFonts.montserrat(color: Colors.black87),
                      ),
                      Text(
                        "Ponto de Encontro: ${data['pontoEncontro'] ?? 'N/I'}",
                        style: GoogleFonts.montserrat(color: Colors.black87),
                      ),
                      Text(
                        "Valor: R\$ ${data['valor'] ?? 'N/I'}",
                        style: GoogleFonts.montserrat(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}