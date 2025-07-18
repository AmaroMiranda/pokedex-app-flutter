import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/theme/app_theme.dart';

class GenerationCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final List<String>? starterIds;
  final String? iconAsset;
  final Color? color;

  const GenerationCard({
    super.key,
    required this.title,
    required this.onTap,
    this.starterIds,
    this.iconAsset,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (iconAsset != null) {
      return _buildAllPokemonCard(context);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -130,
              top: -110,
              bottom: -110,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 16,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 2,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: (starterIds ?? [])
                    .map(
                      (id) => Flexible(
                        child: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPokemonCard(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryRed;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      // --- CORREÇÃO ADICIONADA AQUI ---
      // Define a cor de fundo do card como branca para ser consistente.
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -50,
              top: -50,
              bottom: -50,
              child: Container(
                width: 170,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 0,
              bottom: 0,
              child: SvgPicture.asset(
                iconAsset!,
                width: 90,
                height: 90,
                colorFilter: ColorFilter.mode(
                  cardColor.withOpacity(0.8),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 20,
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
