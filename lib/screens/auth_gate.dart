// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/screens/generation_screen.dart';
import 'package:pokedex_app/screens/login_screen.dart';
import 'package:pokedex_app/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Enquanto espera pela primeira informação do stream, mostra um loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o snapshot tem dados, significa que um utilizador está logado
        if (snapshot.hasData) {
          final user = snapshot.data!;
          final creationTimestamp =
              user.metadata.creationTime?.millisecondsSinceEpoch;
          final lastSignInTimestamp =
              user.metadata.lastSignInTime?.millisecondsSinceEpoch;

          // --- AQUI ESTÁ A LÓGICA CHAVE ---
          // Verifica se o utilizador foi acabado de criar.
          // Um utilizador novo tem a data de criação muito próxima (ou igual) à data do último login.
          // Adicionamos uma margem de 2 segundos para segurança.
          if (creationTimestamp != null &&
              lastSignInTimestamp != null &&
              (lastSignInTimestamp - creationTimestamp).abs() < 2000) {
            // Se for um utilizador novo, o nosso AuthService está a fazer o logout em segundo plano.
            // Em vez de mostrar a GenerationScreen (o "flash"), mostramos um loading.
            // O stream irá em breve emitir um novo evento (utilizador nulo) e este widget
            // irá reconstruir, mostrando a LoginScreen como desejado.
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Para qualquer outro utilizador já autenticado, mostra a tela principal.
          return const GenerationScreen();
        }

        // Se não há utilizador, mostra a tela de login.
        return const LoginScreen();
      },
    );
  }
}
