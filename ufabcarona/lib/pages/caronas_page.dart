import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'elements_imports.dart';

class CaronasPage extends StatefulWidget {
  final User user;
  final bool mostrarFiltros = true;

  const CaronasPage({super.key, required this.user});

  @override
  State<CaronasPage> createState() => _CaronasPageState();
}

class _CaronasPageState extends State<CaronasPage> {
  late final User user;
  late bool mostrarFiltros;
  final TextEditingController _controllerOrigem = TextEditingController();
  final TextEditingController _controllerDestino = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;
    mostrarFiltros = widget.mostrarFiltros;
  }

  @override
  void dispose() {
    _controllerOrigem.removeListener(_filterRides);
    _controllerDestino.removeListener(_filterRides);
    super.dispose();
  }

  void _filterRides() {
    setState(() {
      // Chama o setState para atualizar a UI sempre que os filtros mudarem
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference rides = FirebaseFirestore.instance.collection('rides');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Grupos Caronas",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              setState(() {
                mostrarFiltros = !mostrarFiltros;
              });
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: rides.orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma carona encontrada.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          return ListView(
            children: [
              if (mostrarFiltros)
                Column(
                  children: [
                    SizedBox(height: 5),
                    TextFieldElement(
                      labelText: "Origem",
                      showSearchIcon: true,
                      haveController: true,
                      controller: _controllerOrigem,
                      onChanged: (_) => _filterRides(),
                    ).build(context),
                    SizedBox(height: 7),
                    TextFieldElement(
                      labelText: "Destino",
                      showSearchIcon: true,
                      haveController: true,
                      controller: _controllerDestino,
                      onChanged: (_) => _filterRides(),
                    ).build(context),
                    SizedBox(height: 10),
                  ],
                ),
              ...snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                if (data['origem'].toLowerCase().contains(
                      _controllerOrigem.text.toLowerCase(),
                    ) &&
                    data['destino'].toLowerCase().contains(
                      _controllerDestino.text.toLowerCase(),
                    )) {
                  bool isOwner = data['creatorId'] == user.uid;
                  return CaronaCard(
                    data: data,
                  ).build(isOwner, user, document.id, context);
                } else {
                  return Container();
                }
              }),
            ],
          );
        },
      ),
    );
  }
}
