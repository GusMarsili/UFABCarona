import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'historico_carona_detail_page.dart';
import 'historico_uber_detail_page.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  Future<List<DocumentSnapshot>> _getUserRideHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Busca o documento do usuário
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final rideHistory = List<String>.from(userDoc.data()?['rideHistory'] ?? []);

    // Busca os documentos das caronas finalizadas
    final rideFutures = rideHistory.map((rideId) =>
      FirebaseFirestore.instance.collection('rideRecords').doc(rideId).get()
    ).toList();

    return Future.wait(rideFutures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Caronas')),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getUserRideHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhuma carona finalizada encontrada."));
          }

          final rides = snapshot.data!;
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('${ride['origem']} → ${ride['destino']}'),
                  subtitle: Text('Data: ${ride['finishedAt']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (ride['type'] == 'carona') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoricoCaronaDetailPage(rideData: ride),
                        ),
                      );
                    } else if (ride['type'] == 'uber') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoricoUberDetailPage(rideData: ride),
                        ),
                      );
                    } else {
                      // Opcional: tratar tipo desconhecido
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tipo de carona desconhecido.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}