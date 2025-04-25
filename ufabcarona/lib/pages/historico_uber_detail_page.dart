import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoricoUberDetailPage extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const HistoricoUberDetailPage({super.key, required this.rideData});

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final date = ts.toDate().toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    return 'N/I';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Detalhes da Carona Finalizada"), backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Origem: ${rideData['origem']}"),
            const SizedBox(height: 8),
            Text("Destino: ${rideData['destino']}"),
            const SizedBox(height: 8),
            Text("Horário: ${rideData['horario']}"),
            const SizedBox(height: 8),
            Text("Ponto de Encontro: ${rideData['pontoEncontro']}"),
            const SizedBox(height: 8),
            // Informações do Criador via users collection
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(rideData['creatorId'])
                  .get(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Text("Criador: ...");
                }
                if (!snap.hasData || !snap.data!.exists) {
                  return const Text("Criador: N/I");
                }
                final userData = snap.data!.data() as Map<String, dynamic>;
                final name = userData['displayName'] ?? 'N/I';
                return Text("Criador: $name");
              },
            ),
            const SizedBox(height: 8),
            // Lista de membros com lookup
            if ((rideData['members'] as List<dynamic>?)?.isNotEmpty ?? false) ...[
              const Text(
                "Membros:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (rideData['members'] as List<dynamic>).map((memberId) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(memberId)
                        .get(),
                    builder: (context, snap) {
                      String label;
                      if (snap.connectionState == ConnectionState.waiting) {
                        label = '...';
                      } else if (!snap.hasData || !snap.data!.exists) {
                        label = memberId;
                      } else {
                        final userData = snap.data!.data() as Map<String, dynamic>;
                        label = userData['displayName'] ?? memberId;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(label),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text("Criado: ${_formatTimestamp(rideData['createdAt'])}"),
            const SizedBox(height: 8),
            Text("Finalizado: ${_formatTimestamp(rideData['finishedAt'])}"),
          ],
        ),
      ),
    );
  }
}