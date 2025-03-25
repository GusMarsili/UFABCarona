import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRideScreen extends StatefulWidget {
  final User user;
  const CreateRideScreen({Key? key, required this.user}) : super(key: key);

  @override
  _CreateRideScreenState createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _createRide() async {
    if (_formKey.currentState!.validate()) {
      final String destination = _destinationController.text;
      final int availableSeats = int.tryParse(_seatsController.text) ?? 0;

      await FirebaseFirestore.instance.collection('rides').add({
        'creatorId': widget.user.uid,
        'destination': destination,
        'availableSeats': availableSeats,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Carona criada com sucesso!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Criar Carona"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(labelText: "Destino"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o destino";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _seatsController,
                decoration: InputDecoration(labelText: "Vagas Disponíveis"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o número de vagas";
                  }
                  if (int.tryParse(value) == null) {
                    return "Informe um número válido";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createRide,
                child: Text("Criar Carona"),
              )
            ],
          ),
        ),
      ),
    );
  }
}