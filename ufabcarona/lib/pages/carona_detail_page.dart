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

  /// Apresenta um diálogo de confirmação e deleta o documento se confirmado.
  Future<void> _deleteRide(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
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
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carona deletada com sucesso!")),
      );
      Navigator.of(context).pop(); // volta para a lista
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
              child: Text(
                "Carona não encontrada.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> members = data['members'] ?? [];
          final int vagas = data['vagas'] ?? 0;
          final bool hasSlot = members.length < vagas;
          final bool isMember = members.contains(user.uid);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dados da carona
                Text(
                  "Destino: ${data['destino'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 8),
                Text(
                  "Vagas: $vagas",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Marca do Carro: ${data['marca'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Modelo do Carro: ${data['modelo'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Placa do Carro: ${data['placa'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Valor: R\$ ${data['valor'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Número de Paradas: ${data['paradas'] ?? 'N/I'}",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Informações do criador
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
                if (!isOwner && isMember)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão "Sair"
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar saída'),
                              content: const Text('Você tem certeza que deseja sair da carona?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Sair'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final docRef = FirebaseFirestore.instance.collection('caronas').doc(rideId);
                            await docRef.update({
                              'members': FieldValue.arrayRemove([user.uid]),
                            });
                            Navigator.pop(context); // volta pra tela anterior
                          }
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Sair'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Botão Reservar
                if (!isOwner && !isMember && hasSlot)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('rides')
                            .doc(rideId)
                            .update({
                          'members': FieldValue.arrayUnion([user.uid]),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Reservar"),
                    ),
                  ),
                const SizedBox(height: 24),
                // Lista de membros
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
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(memberId)
                                .get(),
                            builder: (context, snapUser) {
                              Widget avatar;
                              String label;
                              if (isCurrent) {
                                avatar = const CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.person, size: 20),
                                );
                                label = "Você";
                              } else if (snapUser.connectionState == ConnectionState.waiting) {
                                avatar = const CircleAvatar(
                                  radius: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                                label = "";
                              } else if (!snapUser.hasData || !snapUser.data!.exists) {
                                avatar = CircleAvatar(
                                  radius: 20,
                                  child: Text(
                                    memberId.substring(0, 2).toUpperCase(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                                label = memberId;
                              } else {
                                final userData = snapUser.data!.data() as Map<String, dynamic>;
                                final name = userData['displayName'] ?? memberId;
                                final photo = userData['photoURL'] as String? ?? '';
                                avatar = CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      photo.isNotEmpty ? NetworkImage(photo) : null,
                                  child: photo.isEmpty ? Text(
                                    name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontSize: 12),
                                  ) : null,
                                );
                                label = name;
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  avatar,
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    style: GoogleFonts.montserrat(fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                // Botões de ação para o criador
                if (isOwner)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _deleteRide(context),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
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
                                rideData: data,
                                rideId: rideId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}