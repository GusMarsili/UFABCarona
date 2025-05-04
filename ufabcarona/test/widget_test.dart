import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Imports do seu app
import 'package:ufabcarona/bloc/bottom_nav_cubit.dart';
import 'package:ufabcarona/widget/authgate.dart';
import 'package:ufabcarona/widget/main_wrapper.dart';

// Mocks e placeholders para testes
class MockUser extends Mock implements User {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final Stream<User?> authStream;

  MockFirebaseAuth({required this.authStream});

  @override
  Stream<User?> authStateChanges() => authStream;
}

// Páginas mockadas para simular a navegação
class CaronasPage extends StatelessWidget {
  final User user;
  const CaronasPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Página de Caronas'));
}

class UberPage extends StatelessWidget {
  final User user;
  const UberPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Página de UBER'));
}

class ReservasPage extends StatelessWidget {
  final User user;
  const ReservasPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Página de Reservas'));
}

class PerfilPage extends StatelessWidget {
  final User user;
  const PerfilPage({super.key, required this.user});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Página de Perfil'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthGate Widget Test', () {
    testWidgets('Mostra a tela de login quando o usuário não está autenticado', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(), // Você pode adicionar um Provider aqui se precisar injetar mockAuth
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Login'), findsOneWidget); // Adapte o texto conforme sua LoginScreen
    });

    testWidgets('Mostra MainWrapper quando o usuário está autenticado', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => BottomNavCubit(),
            child: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(MainWrapper), findsOneWidget);
    });
  });

  group('MainWrapper Navegação', () {
    testWidgets('Navega entre páginas ao tocar nos ícones', (WidgetTester tester) async {
      final mockUser = MockUser();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => BottomNavCubit(),
            child: MainWrapper(user: mockUser),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Página de Caronas'), findsOneWidget);

      // Vai para UBER
      await tester.tap(find.text('UBER'));
      await tester.pumpAndSettle();
      expect(find.text('Página de UBER'), findsOneWidget);

      // Vai para Reservas
      await tester.tap(find.text('Reservas'));
      await tester.pumpAndSettle();
      expect(find.text('Página de Reservas'), findsOneWidget);

      // Vai para Perfil
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Página de Perfil'), findsOneWidget);
    });
  });
}