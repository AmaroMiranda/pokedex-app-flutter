import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/screens/auth_gate.dart';
import 'package:pokedex_app/theme/app_theme.dart';

// Transforma o main em assíncrono para poder inicializar o Firebase
void main() async {
  // Garante que os widgets do Flutter estão prontos
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaroDéx',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // A tela inicial agora é o nosso portão de autenticação
      home: const AuthGate(),
    );
  }
}
