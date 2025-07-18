// lib/widgets/detail_screen_widgets/abilities_section.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/models/pokemon_detail_model.dart';
import 'package:pokedex_app/theme/app_theme.dart';

class AbilitiesSection extends StatelessWidget {
  final List<PokemonAbility> abilities;
  final Map<String, AbilityDetail> abilityDetails;

  const AbilitiesSection({
    super.key,
    required this.abilities,
    required this.abilityDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Habilidades'),
        ...abilities.map((ability) => _buildAbilityRow(context, ability)),
      ],
    );
  }

  Widget _buildAbilityRow(BuildContext context, PokemonAbility ability) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _capitalize(ability.name),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              final detail = abilityDetails[ability.name];
              if (detail != null) _showAbilityInfoDialog(context, detail);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.info_outline,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbilityInfoDialog(
    BuildContext context,
    AbilityDetail abilityDetail,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _capitalize(abilityDetail.name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              abilityDetail.description,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkText.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split('-')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
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
