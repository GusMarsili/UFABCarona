import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(title: const Text('Histórico de Caronas'), backgroundColor: Colors.white,),
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
                color: Color(0xFFFBFBFB),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: Container(
                    width: 45,  // Definindo largura e altura para deixar quadrado
                    height: 45,
                    decoration: BoxDecoration(
                      color: ride['type'] == 'carona'
                      ? Color(0xFFFFCC00)
                      : Color(0xFF336600), // Cor de fundo do quadrado
                      borderRadius: BorderRadius.circular(8), // Arredonda um pouco, opcional
                    ),
                    alignment: Alignment.center, // Centraliza o ícone
                    child: ride['type'] == 'carona'
                      ?
                      const Icon(
                      Icons.directions_car, // Ícone que você quiser
                      color: Colors.white, // Cor do ícone
                      size: 35,)
                      :
                      const Icon(
                      IconlyBold.user_3, // Ícone que você quiser
                      color: Colors.white, // Cor do ícone
                      size: 35,)
                    
                      
                    
                  ),
                  title: Text('${ride['origem']} → ${ride['destino']}'),
                  subtitle: Text('Data: ${_formatTimestamp(ride['finishedAt'])}'),
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
