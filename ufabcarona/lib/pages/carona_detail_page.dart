import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(data['creatorId'])
                      .get(),
                  builder: (context, userSnap) {
                    if (userSnap.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          const Text("Carregando...", style: TextStyle(fontSize: 16)),
                        ],
                      );
                    }
                    if (!userSnap.hasData || !userSnap.data!.exists) {
                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text("Criador: N/I", style: GoogleFonts.montserrat(fontSize: 16)),
                        ],
                      );
                    }
                    final userData = userSnap.data!.data() as Map<String, dynamic>;
                    final name = userData['displayName'] ?? 'N/I';
                    final photo = (userData['photoURL'] as String?) ?? '';
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                          child: photo.isEmpty ? const Icon(Icons.person, size: 20) : null,
                        ),
                        const SizedBox(width: 8),
                        Text("Criador: $name", style: GoogleFonts.montserrat(fontSize: 16)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Botão Sair (para membro)
                if (!widget.isOwner && isMember)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [              
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
                            final docRef = FirebaseFirestore.instance.collection('rides').doc(widget.rideId);
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
                if (!widget.isOwner && !isMember && hasSlot)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('rides')
                            .doc(widget.rideId)
                            .update({
                          'members': FieldValue.arrayUnion([widget.user.uid]),
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

                      // Primeiro, o caso “eu mesmo”:
                      if (isCurrent) {
                        final name = widget.user.displayName ?? 'Você';
                        final photoUrl = widget.user.photoURL;
                        final avatar = CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(name.substring(0,1).toUpperCase(), style: const TextStyle(fontSize: 12))
                              : null,
                        );
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            avatar,
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Você',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      }

                      // Caso “outro usuário”: aqui sim buscamos no Firestore
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(memberId).get(),
                        builder: (context, snapUser) {
                          if (snapUser.connectionState == ConnectionState.waiting) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                CircleAvatar(radius: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(height: 4),
                                SizedBox(width: 60, child: LinearProgressIndicator()),
                              ],
                            );
                          }
                          String name;
                          String? photoUrl;
                          if (!snapUser.hasData || !snapUser.data!.exists) {
                            name = memberId;
                            photoUrl = null;
                          } else {
                            final userData = snapUser.data!.data() as Map<String, dynamic>;
                            name = userData['displayName'] ?? memberId;
                            photoUrl = userData['photoURL'] as String?;
                          }
                          final avatar = CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                            child: (photoUrl == null || photoUrl.isEmpty)
                                ? Text(name.substring(0,1).toUpperCase(), style: const TextStyle(fontSize: 12))
                                : null,
                          );
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              avatar,
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(fontSize: 12),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Botões de ação para o criador (editar/deletar)
                if (widget.isOwner)
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
                                user: widget.user,
                                rideData: data,
                                rideId: widget.rideId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                // Botão "Começar Corrida" (para o criador)
                if (widget.isOwner && !isRunning) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _rideStatus('running'),
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
                        onPressed: () => _finishRide(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Finalizar Corrida"),
                      ),
                      OutlinedButton(
                        onPressed: () => _rideStatus('open'),
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