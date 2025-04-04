import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListRidesScreen extends StatelessWidget {
  const ListRidesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Duas abas: Caronas e Grupos Uber
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Caronas e Uber"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Caronas'),
              Tab(text: 'Grupos Uber'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CaronasTab(),
            UberGroupsTab(),
          ],
        ),
      ),
    );
  }
}

class CaronasTab extends StatelessWidget {
  const CaronasTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A coleção 'rides' contém os documentos das caronas.
    CollectionReference rides = FirebaseFirestore.instance.collection('rides');

    return StreamBuilder<QuerySnapshot>(
      stream: rides.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhuma carona encontrada."));
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text("Destino: ${data['destino'] ?? 'N/I'}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Origem: ${data['origem'] ?? 'N/I'}"),
                    Text("Horário: ${data['horario'] ?? 'N/I'}"),
                    Text("Ponto de Encontro: ${data['pontoEncontro'] ?? 'N/I'}"),
                    Text("Valor: R\$ ${data['valor'] ?? 'N/I'}"),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class UberGroupsTab extends StatelessWidget {
  const UberGroupsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A coleção 'uberGroups' contém os documentos dos grupos Uber.
    CollectionReference uberGroups =
        FirebaseFirestore.instance.collection('uberGroups');

    return StreamBuilder<QuerySnapshot>(
      stream: uberGroups.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhum grupo Uber encontrado."));
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text("Destino: ${data['destino'] ?? 'N/I'}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Origem: ${data['origem'] ?? 'N/I'}"),
                    Text("Horário: ${data['horario'] ?? 'N/I'}"),
                    Text("Ponto de Encontro: ${data['pontoEncontro'] ?? 'N/I'}"),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}