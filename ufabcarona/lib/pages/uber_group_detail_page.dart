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
    super.key,
    required this.user,
    required this.groupId,
    required this.isOwner,
  });

  Future<void> _deleteUberGroup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Grupo Uber"),
        content: const Text("Tem certeza que deseja excluir este grupo? Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('uberGroups').doc(groupId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Grupo Uber excluído com sucesso")),
      );
      Navigator.of(context).pop(); // Volta para a lista
    }
  }

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
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> members = data['members'] ?? [];
          final bool isMember = members.contains(user.uid);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Destino: ${data['destino'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Origem: ${data['origem'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Horário: ${data['horario'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ponto de Encontro: ${data['pontoEncontro'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: (data['creatorPhotoURL'] ?? '').isNotEmpty
                          ? NetworkImage(data['creatorPhotoURL'])
                          : null,
                      radius: 20,
                      child: (data['creatorPhotoURL'] ?? '').isEmpty
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Criador: ${data['creatorName'] ?? 'N/I'}",
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (!isOwner && !isMember)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('uberGroups')
                            .doc(groupId)
                            .update({
                          'members': FieldValue.arrayUnion([user.uid]),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF336600),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Reservar"),
                    ),
                  ),
                const SizedBox(height: 24),
                if (members.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Membros:",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: members.map<Widget>((memberId) {
                          final bool isCurrent = memberId == user.uid;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                child: Text(
                                  isCurrent ? 'Você' : memberId.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCurrent ? 'Você' : memberId,
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                if (isOwner)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UberForms(
                                  user: user,
                                  groupData: data,
                                  groupId: groupId,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteUberGroup(context),
                        ),
                      ],
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