// lib/widgets/detail_screen_widgets/evolutions_section.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/screens/detail_screen.dart' show EvolutionInfo;
import 'package:pokedex_app/screens/pokedex_page_view.dart';

class EvolutionsSection extends StatelessWidget {
  final List<List<EvolutionInfo>> evolutionLines;
  final String currentPokemonId;
  final List<Pokemon> fullPokemonList; // Necessário para a navegação

  const EvolutionsSection({
    super.key,
    required this.evolutionLines,
    required this.currentPokemonId,
    required this.fullPokemonList,
  });

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split('-')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (evolutionLines.isEmpty) {
      return const Text("Este Pokémon não possui evoluções.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Evoluções'),
        const SizedBox(height: 16),
        ...evolutionLines.map((line) => _buildEvolutionLine(context, line)),
      ],
    );
  }

  Widget _buildEvolutionLine(BuildContext context, List<EvolutionInfo> line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(line.length * 2 - 1, (index) {
            if (index.isEven) {
              return _buildEvolutionCard(context, line[index ~/ 2]);
            }
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_right_alt, color: Colors.grey, size: 28),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEvolutionCard(BuildContext context, EvolutionInfo info) {
    final isCurrentPokemon = info.id == currentPokemonId;
    return GestureDetector(
      onTap: () {
        if (isCurrentPokemon) return;
        int targetIndex = fullPokemonList.indexWhere(
          (p) => p.name == info.name,
        );
        if (targetIndex != -1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => PokedexPageView(
                pokemonList: fullPokemonList,
                initialIndex: targetIndex,
              ),
              transitionsBuilder: (_, a, __, c) => c,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: isCurrentPokemon
              ? Border.all(color: Colors.indigo, width: 2.5)
              : null,
        ),
        child: Column(
          children: [
            Image.network(info.imageUrl, height: 70, width: 70),
            const SizedBox(height: 4),
            Text(
              _capitalize(info.name),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
