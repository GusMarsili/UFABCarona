import 'elements_imports.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UberPage extends StatefulWidget {
  final User user;
  final bool mostrarFiltros = false;
  const UberPage({super.key, required this.user});

  @override
  State<UberPage> createState() => _UberPageState();
}

class _UberPageState extends State<UberPage> {
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
    CollectionReference uberGroups = FirebaseFirestore.instance.collection(
      'uberGroups',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Grupos Uber",
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
      body: Column(
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
              ],
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  uberGroups.orderBy('updatedAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhum grupo Uber encontrado.",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                            final List<dynamic> members = data['members'] ?? [];
                             
                            final int vagasDisponiveis = 3 - members.length;

                        // Verifica se a carona foi criada pelo usuário atual
                        if (data['origem'].toLowerCase().contains(
                              _controllerOrigem.text.toLowerCase(),
                            ) &&
                            data['destino'].toLowerCase().contains(
                              _controllerDestino.text.toLowerCase(),
                            ) &&
                            vagasDisponiveis>0) {
                          bool isOwner = data['creatorId'] == user.uid;
                          return UberCard(
                            data: data,
                          ).build(isOwner, user, document.id, context);
                        } else {
                          return Container();
                        }
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
