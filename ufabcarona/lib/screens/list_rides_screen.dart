import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListRidesScreen extends StatelessWidget {
  const ListRidesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference rides = FirebaseFirestore.instance.collection('rides');

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Caronas"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: rides.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Nenhuma carona encontrada."));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Destino: ${data['destination']}"),
                subtitle: Text("Vagas: ${data['availableSeats']}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}