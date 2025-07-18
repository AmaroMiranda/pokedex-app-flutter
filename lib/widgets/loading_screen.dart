// lib/widgets/loading_screen.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/theme/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  final String message;

  const LoadingScreen({
    super.key,
    this.message = 'Carregando...', // Mensagem padrão
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container branco que cobre a tela toda
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/pikachu_running.gif', width: 100),
            const SizedBox(height: 20),
            Text(
              message, // Usa a mensagem recebida
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
