import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ufabcarona/pages/elements_imports.dart';


class ReservasPage extends StatelessWidget {
  final User user;
  const ReservasPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Minhas Reservas',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minhas Caronas',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .where('members', arrayContains: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('Nenhuma carona reservada.');
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isOwner = data['creatorId'] == user.uid;
                    return CaronaReservaCard(
                            data: data,
                          ).build(isOwner, user, doc.id, context);
                    
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Meus Grupos Uber',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('uberGroups')
                  .where('members', arrayContains: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('Nenhum grupo Uber reservado.');
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isOwner = data['creatorId'] == user.uid;
                    return UberReservaCard(
                            data: data,
                          ).build(isOwner, user, doc.id, context);
                    
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Minhas Publicações',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),            
            StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: CombineLatestStream.list([
                FirebaseFirestore.instance
                    .collection('rides')
                    .where('creatorId', isEqualTo: user.uid)
                    .snapshots()
                    .map((snap) => snap.docs),
                FirebaseFirestore.instance
                    .collection('uberGroups')
                    .where('creatorId', isEqualTo: user.uid)
                    .snapshots()
                    .map((snap) => snap.docs),
              ]).map((lists) => lists.expand((x) => x).toList()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  return const Text('Nenhuma publicação encontrada.');
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isRide = doc.reference.parent.id == 'rides';

                    return isRide ? CaronaReservaCard(
                            data: data,
                          ).build(true, user, doc.id, context)
                          :
                          UberReservaCard(
                            data: data,
                          ).build(true, user, doc.id, context);



                    
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
