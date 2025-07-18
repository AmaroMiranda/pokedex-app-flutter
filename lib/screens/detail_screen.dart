// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/controllers/detail_controller.dart';
import 'package:pokedex_app/models/pokemon_detail_model.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/screens/moveset_screen.dart';
import 'package:pokedex_app/screens/pokedex_page_view.dart';
import 'package:pokedex_app/theme/app_theme.dart';
import 'package:pokedex_app/widgets/detail_screen_widgets/abilities_section.dart';
import 'package:pokedex_app/widgets/detail_screen_widgets/evolutions_section.dart';
import 'package:pokedex_app/widgets/detail_screen_widgets/stats_section.dart';
import 'package:pokedex_app/widgets/loading_screen.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart';

// --- Classes de Modelo de Dados ---

class PokemonVariety {
  final String name;
  final String url;

  PokemonVariety({required this.name, required this.url});

  factory PokemonVariety.fromJson(Map<String, dynamic> json) => PokemonVariety(
    name: json['pokemon']['name'],
    url: json['pokemon']['url'],
  );

  // CORREÇÃO: Método toJson adicionado
  Map<String, dynamic> toJson() => {
    'pokemon': {'name': name, 'url': url},
  };
}

class EvolutionInfo {
  final String name;
  final String id;
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  EvolutionInfo({required this.name, required this.id});

  factory EvolutionInfo.fromJson(Map<String, dynamic> json) =>
      EvolutionInfo(name: json['name'], id: json['id']);

  // CORREÇÃO: Método toJson adicionado
  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}

// --- Tela Principal (View) ---

class DetailScreen extends StatefulWidget {
  final List<Pokemon> pokemonList;
  final int currentIndex;

  const DetailScreen({
    super.key,
    required this.pokemonList,
    required this.currentIndex,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with AutomaticKeepAliveClientMixin<DetailScreen> {
  @override
  bool get wantKeepAlive => true;

  late final DetailController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    final pokemonUrl = widget.pokemonList[widget.currentIndex].url;
    _controller = DetailController(pokemonUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    final soundUrl = _controller.pokemonDetail.value?.soundUrl;
    if (soundUrl != null) {
      await _audioPlayer.play(UrlSource(soundUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const LoadingScreen(message: 'Carregando detalhes...');
        }
        return ValueListenableBuilder<String>(
          valueListenable: _controller.error,
          builder: (context, error, _) {
            if (error.isNotEmpty) {
              return Scaffold(body: Center(child: Text('Erro: $error')));
            }
            return _buildContent();
          },
        );
      },
    );
  }

  Widget _buildContent() {
    return ValueListenableBuilder<PokemonDetail?>(
      valueListenable: _controller.pokemonDetail,
      builder: (context, pokemonDetail, _) {
        if (pokemonDetail == null) {
          return const Scaffold(
            body: Center(child: Text("Pokémon não encontrado.")),
          );
        }

        final typeColor = getBackgroundColorForType(pokemonDetail.types[0]);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [typeColor, Color.lerp(typeColor, Colors.black, 0.5)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(pokemonDetail),
            body: Stack(
              children: [
                _buildHeaderAndImage(pokemonDetail),
                DraggableScrollableSheet(
                  initialChildSize: 0.52,
                  minChildSize: 0.52,
                  maxChildSize: 0.8,
                  builder: (context, scrollController) {
                    return _buildDetailsSheet(
                      scrollController,
                      pokemonDetail,
                      typeColor,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(PokemonDetail pokemonDetail) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (pokemonDetail.shinyImageUrl != null)
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isShowingShiny,
            builder: (context, isShowingShiny, _) => IconButton(
              icon: Icon(
                Icons.auto_awesome_rounded,
                color: isShowingShiny ? Colors.yellow.shade600 : Colors.white,
                size: 28,
              ),
              onPressed: _controller.toggleShiny,
            ),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: _controller.isFavorite,
          builder: (context, isFavorite, _) => IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.yellow.shade600 : Colors.white,
              size: 30,
            ),
            onPressed: _controller.toggleFavorite,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.sports_martial_arts_outlined,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovesetScreen(pokemonDetail: pokemonDetail),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAndImage(PokemonDetail pokemonDetail) {
    // Agrupa elementos de fundo para evitar reconstruções desnecessárias
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: SvgPicture.asset(
            'assets/icons/pokeball.svg',
            width: 250,
            height: 250,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.07),
              BlendMode.srcIn,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  pokemonDetail.name.capitalize(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '#${pokemonDetail.id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 250),
            child: GestureDetector(
              onTap: _playSound,
              child: ValueListenableBuilder<bool>(
                valueListenable: _controller.isShowingShiny,
                builder: (context, isShowingShiny, _) => Image.network(
                  isShowingShiny && pokemonDetail.shinyImageUrl != null
                      ? pokemonDetail.shinyImageUrl!
                      : pokemonDetail.imageUrl,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSheet(
    ScrollController scrollController,
    PokemonDetail pokemonDetail,
    Color typeColor,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pokemonDetail.types
                  .map((type) => TypeChip(type: type))
                  .toList(),
            ),
            const SizedBox(height: 24),
            StatsSection(stats: pokemonDetail.stats, typeColor: typeColor),
            const SizedBox(height: 24),
            ValueListenableBuilder(
              valueListenable: _controller.abilityDetails,
              builder: (context, abilityDetails, _) => AbilitiesSection(
                abilities: pokemonDetail.abilities,
                abilityDetails: abilityDetails,
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder(
              valueListenable: _controller.evolutionLines,
              builder: (context, evolutionLines, _) => EvolutionsSection(
                evolutionLines: evolutionLines,
                currentPokemonId: pokemonDetail.id.toString(),
                fullPokemonList: widget.pokemonList,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Extensão para capitalização, útil para a UI
extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return split('-')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}
