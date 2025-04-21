import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'uber_forms.dart';

class UberGroupDetailPage extends StatefulWidget {
  final User user;
  final String groupId;
  final bool isOwner;

  const UberGroupDetailPage({
    super.key,
    required this.user,
    required this.groupId,
    required this.isOwner,
  });

  State<UberGroupDetailPage> createState() => _UberGroupDetailPage();
}

class _UberGroupDetailPage extends State<UberGroupDetailPage> {

  // Muda o status da carona no Firestore
  Future<void> _groupStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('uberGroups')
        .doc(widget.groupId)
        .update({'status': status});
  }

  // Confirma e finaliza a corrida (deleta o documento)
  Future<void> _finishGroup(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Finalizar Corrida"),
        content: const Text("Deseja encerrar esta corrida?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text("Finalizar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('uberGroups')
          .doc(widget.groupId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Corrida finalizada com sucesso!")),
      );
      Navigator.of(context).pop(); // volta para a lista
    }
  }

  // Apresenta um diálogo de confirmação e deleta o documento se confirmado.
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
      await FirebaseFirestore.instance.collection('uberGroups').doc(widget.groupId).delete();
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
            .doc(widget.groupId)
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
          final bool isMember = members.contains(widget.user.uid);
          final bool isRunning = data['status'] == 'running';

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
                // Botão Sair (para membro)
                if (!widget.isOwner && isMember)
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
                            final docRef = FirebaseFirestore.instance.collection('uberGroups').doc(widget.groupId);
                            await docRef.update({
                              'members': FieldValue.arrayRemove([widget.user.uid]),
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
                if (!widget.isOwner && !isMember)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('uberGroups')
                            .doc(widget.groupId)
                            .update({
                          'members': FieldValue.arrayUnion([widget.user.uid]),
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
                // Lista de membros
                if (members.isNotEmpty) ...[
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
                    children: members.map((memberId) {
                      final bool isCurrent = memberId == widget.user.uid;
                      final String label = isCurrent ? 'Você' : memberId;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              isCurrent ? '😊' : memberId.substring(0, 2).toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: GoogleFonts.montserrat(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Botões de ação para o criador (editar/deletar)
                if (widget.isOwner)
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
                                  user: widget.user,
                                  groupData: data,
                                  groupId: widget.groupId,
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
                // Botão "Começar Corrida" (para o criador)
                if (widget.isOwner && !isRunning) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _groupStatus('running'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Começar Corrida"),
                    ),
                  ),
                ],
                // Indicador e botões "Finalizar" / "Voltar"
                if (widget.isOwner && isRunning) ...[
                  const SizedBox(height: 24),
                  Text(
                    "Corrida em andamento",
                    style: GoogleFonts.montserrat(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _finishGroup(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Finalizar Corrida"),
                      ),
                      OutlinedButton(
                        onPressed: () => _groupStatus('not running'),
                        child: const Text("Voltar"),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}