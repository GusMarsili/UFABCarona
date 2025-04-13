import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'uber_forms.dart';

class UberGroupDetailPage extends StatelessWidget {
  final User user;
  final String groupId;
  final bool isOwner;
  
  const UberGroupDetailPage({
    Key? key,
    required this.user,
    required this.groupId,
    required this.isOwner,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Detalhes do Grupo Uber",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('uberGroups')
            .doc(groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Grupo não encontrado.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          Map<String, dynamic> groupData =
              snapshot.data!.data() as Map<String, dynamic>;
          final String creatorName = groupData['creatorName'] ?? 'N/I';
          final String? creatorPhotoURL = groupData['creatorPhotoURL'];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Destino: ${groupData['destino'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Origem: ${groupData['origem'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Horário: ${groupData['horario'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ponto de Encontro: ${groupData['pontoEncontro'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Exibir os dados do criador salvos no documento:
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: (creatorPhotoURL != null && creatorPhotoURL.isNotEmpty)
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
                // Botão de edição (aparece somente se o usuário for o criador)
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
                            builder: (context) => UberForms(
                              user: user,
                              groupData: groupData,
                              groupId: groupId,
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