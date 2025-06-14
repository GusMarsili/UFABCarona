import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'elements_imports.dart';
import 'package:google_fonts/google_fonts.dart';

class UberForms extends StatefulWidget {
  final User user;
  // Parâmetros opcionais para edição:
  final Map<String, dynamic>? groupData;
  final String? groupId;
  
  const UberForms({
    super.key,
    required this.user,
    this.groupData,
    this.groupId,
  });

  @override
  State<UberForms> createState() => _UberFormsState();
}

class HoraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remover tudo o que não for número
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limitar a quantidade de dígitos para 4 (HHMM)
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    // Adiciona o ":" no meio, entre os 2 primeiros e 2 últimos dígitos
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) buffer.write(':'); // Adiciona ":" entre os dois primeiros dígitos
      buffer.write(digitsOnly[i]);
    }

    String formatted = buffer.toString();

    

    // Retorna o texto formatado e garante que o cursor esteja na posição final
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _UberFormsState extends State<UberForms> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos do formulário
  final TextEditingController _origemController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _pontoEncontroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se estiver em modo edição, pré-preenche os campos com os dados existentes
    if (widget.groupData != null) {
      _origemController.text = widget.groupData!['origem'] ?? '';
      _destinoController.text = widget.groupData!['destino'] ?? '';
      _horarioController.text = widget.groupData!['horario'] ?? '';
      _pontoEncontroController.text = widget.groupData!['pontoEncontro'] ?? '';
    }
  }

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _horarioController.dispose();
    _pontoEncontroController.dispose();
    super.dispose();
  }

  Future<void> _saveUberGroup() async {
    if (_formKey.currentState!.validate()) {
      if (widget.groupData == null) {
        await FirebaseFirestore.instance.collection('uberGroups').add({
          'creatorId': widget.user.uid,
          'status': "open", // (open / running / closed)
          'origem': _origemController.text,
          'destino': _destinoController.text,
          'horario': _horarioController.text,
          'pontoEncontro': _pontoEncontroController.text,
          'members': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(), 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Grupo Uber criado com sucesso!")),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('uberGroups')
            .doc(widget.groupId)
            .update({
          'origem': _origemController.text,
          'destino': _destinoController.text,
          'horario': _horarioController.text,
          'pontoEncontro': _pontoEncontroController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Grupo Uber atualizado com sucesso!")),
        );
      }
      // Limpa os campos do formulário
      _origemController.clear();
      _destinoController.clear();
      _horarioController.clear();
      _pontoEncontroController.clear();

      // Exibir um modal de loading que bloqueia a interação
      showDialog(
        context: context,
        barrierDismissible: false, // impede que o usuário feche o diálogo
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Aguarda 1 segundo para que o SnackBar seja visível
      await Future.delayed(const Duration(seconds: 1));

      // Fecha o diálogo de loading
      Navigator.of(context).pop();

      // Volta para a página anterior
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.groupData == null
        ? "Criar Grupo Uber"
        : "Modificar Grupo Uber";

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _origemController,
                  decoration: const InputDecoration(labelText: 'Origem'),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe a origem" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _destinoController,
                  decoration: const InputDecoration(labelText: 'Destino'),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Informe o destino" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _horarioController,
                  decoration: const InputDecoration(labelText: 'Horário'),
                  inputFormatters: [HoraInputFormatter()],  // Usa o formatador personalizado
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Informe o horário";
                    }
                
                    // Valida o formato de HH:MM
                    final parts = v.split(':');
                    if (parts.length != 2) return "Formato inválido";
                
                    final hora = int.tryParse(parts[0]);
                    final minuto = int.tryParse(parts[1]);
                
                    if (hora == null || minuto == null) return "Formato inválido";
                    if (hora < 0 || hora > 23) return "Hora deve ser entre 00 e 23";
                    if (minuto < 0 || minuto > 59) return "Minuto deve ser entre 00 e 59";
                
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _pontoEncontroController,
                  decoration: const InputDecoration(labelText: 'Ponto de Encontro'),
                  validator: (value) =>
                      value == null || value.isEmpty
                          ? "Informe o ponto de encontro"
                          : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: _saveUberGroup,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF336600),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(fontSize: 20),
                      elevation: 4, // <<< Aqui adiciona a sombra
                      shadowColor: Color(0xFF000000), // <<< Define a cor da sombra
                    ),
                    child: widget.groupData == null
                        ? const Text(
                            "Criar",
                            style: TextStyle(fontFamily: "Poppins", fontSize: 20),
                          )
                        : const Text(
                            "Salvar",
                            style: TextStyle(fontFamily: "Poppins", fontSize: 20),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
