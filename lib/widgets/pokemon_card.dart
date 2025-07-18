// lib/widgets/pokemon_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/pokemon_model.dart';

Color getColorForType(String type) {
  switch (type.toLowerCase()) {
    case 'grass':
      return const Color(0xFF4CAF50);
    case 'fire':
      return const Color(0xFFF44336);
    case 'water':
      return const Color(0xFF2196F3);
    case 'bug':
      return const Color(0xFF8BC34A);
    case 'normal':
      return const Color(0xFFA8A77A);
    case 'poison':
      return const Color(0xFF9C27B0);
    case 'electric':
      return const Color(0xFFFFEB3B);
    case 'ground':
      return const Color(0xFF795548);
    case 'fairy':
      return const Color(0xFFE91E63);
    case 'fighting':
      return const Color(0xFFE65100);
    case 'psychic':
      return const Color(0xFFF50057);
    case 'rock':
      return const Color(0xFF616161);
    case 'ghost':
      return const Color(0xFF673AB7);
    case 'ice':
      return const Color(0xFF00BCD4);
    case 'dragon':
      return const Color(0xFF3F51B5);
    default:
      return Colors.grey;
  }
}

String getIconForType(String type) {
  return 'assets/icons/${type.toLowerCase()}.svg';
}

Color getBackgroundColorForType(String type) {
  switch (type.toLowerCase()) {
    case 'grass':
      return const Color(0xFF2D6A30);
    case 'fire':
      return const Color(0xFFB22A22);
    case 'water':
      return const Color(0xFF1A5A95);
    case 'bug':
      return const Color(0xFF63802D);
    case 'normal':
      return const Color(0xFF7C7B5B);
    case 'poison':
      return const Color(0xFF751F8D);
    case 'electric':
      return const Color(0xFFB5A224);
    case 'ground':
      return const Color(0xFF9E7756);
    case 'fairy':
      return const Color(0xFFB21C4A);
    case 'fighting':
      return const Color(0xFF9E400E);
    case 'psychic':
      return const Color(0xFFC70041);
    case 'rock':
      return const Color(0xFF4C4A48);
    case 'ghost':
      return const Color(0xFF502E8A);
    case 'ice':
      return const Color(0xFF00899D);
    case 'dragon':
      return const Color(0xFF333D8A);
    default:
      return Colors.grey.shade800;
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;
  final bool showShiny; // NOVO: Flag para mostrar a versão Shiny

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    this.showShiny = false, // NOVO: Valor padrão é false
  });

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';
    final typeColor = getColorForType(primaryType);

    // NOVO: Determina qual URL de imagem usar
    final imageUrl = (showShiny && pokemon.shinyImageUrl != null)
        ? pokemon.shinyImageUrl!
        : pokemon.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -60,
              bottom: -60,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 16,
              right: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#${pokemon.id.padLeft(3, '0')}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: pokemon.types
                        .map((type) => TypeChip(type: type))
                        .toList(),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 5,
              top: 0,
              bottom: 0,
              child: Image.network(
                imageUrl, // ALTERADO: Usa a URL determinada acima
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red, size: 40);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypeChip extends StatelessWidget {
  final String type;
  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final typeColor = getColorForType(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            getIconForType(type),
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(typeColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              color: typeColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
