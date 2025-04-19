import 'package:google_fonts/google_fonts.dart';

import 'carona_detail_page.dart';
import 'uber_group_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppBarScreen {
  AppBar build() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      centerTitle: true,
      title: Row(
      
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/images/logo-degrade.png',
            height: 50,
          ),
          Text(
            "UFABCarona",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String _getFirstName(String? name) {
  if (name == null || name.isEmpty) return 'N/I';
  List<String> parts = name.trim().split(' ');
  return parts.length >= 2 ? '${parts[0]} ' : parts[0];
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
              fontSize: 15,
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
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget horario() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 20), //access_time
        SizedBox(width: 4),
        Text(
          data['horario'] ?? 'N/I',
          style: const TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
        ),
      ],
    );
  }

  Widget encontro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 20),
        SizedBox(width: 4),
        Text(
          "${data['vagas'] ?? 'N/I'} vagas",
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
        SizedBox(width: 16),
        Icon(Icons.location_on, size: 20),
        SizedBox(width: 4),
        Text(
          data['pontoEncontro'] ?? 'N/I',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
      ],
    );
  }

  

  Widget botao(String textoBotao,double sizeWidth, void Function()? funcaoBotao) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
      width: sizeWidth, //double.infinity,245
      height: 30,
      child: ElevatedButton(
        
        onPressed: funcaoBotao,
        style: ElevatedButton.styleFrom(
          
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 5),
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
    ),
    );
    
  }

  Widget foto() {
    return CircleAvatar(
      radius: 23,
      backgroundColor: Colors.grey.shade200,
      child:
          data['creatorPhotoURL'] != null && data['creatorPhotoURL'].isNotEmpty
              ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: data['creatorPhotoURL'],
                  width: 50,
                  height: 50,
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
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 25,vertical: 5), 
      child: SizedBox(
        height: 165,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 18), 

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              letreiro(),
              
              Expanded(
                child: Row(
                  
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Informações da viagem  
                                   
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [ 
                                                   
                          horario(),  
                                                  
                          encontro(),
                        ],
                      ),
                    
                    
                    // Foto e nome
                    
                       Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          
                          children: [  
                                                                                   
                               foto(),
                                                         
                               Text(
                                _getFirstName(data['creatorName']),
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                ),
                              ),                                                        
                            
                          ],
                        ),
                    
                    
                  ],
                ),
              ),
              // Botão Reservar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  botao("Reservar",245, () {
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
                  Text(
                       "R\$ ${data['valor'] ?? 'N/I'}",
                       style: TextStyle(
                         fontWeight: FontWeight.normal,
                         fontFamily: 'Montserrat',
                         fontSize: 20,
                       ),
                     ),
                ],
              ),
            ],
          ),
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
      color: Color(0xFFFBFBFB),
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
            botao("Participar",double.infinity, () {
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
