import 'package:flutter/material.dart';

class HistoricoUberDetailPage extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const HistoricoUberDetailPage({super.key, required this.rideData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes da Carona Finalizada")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Origem: ${rideData['origem']}"),
            const SizedBox(height: 8),
            Text("Destino: ${rideData['destino']}"),
            const SizedBox(height: 8),
            Text("Horário: ${rideData['horario']}"),
            const SizedBox(height: 8),
            Text("Ponto de Encontro: ${rideData['pontoEncontro']}"),
            const SizedBox(height: 8),
            Text("Criador: ${rideData['creatorName']}"),
            const SizedBox(height: 8),
            Text("Membros: ${(rideData['members'] as List).join(', ')}"),
            const SizedBox(height: 8),
            Text("Criado: ${rideData['createdAt']}"),
            const SizedBox(height: 8),
            Text("Finalizado: ${rideData['finishedAt']}"),
          ],
        ),
      ),
    );
  }
}