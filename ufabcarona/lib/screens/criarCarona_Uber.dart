import 'package:flutter/material.dart';
import 'ElementsImports.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: StartPage());
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return StartPageState();
  }
}

class StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarScreen().build(),
      body: _BodyScreen().build(context),
      //#TODO: Criar o BottomNavigationBar
      persistentFooterButtons: [Text("TODO: Criar o BottomNavigationBar")],
    );
  }
}

//ARRUMAR
class _BodyScreen {
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Você Deseja",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          SizedBox(height: heigth * 0.05),
          ButtonElement(
            backgroundColor: Color(0xFFFFCC00),
            foregroundColor: Colors.black,
            text: "Criar carona",
          ).build(context),
          SizedBox(height: heigth * 0.015),
          ButtonElement(
            backgroundColor: Color(0xFF336600),
            foregroundColor: Colors.white,
            text: "Criar Grupo Uber",
          ).build(context),
        ],
      ),
    );
  }
}

class ButtonElement {
  final Color backgroundColor, foregroundColor;
  final String text; //screenDestination;

  ButtonElement({
    //required this.screenDestination,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.1,
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