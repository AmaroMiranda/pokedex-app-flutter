// lib/screens/generation_screen.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/controllers/auth_controller.dart';
import 'package:pokedex_app/screens/favorites_screen.dart';
import 'package:pokedex_app/screens/pokemon_list_screen.dart';
import 'package:pokedex_app/theme/app_theme.dart';
import 'package:pokedex_app/widgets/generation_card.dart';

class GenerationScreen extends StatelessWidget {
  const GenerationScreen({super.key});

  void _navigateToPokemonList(
    BuildContext context,
    String title,
    String apiUrl,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonListScreen(title: title, apiUrl: apiUrl),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(
    BuildContext context,
    AuthController authController,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Confirmar Saída',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: const Text('Você tem a certeza que deseja sair?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Não',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Sim, Sair',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                authController.signOut();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    final List<Map<String, dynamic>> regions = [
      {
        'title': 'Kanto',
        'genId': '1',
        'icon': 'assets/icons/kanto.svg',
        'color': const Color(0xFF5DB962),
      },
      {
        'title': 'Johto',
        'genId': '2',
        'icon': 'assets/icons/johto.svg',
        'color': const Color(0xFFF7D55E),
      },
      {
        'title': 'Hoenn',
        'genId': '3',
        'icon': 'assets/icons/hoenn.svg',
        'color': const Color(0xFF4EC2A9),
      },
      {
        'title': 'Sinnoh',
        'genId': '4',
        'icon': 'assets/icons/sinnoh.svg',
        'color': const Color(0xFF8175CE),
      },
      {
        'title': 'Unova',
        'genId': '5',
        'icon': 'assets/icons/unova.svg',
        'color': const Color(0xFF5A5A5A),
      },
      {
        'title': 'Kalos',
        'genId': '6',
        'icon': 'assets/icons/kalos.svg',
        'color': const Color(0xFFD8635B),
      },
      {
        'title': 'Alola',
        'genId': '7',
        'icon': 'assets/icons/alola.svg',
        'color': const Color(0xFF5AB6D3),
      },
      {
        'title': 'Galar',
        'genId': '8',
        'icon': 'assets/icons/galar.svg',
        'color': const Color(0xFFC75A8E),
      },
    ];

    final Map<String, dynamic> generations = {
      'Geração I': {
        'id': '1',
        'starters': ['1', '4', '7'],
      },
      'Geração II': {
        'id': '2',
        'starters': ['152', '155', '158'],
      },
      'Geração III': {
        'id': '3',
        'starters': ['252', '255', '258'],
      },
      'Geração IV': {
        'id': '4',
        'starters': ['387', '390', '393'],
      },
      'Geração V': {
        'id': '5',
        'starters': ['495', '498', '501'],
      },
      'Geração VI': {
        'id': '6',
        'starters': ['650', '653', '656'],
      },
      'Geração VII': {
        'id': '7',
        'starters': ['722', '725', '728'],
      },
      'Geração VIII': {
        'id': '8',
        'starters': ['810', '813', '816'],
      },
    };

    const double childAspectRatio = 1.6;

    return Scaffold(
      appBar: AppBar(
        // CORREÇÃO: Aplicando o estilo ao título do AppBar
        title: const Text('MaroDéx'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Pokemon',
          fontSize: 28,
          color: Colors.white,
          letterSpacing: 3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              _showLogoutConfirmationDialog(context, authController);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: GenerationCard(
                        title: 'Todos',
                        iconAsset: 'assets/icons/pokeball.svg',
                        color: AppTheme.primaryRed,
                        onTap: () => _navigateToPokemonList(
                          context,
                          'Todos os Pokémon',
                          'https://pokeapi.co/api/v2/pokemon?limit=1025',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: GenerationCard(
                        title: 'Favoritos',
                        iconAsset: 'assets/icons/star.svg',
                        color: const Color(0xFFFFD700),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _SectionTitle(title: 'Regiões'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.4,
              children: regions.map((region) {
                final apiUrl =
                    'https://pokeapi.co/api/v2/generation/${region['genId']}/';
                return GenerationCard(
                  key: ValueKey(region['title']),
                  title: region['title']!,
                  iconAsset: region['icon']!,
                  color: region['color'] as Color,
                  onTap: () =>
                      _navigateToPokemonList(context, region['title']!, apiUrl),
                );
              }).toList(),
            ),
          ),
          const _SectionTitle(title: 'Gerações'),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: generations.entries.map((entry) {
                final title = entry.key;
                final data = entry.value;
                final genId = data['id'] as String;
                final starterIds = List<String>.from(data['starters']);
                final apiUrl = 'https://pokeapi.co/api/v2/generation/$genId/';

                return GenerationCard(
                  key: ValueKey(title),
                  title: title,
                  starterIds: starterIds,
                  onTap: () => _navigateToPokemonList(context, title, apiUrl),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
