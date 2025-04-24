import 'package:flutter/material.dart';

class HistoricoCaronaDetailPage extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const HistoricoCaronaDetailPage({super.key, required this.rideData});

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
            Text("Paradas: ${rideData['paradas']}"),
            const SizedBox(height: 8),
            Text("Valor: ${rideData['valor']}"),
            const SizedBox(height: 8),
            Text("Placa: ${rideData['placa']}"),
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