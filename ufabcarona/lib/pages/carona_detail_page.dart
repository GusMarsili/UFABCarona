import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carona_forms.dart';

class CaronaDetailPage extends StatelessWidget {
  final User user;
  final String rideId;
  final bool isOwner;
  
  const CaronaDetailPage({
    super.key,
    required this.user,
    required this.rideId,
    required this.isOwner,
  });
  
  @override
  Widget build(BuildContext context) {
    // Agora, usamos um StreamBuilder para escutar o documento em tempo real.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Detalhes da Carona",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Carona não encontrada.", style: TextStyle(color: Colors.black)),
            );
          }
          
          Map<String, dynamic> rideData = snapshot.data!.data() as Map<String, dynamic>;
          final String creatorName = rideData['creatorName'] ?? 'N/I';
          final String? creatorPhotoURL = rideData['creatorPhotoURL'];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dados da carona
                Text(
                  "Destino: ${rideData['destino'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Origem: ${rideData['origem'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Horário: ${rideData['horario'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ponto de Encontro: ${rideData['pontoEncontro'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vagas: ${rideData['vagas'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Marca do Carro: ${rideData['marca'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Modelo do Carro: ${rideData['modelo'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Placa do Carro: ${rideData['placa'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Valor: R\$ ${rideData['valor'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Número de Paradas: ${rideData['paradas'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Informações do criador
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: creatorPhotoURL != null && creatorPhotoURL.isNotEmpty
                          ? NetworkImage(creatorPhotoURL)
                          : null,
                      radius: 20,
                      child: (creatorPhotoURL == null || creatorPhotoURL.isEmpty)
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Criador: $creatorName",
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Botão de edição (exibido apenas se o usuário for o criador)
                if (isOwner)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaronaForms(
                              user: user,
                              rideData: rideData,
                              rideId: rideId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}