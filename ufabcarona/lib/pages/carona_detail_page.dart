import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufabcarona/pages/elements_imports.dart';
import 'carona_forms.dart';

class CaronaDetailPage extends StatefulWidget {
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
  State<CaronaDetailPage> createState() => _CaronaDetailPageState();
}

class _CaronaDetailPageState extends State<CaronaDetailPage> {

  // Muda o status da carona no Firestore
  Future<void> _rideStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.rideId)
        .update({'status': status});
  }

  // Confirma e finaliza a corrida (salva no histórico, atualiza users e deleta o documento)
  Future<void> _finishRide(BuildContext context) async {
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
      final ridesRef = FirebaseFirestore.instance.collection('rides').doc(widget.rideId);

      // 1) Recupera os dados atuais da carona
      final snapshot = await ridesRef.get();
      if (snapshot.exists) {
        final rideData = Map<String, dynamic>.from(snapshot.data()!);

        // 2) Adiciona timestamp de finalização e tipo
        rideData['finishedAt'] = FieldValue.serverTimestamp();
        rideData['type'] = "carona";

        // 3) Salva no histórico (rideRecords) com o mesmo ID
        await FirebaseFirestore.instance
            .collection('rideRecords')
            .doc(widget.rideId)
            .set(rideData);

        // 4) Atualiza o array `rideHistory` em cada usuário envolvido
        //    criador + membros
        final List<String> userIds = [
          rideData['creatorId'] as String,
          ...List<String>.from(rideData['members'] ?? <String>[])
        ];
        for (final uid in userIds) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({
                'rideHistory': FieldValue.arrayUnion([widget.rideId])
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
          .doc(widget.rideId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carona deletada com sucesso!")),
      );
      Navigator.of(context).pop(); // volta para a lista
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
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(widget.rideId)
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
          final bool isMember = members.contains(widget.user.uid);
          final bool isRunning = data['status'] == 'running';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if(!widget.isOwner)
                  Text(
                    "Detalhes da Carona",
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                // Botões de ação para o criador (editar/deletar)
                if (widget.isOwner)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Detalhes da Carona",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
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
                                   builder: (context) => CaronaForms(
                                     user: widget.user,
                                     rideData: data,
                                     rideId: widget.rideId,
                                   ),
                                 ),
                               );
                              },
                            ),
                            //const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _deleteRide(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                CaronaCardDetail(data: data, members: members).build(),
                const SizedBox(height: 15),
                // // Botão Sair (para membro)
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
                            final docRef = FirebaseFirestore.instance.collection('rides').doc(widget.rideId);
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
                //const SizedBox(height: 16),

                // Botão Reservar
                if (!widget.isOwner && !isMember && hasSlot)
                  buttonAction(
                    Color(0xFFFFCC00),
                    Colors.black,
                    "Reservar",
                    () async {
                      await FirebaseFirestore.instance
                          .collection('rides')
                            .doc(widget.rideId)
                            .update({
                            'members': FieldValue.arrayUnion([widget.user.uid]),
                          });
                    },
                    context,
                  ),
                  
                //const SizedBox(height: 24),
                
            
                // Botão "Começar Corrida" (para o criador)
                if (widget.isOwner && !isRunning)
                  buttonAction(
                    Color(0xFF336600),
                    Colors.white,
                    "Começar Corrida",
                    () => _rideStatus('running'),
                    context,
                  ),
                
                // Indicador e botões "Finalizar" / "Voltar"
                if (widget.isOwner && isRunning) ...[
                  //const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Corrida em andamento",
                      style: GoogleFonts.montserrat(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buttonAction(
                    Colors.red,
                    Colors.white,
                    "Finalizar Corrida",
                    () {
                      _finishRide(context);
                    },
                    context,
                  ),
                  const SizedBox(height: 12),
                  buttonAction(
                      Colors.green,
                      Colors.white,
                      "Reiniciar Corrida",
                      () {
                        _rideStatus('open');
                      },
                      context,
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
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
