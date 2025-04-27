import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("FAQ - Perguntas Frequentes"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFaqItem(
            "Quem pode utilizar o aplicativo?",
            "Só os alunos da UFABC têm acesso ao app, então pode ficar tranquilo! Se você é aluno, está no lugar certo para se conectar e organizar suas caronas.",
          ),
          _buildFaqItem(
            "Como crio uma carona?",
            "Criar uma carona é fácil! É só clicar no botão 'Criar Carona' ou 'Criar Uber', preencher o formulário e pronto! Sua carona ou grupo Uber estará disponível para o pessoal que precisar. Simples assim!",
          ),
          _buildFaqItem(
            "Onde eu vejo as caronas que criei?",
            "As caronas que você criou ficam na aba 'Reservas'. Lá você pode ver todos os detalhes e acompanhar as caronas que organizou.",
          ),
          _buildFaqItem(
            "Tem como eu editar uma carona que criei?",
            "Claro! Se você precisa fazer algum ajuste, é só clicar na carona que você criou. Você verá um lápis azul para editar ou uma lixeira vermelha para deletar. Simples e rápido!",
          ),
          _buildFaqItem(
            "Entrei em um grupo e agora quero sair, tem como?",
            "Sim! Se você entrou em um grupo de carona e mudou de ideia, é só entrar no grupo e clicar no botão 'Sair'. Sem complicação!",
          ),
          _buildFaqItem(
            "O que fazer se eu tiver algum problema com a carona ou motorista?",
            "Em breve teremos a opção de reportar usuários. Fique ligado nas atualizações do app para essa função!",
          ),
          _buildFaqItem(
            "Como funciona a avaliação dos motoristas e caronas?",
            "Em breve também será possível avaliar tanto motoristas quanto passageiros. Fique de olho nas atualizações para saber quando essa funcionalidade estará disponível!",
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
