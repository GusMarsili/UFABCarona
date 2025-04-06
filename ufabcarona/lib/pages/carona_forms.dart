import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'elements_imports.dart';

class CaronaForms extends StatelessWidget {
  final User user;
  const CaronaForms({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CaronaPage(user: user);
  }
}

class CaronaPage extends StatefulWidget {
  final User user;
  const CaronaPage({super.key, required this.user});

  @override
  State<StatefulWidget> createState() {
    return CaronaPageState();
  }
}

class CaronaPageState extends State<CaronaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _origemController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _pontoEncontroController = TextEditingController();
  final TextEditingController _vagasController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _paradasController = TextEditingController();

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _horarioController.dispose();
    _pontoEncontroController.dispose();
    _vagasController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _valorController.dispose();
    _paradasController.dispose();
    super.dispose();
  }

  Future<void> _createCarona() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('rides').add({
        'creatorId': widget.user.uid,
        'origem': _origemController.text,
        'destino': _destinoController.text,
        'horario': _horarioController.text,
        'pontoEncontro': _pontoEncontroController.text,
        'vagas': int.tryParse(_vagasController.text) ?? 0,
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'placa': _placaController.text,
        'valor': _valorController.text,
        'paradas': _paradasController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Exibe a mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carona criada com sucesso!")),
      );

      // Limpa os campos do formulário
      _origemController.clear();
      _destinoController.clear();
      _horarioController.clear();
      _pontoEncontroController.clear();
      _vagasController.clear();
      _marcaController.clear();
      _modeloController.clear();
      _placaController.clear();
      _valorController.clear();
      _paradasController.clear();
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
                  "Criar Carona",
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
                TextFormField(
                  controller: _vagasController,
                  decoration: const InputDecoration(labelText: 'Vagas'),
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
                SizedBox(height: spacing),
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(labelText: 'Marca do carro'),
                  validator: (value) => value == null || value.isEmpty
                      ? "Informe a marca do carro"
                      : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _modeloController,
                  decoration:
                      const InputDecoration(labelText: 'Modelo do carro'),
                  validator: (value) => value == null || value.isEmpty
                      ? "Informe o modelo do carro"
                      : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _placaController,
                  decoration:
                      const InputDecoration(labelText: 'Placa do carro'),
                  validator: (value) => value == null || value.isEmpty
                      ? "Informe a placa do carro"
                      : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe o valor" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _paradasController,
                  decoration: const InputDecoration(labelText: 'Paradas'),
                  validator: (value) => value == null || value.isEmpty
                      ? "Informe as paradas"
                      : null,
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: _createCarona,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFFFCC00),
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