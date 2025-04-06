import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CaronasPage extends StatelessWidget {
  const CaronasPage({super.key, required User user});

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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
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