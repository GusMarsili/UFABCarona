import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'elements_imports.dart';

class UberForms extends StatelessWidget {
  final User user;
  const UberForms({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return UberPage(user: user);
  }
}

class UberPage extends StatefulWidget {
  final User user;
  const UberPage({super.key, required this.user});

  @override
  State<StatefulWidget> createState() {
    return UberPageState();
  }
}

class UberPageState extends State<UberPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _origemController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _pontoEncontroController = TextEditingController();

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _horarioController.dispose();
    _pontoEncontroController.dispose();
    super.dispose();
  }

  Future<void> _createUberGroup() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('uberGroups').add({
        'creatorId': widget.user.uid,
        'origem': _origemController.text,
        'destino': _destinoController.text,
        'horario': _horarioController.text,
        'pontoEncontro': _pontoEncontroController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Grupo Uber criado com sucesso!")),
      );

      // Limpa os campos do formulário
      _origemController.clear();
      _destinoController.clear();
      _horarioController.clear();
      _pontoEncontroController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double spacing = height * 0.012;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarScreen().build(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.05),
                const Text(
                  "Criar Grupo Uber",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _origemController,
                  decoration: const InputDecoration(labelText: 'Origem'),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe a origem" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _destinoController,
                  decoration: const InputDecoration(labelText: 'Destino'),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe o destino" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _horarioController,
                  decoration: const InputDecoration(labelText: 'Horário'),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe o horário" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _pontoEncontroController,
                  decoration:
                      const InputDecoration(labelText: 'Ponto de Encontro'),
                  validator: (value) => value == null || value.isEmpty
                      ? "Informe o ponto de encontro"
                      : null,
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: _createUberGroup,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF336600),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text(
                      "Criar",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}