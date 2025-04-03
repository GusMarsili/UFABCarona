import 'package:flutter/material.dart';
import 'package:ola_mundo/ElementsImports.dart';

class CaronaForms extends StatelessWidget {
  const CaronaForms({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CaronaPage());
  }
}

class CaronaPage extends StatefulWidget {
  const CaronaPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CaronaPageState();
  }
}

class CaronaPageState extends State<CaronaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarScreen().build(),
      body: _BodyScreen().build(context),
    );
  }
}

class _BodyScreen {
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double spacing = height * 0.012;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: (height * 0.05)),
                Text(
                  "Criar Carona",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Origem').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Destino').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Horário').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Ponto de Encontro').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Vagas').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Marca do carro').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Modelo do carro').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Placa do carro').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Valor').build(context),
                SizedBox(height: spacing),
                TextFieldElement(labelText: 'Paradas').build(context),
                SizedBox(height: spacing),
                _Button(
                  text: "Criar",
                  backgroundColor: Color(0xFFFFCC00),
                  foregroundColor: Colors.black,
                ).build(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Button {
  final Color backgroundColor, foregroundColor;
  final String text;

  _Button({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Text(
          text,
          style: TextStyle(fontFamily: "Poppins", fontSize: 20),
        ),
      ),
    );
  }
}
