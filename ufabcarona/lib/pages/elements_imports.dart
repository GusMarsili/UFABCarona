import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'carona_detail_page.dart';
import 'uber_group_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class AppBarScreen {
  AppBar build(bool status) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/images/logo-degrade.png', height: 50),
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
      automaticallyImplyLeading: status,
    );
  }
}

String _getFirstName(String? name) {
  if (name == null || name.isEmpty) return 'N/I';
  List<String> parts = name.trim().split(' ');
  return parts.length >= 2 ? '${parts[0]} ' : parts[0];
}

String formatarPrimeiraLetra(String? texto) {
    if (texto == null || texto.isEmpty) return 'N/I';
    texto = texto.toLowerCase();
    return texto[0].toUpperCase() + texto.substring(1);
  }

abstract class Cards {
  final Map<String, dynamic> data;
  const Cards({required this.data});



  int calcularVagas(int vagasTotais, List<dynamic> membros) {
    int vagasDisponiveis = vagasTotais - membros.length;
    return vagasDisponiveis.clamp(0, double.infinity).toInt();
  }


  Widget letreiro() {
    return Center(
      child: Row(
        children: [
          Text(
            formatarPrimeiraLetra(data['origem']),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 15,
            ),
          ),
          SizedBox(width: 8),
          Image.asset('lib/images/arrow.png', height: 12),
          SizedBox(width: 8),
          Expanded(
            child: AutoSizeText(
              formatarPrimeiraLetra(data['destino']),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
              maxLines: 1,
              minFontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  Widget horario([int? vagas]) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 20), //access_time
        SizedBox(width: 4),
        Text(
          data['horario'] ?? 'N/I',
          style: const TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
        ),
        SizedBox(width: 16),
        Icon(Icons.person, size: 20),
        SizedBox(width: 4),
        
        Text(
          vagas != null ? "$vagas vagas" : "Vagas N/I",
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
      ],
    );
  }

 

  Widget encontro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.location_on, size: 20),
        SizedBox(width: 4),
        Text(
          formatarPrimeiraLetra(data['pontoEncontro']) ,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
      ],
    );
  }

  Widget carro(){
    

  String formatarPlaca(String? placa) {
    if (placa == null || placa.isEmpty) return 'N/I';
    return placa.toUpperCase();
  }
  return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        Icon(Icons.drive_eta, size: 20),
        SizedBox(width: 5),
        Text(
          formatarPrimeiraLetra(data['marca']),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
        SizedBox(width: 5),
        Text(
          formatarPrimeiraLetra(data['modelo']),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
        SizedBox(width: 5),
        Text(
          formatarPlaca(data['placa']),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
        ),
      ],
    );
}

  Widget botao(
    String textoBotao,
    double sizeWidth,
    void Function()? funcaoBotao,
  ) {
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

  Widget foto(String creatorId, {double size = 23, bool returnName = false}) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(creatorId).get(),
      builder: (context, snapUser) {
        // Enquanto carrega, mostra um placeholder
        if (snapUser.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: size,
            backgroundColor: Colors.grey.shade200,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }
        // Se não existir, mostra ícone genérico
        if (!snapUser.hasData || !snapUser.data!.exists) {
          return CircleAvatar(
            radius: size,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, size: 20),
          );
        }
        // Se encontrou, usa o campo photoURL do doc user
        final userData = snapUser.data!.data() as Map<String, dynamic>;
        final photoUrl = userData['photoURL'] as String? ?? '';

        return Row(
          children: [
            CircleAvatar(
              radius: size,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child:
                  photoUrl.isEmpty
                      ? 
                      
                      Text(
                        (userData['displayName'] as String? ?? '')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      )
                      : null,
            ),
            if (returnName) const SizedBox(width: 8),
            if (returnName)
              Expanded(
                child: AutoSizeText(
                  userData['displayName'] ?? 'N/I',
                  style: GoogleFonts.montserrat(fontSize: 16),
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),
          ],
        );
      },
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
    final List<dynamic> members = data['members'] ?? [];
    int vagasDisponiveis = calcularVagas(data['vagas'], members);
    return Card(
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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
                      children: [horario(vagasDisponiveis), encontro()],
                    ),

                    // Foto e nome
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        foto(data['creatorId']),

                        FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(data['creatorId'])
                                  .get(),
                          builder: (context, snapUser) {
                            String firstName = '';
                            if (snapUser.connectionState ==
                                ConnectionState.waiting) {
                              firstName = 'Carregando...';
                            } else if (snapUser.hasData &&
                                snapUser.data!.exists) {
                              final userData =
                                  snapUser.data!.data() as Map<String, dynamic>;
                              final fullName =
                                  userData['displayName'] as String? ?? '';
                              firstName = _getFirstName(fullName);
                            } else {
                              firstName = 'N/I';
                            }
                            return Text(
                              firstName,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                              ),
                            );
                          },
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
                  botao("Reservar", 245, () {
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
                    "R\$${data['valor'] ?? 'N/I'}",
                    
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
    final List<dynamic> members = data['members'] ?? [];
    int vagasDisponiveis = calcularVagas(2, members);
    return Card(
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            letreiro(),
            const SizedBox(height: 10),
            horario(vagasDisponiveis),
            SizedBox(height: 10),
            encontro(),
            const SizedBox(height: 10),
            botao("Participar", double.infinity, () {
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

class UberCardDetail extends Cards {
  final List<dynamic> members;
  UberCardDetail({required super.data, required this.members});



  Widget build() {
    final List<dynamic> members = data['members'] ?? [];
    int vagasDisponiveis = calcularVagas(2, members);
    return Card(
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            letreiro(),
            const SizedBox(height: 20),
            horario(vagasDisponiveis),
            SizedBox(height: 16),
            encontro(),
            const SizedBox(height: 20),
            Text(
              "Criador(a):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 15),
            foto(data['creatorId'], size: 30, returnName: true),
            const SizedBox(height: 15),
            
            Text(
              "Participantes:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            if (members.isNotEmpty)
              ...members.map((member) {
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(member)
                          .get(),
                  builder: (context, snapUser) {
                    if (snapUser.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapUser.hasData || !snapUser.data!.exists) {
                      return const SizedBox.shrink();
                    }
                    final userData =
                        snapUser.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            foto(member, size: 30),
                            const SizedBox(width: 10),

                            Expanded(
                              child: AutoSizeText(
                                userData['displayName'] ?? 'N/I',
                                style: GoogleFonts.montserrat(fontSize: 16),
                                maxLines: 1,
                                minFontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              })
            else ...[
              Text(
                "Nenhum participante ainda.",
                style: GoogleFonts.montserrat(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class CaronaCardDetail extends Cards {
  final List<dynamic> members;
  CaronaCardDetail({required super.data, required this.members});

  Widget build() {
    final List<dynamic> members = data['members'] ?? [];
    int vagasDisponiveis = calcularVagas(data['vagas'], members);
    return Card(
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            letreiro(), //origem e destino
            const SizedBox(height: 15),
            Text( //valor da corrida
                    "R\$ ${data['valor'] ?? 'N/I'}",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                    ),
                  ),
            SizedBox(height: 15),
            horario(vagasDisponiveis), // horario e vagas
            SizedBox(height: 15),
            encontro(), //ponto de encontro
            const SizedBox(height: 15),
            carro(), //marca, modelo e placa do carro
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Paradas:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                  ),
                ),
                if (data['paradas'] != null && data['paradas'].isNotEmpty) ...[
                  // Exibindo cada parada com bullet points
                  for (var parada in data['paradas']) 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.black),  // Bullet point
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              parada,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ] else ...[
                  // Caso não haja paradas
                  Text(
                    "Sem Paradas",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 15),
            
            Text(
              "Motorista:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 15),
            foto(data['creatorId'], size: 30, returnName: true),
            const SizedBox(height: 15),
            Text(
              "Passageiros:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            if (members.isNotEmpty)
              ...members.map((member) {
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(member)
                          .get(),
                  builder: (context, snapUser) {
                    if (snapUser.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapUser.hasData || !snapUser.data!.exists) {
                      return const SizedBox.shrink();
                    }
                    final userData =
                        snapUser.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            foto(member, size: 30),
                            const SizedBox(width: 10),
                            
                            Expanded(
                              child: AutoSizeText(
                                userData['displayName'] ?? 'N/I',
                                style: GoogleFonts.montserrat(fontSize: 16),
                                maxLines: 1,
                                minFontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              })
            else ...[
              Text(
                "Nenhum passageiro ainda.",
                style: GoogleFonts.montserrat(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UberReservaCard extends Cards {
  UberReservaCard({required super.data});
  
  Widget build(
    bool isOwner,
    User user,
    String documentId,
    BuildContext context,
  ) {
    final List<dynamic> members = data['members'] ?? [];
    int vagasDisponiveis = calcularVagas(2, members);
    return Card(
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 letreiro(),
                 const SizedBox(height: 10),
                 horario(vagasDisponiveis),
                 const SizedBox(height: 10),
                 encontro(),
               ],
             ),
           ),

           InkWell(
             onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => UberGroupDetailPage(
                     user: user,
                     groupId: documentId,
                     isOwner: isOwner,
                   ),
                 ),
               );
             },
             child: data['status'] == 'running' ?
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 14),
               decoration: const BoxDecoration(
                 color: Color(0xFFFFCC00), // Verde escuro
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(16),
                   bottomRight: Radius.circular(16),
                 ),
               ),
               alignment: Alignment.center,
               child: const Text(
                 'Corrida Em Andamento',
                 style: TextStyle(
                   color: Colors.black,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'Montserrat',
                   fontSize: 16,
                 ),
               ),
             )
             : Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 14),
               decoration: const BoxDecoration(
                 color: Color(0xFF336600), // Verde escuro
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(16),
                   bottomRight: Radius.circular(16),
                 ),
               ),
               alignment: Alignment.center,
               child: const Text(
                 'Informações',
                 style: TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'Montserrat',
                   fontSize: 16,
                 ),
               ),
             ),
           ),
        ],
      ),
    );
  }
}

class CaronaReservaCard extends Cards {
  CaronaReservaCard({required super.data});
  
  Widget build(
    bool isOwner,
    User user,
    String documentId,
    BuildContext context,
  ) {
    final List<dynamic> members = data['members'] ?? [];
    int vagasDisponiveis = calcularVagas(data['vagas'], members);
    return Card(
      color: Color(0xFFFBFBFB),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          SizedBox(
            height: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 18),
          
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          children: [horario(vagasDisponiveis), encontro()],
                        ),
          
                        // Foto e nome
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          
                          children: [
                            foto(data['creatorId']),
          
                            FutureBuilder<DocumentSnapshot>(
                              future:
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(data['creatorId'])
                                      .get(),
                              builder: (context, snapUser) {
                                String firstName = '';
                                if (snapUser.connectionState ==
                                    ConnectionState.waiting) {
                                  firstName = 'Carregando...';
                                } else if (snapUser.hasData &&
                                    snapUser.data!.exists) {
                                  final userData =
                                      snapUser.data!.data() as Map<String, dynamic>;
                                  final fullName =
                                      userData['displayName'] as String? ?? '';
                                  firstName = _getFirstName(fullName);
                                } else {
                                  firstName = 'N/I';
                                }
                                return Text(
                                  firstName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
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
            ),
          ),
          InkWell(
             onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => CaronaDetailPage(
                     user: user,
                     rideId: documentId,
                     isOwner: isOwner,
                   ),
                 ),
               );
             },
             child: 
             data['status'] == 'running' ?
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 14),
               decoration: const BoxDecoration(
                 color: Color(0xFFFFCC00), // Verde escuro
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(16),
                   bottomRight: Radius.circular(16),
                 ),
               ),
               alignment: Alignment.center,
               child: const Text(
                 'Corrida Em Andamento',
                 style: TextStyle(
                   color: Colors.black,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'Montserrat',
                   fontSize: 16,
                 ),
               ),
             )
             : Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 14),
               decoration: const BoxDecoration(
                 color: Color(0xFF336600), // Verde escuro
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(16),
                   bottomRight: Radius.circular(16),
                 ),
               ),
               alignment: Alignment.center,
               child: const Text(
                 'Informações',
                 style: TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'Montserrat',
                   fontSize: 16,
                 ),
               ),
             ),
           ),
        ],
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
