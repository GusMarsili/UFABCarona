import 'elements_imports.dart';
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

  @override
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

  // Confirma e finaliza a corrida (salva no histórico, atualiza users e deleta o documento)
  Future<void> _finishGroup(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Finalizar Corrida"),
            content: const Text("Deseja encerrar esta corrida?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: const Text(
                  "Finalizar",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final ridesRef = FirebaseFirestore.instance
          .collection('uberGroups')
          .doc(widget.groupId);

      // 1) Recupera os dados atuais da carona
      final snapshot = await ridesRef.get();
      if (snapshot.exists) {
        final rideData = Map<String, dynamic>.from(snapshot.data()!);

        // 2) Adiciona timestamp de finalização e tipo
        rideData['finishedAt'] = FieldValue.serverTimestamp();
        rideData['type'] = "uber";

        // 3) Salva no histórico (rideRecords) com o mesmo ID
        await FirebaseFirestore.instance
            .collection('rideRecords')
            .doc(widget.groupId)
            .set(rideData);

        // 4) Atualiza o array `rideHistory` em cada usuário envolvido
        //    criador + membros
        final List<String> userIds = [
          rideData['creatorId'] as String,
          ...List<String>.from(rideData['members'] ?? <String>[]),
        ];
        for (final uid in userIds) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'rideHistory': FieldValue.arrayUnion([widget.groupId]),
          }, SetOptions(merge: true));
        }
      }

      // 5) Remove a carona original
      await ridesRef.delete();

      // 6) Feedback visual e retorno
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
      builder:
          (context) => AlertDialog(
            title: const Text("Excluir Grupo Uber"),
            content: const Text(
              "Tem certeza que deseja excluir este grupo? Essa ação não pode ser desfeita.",
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text(
                  "Excluir",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.of(context).pop(true),
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
        const SnackBar(content: Text("Grupo Uber excluído com sucesso")),
      );
      Navigator.of(context).pop(); // Volta para a lista
    }
  }

  Widget buttonAction(
    Color colorBackground,
    Color colorText,
    String text,
    Function() onPressed,
    BuildContext context, {
    bool icone = false,
    Icon? icon,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icone ? icon! : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorBackground,
          foregroundColor: colorText,
        ),
        label: Text(text, style: TextStyle(fontSize: 15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarScreen().build(false),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
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
                  "Detalhes do Grupo Uber",
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                UberCardDetail(data: data, members: members).build(),

                // Botões de ação para o criador (editar/deletar)
                if (widget.isOwner)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UberForms(
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
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _deleteUberGroup(context),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 15),
                // Botão Sair (para membro)
                if (!widget.isOwner && isMember)
                  buttonAction(
                    Colors.red,
                    Colors.white,
                    "Sair",
                    () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Confirmar saída'),
                              content: const Text(
                                'Você tem certeza que deseja sair da carona?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Sair'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        final docRef = FirebaseFirestore.instance
                            .collection('uberGroups')
                            .doc(widget.groupId);
                        await docRef.update({
                          'members': FieldValue.arrayRemove([widget.user.uid]),
                        });
                        Navigator.pop(context); // volta pra tela anterior
                      }
                    },
                    context,
                    icone: true,
                    icon: const Icon(Icons.exit_to_app),
                  ),

                // Botão Reservar
                if (!widget.isOwner && !isMember)
                  buttonAction(
                    Color(0xFFFFCC00),
                    Colors.black,
                    "Participar",
                    () async {
                      await FirebaseFirestore.instance
                          .collection('uberGroups')
                          .doc(widget.groupId)
                          .update({
                            'members': FieldValue.arrayUnion([widget.user.uid]),
                          });
                    },
                    context,
                  ),

                // Botão "Começar Corrida" (para o criador)
                if (widget.isOwner && !isRunning)
                  buttonAction(
                    Color(0xFF336600),
                    Colors.white,
                    "Começar Corrida",
                    () => _groupStatus('running'),
                    context,
                  ),

                // Indicador e botões "Finalizar" / "Voltar"
                // TODO: MELHORAR ESSA PARTE DO VISUAL
                if (widget.isOwner && isRunning) ...[
                  const SizedBox(height: 24),
                  Text(
                    "Corrida em Andamento",
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                        onPressed: () => _groupStatus('open'),
                        child: const Text("Voltar"),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                buttonAction(
                  const Color.fromARGB(255, 238, 231, 231),
                  Colors.black,
                  "Voltar",
                  () {
                    Navigator.pop(context);
                  },
                  context,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
