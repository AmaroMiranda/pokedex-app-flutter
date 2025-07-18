import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/controllers/auth_controller.dart';
import 'package:pokedex_app/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildLoginOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      color: AppTheme.primaryRed,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/icons/pokeball.svg',
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.1),
                BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            child: Image.network(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png', // Charizard
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 80),
        // CORREÇÃO: Título com a nova fonte temática
        Text(
          'MaroDéx',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Pokemon', // Usando a nova fonte
            fontSize: 56,
            color: AppTheme.primaryRed,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha como iniciar a sua jornada',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.darkText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 40),
        ValueListenableBuilder<String>(
          valueListenable: _controller.error,
          builder: (context, error, _) {
            if (error.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildLoginButtons();
          },
        ),
      ],
    );
  }

  // CORREÇÃO: Botões extraídos para um método próprio para maior clareza
  Widget _buildLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botão de Login com Google estilizado
        ElevatedButton.icon(
          icon: SvgPicture.asset('assets/icons/google.svg', height: 22.0),
          label: const Text('Entrar com Google'),
          onPressed: _controller.signInWithGoogle,
          style: ElevatedButton.styleFrom(
            elevation: 2, // Sombra suave
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.darkText,
            minimumSize: const Size(double.infinity, 52),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Botão de Login Anónimo estilizado
        ElevatedButton.icon(
          icon: const Icon(Icons.person_outline, size: 26),
          label: const Text('Entrar como convidado'),
          onPressed: _controller.signInAnonymously,
          style: ElevatedButton.styleFrom(
            // Usa a cor primária do tema para este botão
            backgroundColor: AppTheme.primaryRed.withOpacity(0.9),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
