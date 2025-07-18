// lib/widgets/detail_screen_widgets/stats_section.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/models/pokemon_detail_model.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart'; // Para getColorForType

class StatsSection extends StatelessWidget {
  final List<PokemonStat> stats;
  final Color typeColor;

  const StatsSection({super.key, required this.stats, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Stats'),
        ...stats.map(
          (stat) => _StatRow(
            name: stat.name,
            value: stat.value,
            typeColor: typeColor,
          ),
        ),
      ],
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

class _StatRow extends StatelessWidget {
  final String name;
  final int value;
  final Color typeColor;

  const _StatRow({
    required this.name,
    required this.value,
    required this.typeColor,
  });

  String get _statAbbreviation {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'ATK';
      case 'defense':
        return 'DEF';
      case 'special-attack':
        return 'Sp. ATK';
      case 'special-defense':
        return 'Sp. DEF';
      case 'speed':
        return 'SPD';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _statAbbreviation,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 10,
                color: typeColor.withOpacity(0.2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width:
                        (value / 180).clamp(0, 1) *
                        MediaQuery.of(context).size.width,
                    color: typeColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
