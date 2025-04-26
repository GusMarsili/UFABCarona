import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'elements_imports.dart';

class CaronaForms extends StatefulWidget {
  final User user;
  // Parâmetros opcionais para edição:
  final Map<String, dynamic>? rideData;
  final String? rideId;

  const CaronaForms({
    super.key,
    required this.user,
    this.rideData,
    this.rideId,
  });

  @override
  State<CaronaForms> createState() => _CaronaFormsState();
}

class _CaronaFormsState extends State<CaronaForms> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos do formulário
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
  void initState() {
    super.initState();
    if (widget.rideData != null) {
      _origemController.text = widget.rideData!['origem'] ?? '';
      _destinoController.text = widget.rideData!['destino'] ?? '';
      _horarioController.text = widget.rideData!['horario'] ?? '';
      _pontoEncontroController.text = widget.rideData!['pontoEncontro'] ?? '';
      _vagasController.text = widget.rideData!['vagas']?.toString() ?? '';
      _marcaController.text = widget.rideData!['marca'] ?? '';
      _modeloController.text = widget.rideData!['modelo'] ?? '';
      _placaController.text = widget.rideData!['placa'] ?? '';
      _valorController.text = widget.rideData!['valor']?.toString() ?? '';
      _paradasController.text = widget.rideData!['paradas'] ?? '';
    }
  }

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

  Future<void> _saveCarona() async {
    if (_formKey.currentState!.validate()) {
      if (widget.rideData == null) {
        await FirebaseFirestore.instance.collection('rides').add({
          'creatorId': widget.user.uid,
          'status': "open", // (open / running / closed)
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
          'members': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Carona criada com sucesso!")),
        );
      } else {
        await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).update({
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
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Carona atualizada com sucesso!")),
        );
      }

      // Limpa os campos
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

      // Modal de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.rideData == null ? "Criar Carona" : "Modificar Carona";
    final height = MediaQuery.of(context).size.height;
    final spacing = height * 0.012;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarScreen().build(true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.05),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _origemController,
                  decoration: const InputDecoration(labelText: 'Origem'),
                  validator: (v) => v == null || v.isEmpty ? "Informe a origem" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _destinoController,
                  decoration: const InputDecoration(labelText: 'Destino'),
                  validator: (v) => v == null || v.isEmpty ? "Informe o destino" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _horarioController,
                  decoration: const InputDecoration(labelText: 'Horário'),
                  validator: (v) => v == null || v.isEmpty ? "Informe o horário" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _pontoEncontroController,
                  decoration: const InputDecoration(labelText: 'Ponto de Encontro'),
                  validator: (v) => v == null || v.isEmpty ? "Informe o ponto de encontro" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _vagasController,
                  decoration: const InputDecoration(labelText: 'Vagas'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Informe o número de vagas";
                    if (int.tryParse(v) == null) return "Informe um número válido";
                    return null;
                  },
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(labelText: 'Marca do carro'),
                  validator: (v) => v == null || v.isEmpty ? "Informe a marca do carro" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(labelText: 'Modelo do carro'),
                  validator: (v) => v == null || v.isEmpty ? "Informe o modelo do carro" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(labelText: 'Placa do carro'),
                  validator: (v) => v == null || v.isEmpty ? "Informe a placa do carro" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  validator: (v) => v == null || v.isEmpty ? "Informe o valor" : null,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _paradasController,
                  decoration: const InputDecoration(labelText: 'Paradas'),
                  validator: (v) => v == null || v.isEmpty ? "Informe as paradas" : null,
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: height * 0.06,
                  child: ElevatedButton(
                    onPressed: _saveCarona,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFFFCC00),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: widget.rideData == null
                        ? const Text("Criar", style: TextStyle(fontFamily: "Poppins", fontSize: 20))
                        : const Text("Salvar", style: TextStyle(fontFamily: "Poppins", fontSize: 20)),
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
