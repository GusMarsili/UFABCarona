import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bottom_nav_cubit.dart';
import '../pages/login_page.dart';
import 'main_wrapper.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto aguarda a verificação, exibe um loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Se o usuário estiver logado, direciona para a tela principal
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return BlocProvider(
            create: (context) => BottomNavCubit(),
            child: MainWrapper(user: user),
          );
        }
        // Caso contrário, direciona para a tela de login
        return const LoginScreen();
      },
    );
  }
}