// lib/screens/move_detail_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/models/pokemon_move_model.dart';
import 'package:pokedex_app/repositories/pokemon_repository.dart'; // Importa o repositório
import 'package:pokedex_app/screens/pokedex_page_view.dart';
import 'package:pokedex_app/theme/app_theme.dart';
import 'package:pokedex_app/widgets/loading_screen.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoveDetailScreen extends StatefulWidget {
  final MoveDetail moveDetail;

  const MoveDetailScreen({super.key, required this.moveDetail});

  @override
  State<MoveDetailScreen> createState() => _MoveDetailScreenState();
}

class _MoveDetailScreenState extends State<MoveDetailScreen> {
  // NOVO: Instância do nosso repositório
  final PokemonRepository _repository = PokemonRepository();

  List<Pokemon> _learnedByPokemon = [];
  bool _isLoading = true;
  String _error = '';

  // A lógica de cache também permanece aqui por enquanto
  String get _cacheKey => 'move_learned_by_${widget.moveDetail.name}';

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_cacheKey.json');
  }

  Future<void> _savePokemonToCache(List<Pokemon> pokemonList) async {
    final file = await _getCacheFile();
    final jsonList = pokemonList.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<Pokemon>?> _loadPokemonFromCache() async {
    try {
      final file = await _getCacheFile();
      if (!await file.exists()) return null;

      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List;
      return jsonList.map((json) => Pokemon.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cachedData = await _loadPokemonFromCache();
    if (cachedData != null && mounted) {
      setState(() {
        _learnedByPokemon = cachedData;
        _isLoading = false;
      });
      return;
    }
    await _fetchFromApi();
  }

  // MÉTODO ATUALIZADO: Agora usa o repositório
  Future<void> _fetchFromApi() async {
    try {
      final pokemonList = await _repository.getPokemonLearnedByMove(
        widget.moveDetail.name,
      );

      await _savePokemonToCache(pokemonList);

      if (mounted) {
        setState(() {
          _learnedByPokemon = pokemonList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar os Pokémon.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (O resto do build permanece igual)
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(title: Text(widget.moveDetail.name.capitalize())),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _MoveDetailsCard(move: widget.moveDetail)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Aprendido por:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: LoadingScreen(message: 'Buscando Pokémon...')),
      );
    }
    if (_error.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(_error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (_learnedByPokemon.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text("Nenhum Pokémon conhecido aprende este golpe."),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final pokemon = _learnedByPokemon[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokedexPageView(
                    pokemonList: _learnedByPokemon,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );
        }, childCount: _learnedByPokemon.length),
      ),
    );
  }
}

// ... (Resto do ficheiro _MoveDetailsCard, etc., continua igual)
class _MoveDetailsCard extends StatelessWidget {
  final MoveDetail move;
  const _MoveDetailsCard({required this.move});

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getColorForType(move.type);
    IconData categoryIcon;
    String categoryText;

    switch (move.damageClass) {
      case 'physical':
        categoryIcon = Icons.sports_kabaddi;
        categoryText = 'Físico';
        break;
      case 'special':
        categoryIcon = Icons.flare;
        categoryText = 'Especial';
        break;
      default:
        categoryIcon = Icons.shield_outlined;
        categoryText = 'Status';
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TypeChip(type: move.type),
              Row(
                children: [
                  Icon(categoryIcon, color: AppTheme.darkText.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text(
                    categoryText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'POWER',
                move.power?.toString() ?? '-',
                typeColor,
              ),
              _buildStatColumn(
                'ACCURACY',
                move.accuracy?.toString() ?? '-',
                typeColor,
              ),
              _buildStatColumn('PP', move.pp.toString(), typeColor),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(
            'Efeito do Golpe',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            move.effect,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.darkText.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return split('-')
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
