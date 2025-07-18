import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/models/pokemon_move_model.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart';
import 'package:pokedex_app/utils/string_extensions.dart';

class MoveCard extends StatelessWidget {
  final MoveDetail move;

  const MoveCard({super.key, required this.move});

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getColorForType(move.type);
    final typeIcon = getIconForType(move.type);

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -60,
            bottom: -60,
            child: Container(
              width: 210,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 0,
            bottom: 0,
            child: SvgPicture.asset(
              typeIcon,
              width: 90,
              height: 90,
              colorFilter: ColorFilter.mode(
                typeColor.withOpacity(0.8),
                BlendMode.srcIn,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 120, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  move.name.replaceAll('-', ' ').capitalize(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                TypeChip(type: move.type),
                const SizedBox(height: 8),

                // Usamos espaçamento fixo com SizedBox para um controlo preciso.
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Alinha todos ao início
                  children: [
                    _buildStatColumn(
                      'POWER',
                      move.power?.toString() ?? '-',
                      typeColor,
                    ),
                    const SizedBox(width: 24), // Espaço fixo
                    _buildStatColumn(
                      'ACCURACY',
                      move.accuracy?.toString() ?? '-',
                      typeColor,
                    ),
                    const SizedBox(width: 24), // Espaço fixo
                    _buildStatColumn('PP', move.pp.toString(), typeColor),
                  ],
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (move.effect.isNotEmpty) ...[
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        const SizedBox(height: 4),
                        Text(
                          move.effect,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
