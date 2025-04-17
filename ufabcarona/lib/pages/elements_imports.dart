import 'carona_detail_page.dart';
import 'uber_group_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppBarScreen {
  AppBar build() {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/images/logoUFABCarona.png', height: 60),
          SizedBox(width: 1),
          Text(
            "UFABCarona",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

abstract class Cards {
  final Map<String, dynamic> data;
  const Cards({required this.data});

  Widget letreiro() {
    return Center(
      child: Row(
        children: [
          Text(
            data['origem'] ?? 'N/I',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(width: 8),
          Image.asset('lib/images/arrow.png', height: 12),
          SizedBox(width: 8),
          Text(
            data['destino'] ?? 'N/I',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget horario() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16),
        SizedBox(width: 4),
        Text(
          data['horario'] ?? 'N/I',
          style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
        ),
      ],
    );
  }

  Widget encontro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 16),
        SizedBox(width: 4),
        Text(
          "${data['vagas'] ?? 'N/I'}",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        SizedBox(width: 16),
        Icon(Icons.location_on, size: 16),
        SizedBox(width: 4),
        Text(
          data['pontoEncontro'] ?? 'N/I',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ],
    );
  }

  Widget botao(String textoBotao, void Function()? funcaoBotao) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: funcaoBotao,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          textoBotao,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  Widget foto() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade200,
      child:
          data['creatorPhotoURL'] != null && data['creatorPhotoURL'].isNotEmpty
              ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: data['creatorPhotoURL'],
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.person, size: 20),
                ),
              )
              : const Icon(Icons.person, size: 20),
    );
  }
}

class CaronaCard extends Cards {
  CaronaCard({required super.data});

  Widget build(
    bool isOwner,
    User user,
    String documentId,
    BuildContext context,
  ) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            letreiro(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações da viagem
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Horário
                      horario(),
                      const SizedBox(height: 8),
                      encontro(),
                    ],
                  ),
                ),
                // Foto e nome
                Column(
                  children: [
                    foto(),
                    SizedBox(height: 8),
                    Text(
                      data['creatorName'] ?? 'N/I',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "R\$ ${data['valor'] ?? 'N/I'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botão Reservar
            botao("Reservar", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CaronaDetailPage(
                        user: user,
                        rideId: documentId,
                        isOwner: isOwner,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class UberCard extends Cards {
  UberCard({required super.data});
  Widget build(
    bool isOwner,
    User user,
    String documentId,
    BuildContext context,
    ) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            letreiro(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Horário
                      horario(),
                      const SizedBox(width: 16),
                      encontro(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            botao("Participar", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => UberGroupDetailPage(
                        user: user,
                        groupId: documentId,
                        isOwner: isOwner,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TextFieldElement {
  final String labelText;
  final bool showSearchIcon;
  final bool haveController;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  TextFieldElement({
    required this.labelText,
    this.showSearchIcon = false,
    this.haveController = false,
    this.controller,
    this.onChanged,
  });

  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
        controller: haveController ? controller : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          prefixIcon:
              showSearchIcon ? Icon(Icons.search, color: Colors.grey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
