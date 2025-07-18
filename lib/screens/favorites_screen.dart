// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/controllers/favorites_controller.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/screens/pokedex_page_view.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart';
import 'package:pokedex_app/widgets/loading_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.loadFavorites, // Ação delegada ao controller
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const LoadingScreen(
              message: 'Procurando seus Pokémon favoritos...',
            );
          }
          return ValueListenableBuilder<String>(
            valueListenable: _controller.error,
            builder: (context, error, _) {
              if (error.isNotEmpty) {
                return Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                );
              }
              return ValueListenableBuilder<List<Pokemon>>(
                valueListenable: _controller.favoritePokemonList,
                builder: (context, favoritesList, _) {
                  if (favoritesList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Você ainda não adicionou Pokémon aos favoritos.\nToque na estrela na página de um Pokémon!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: favoritesList.length,
                    itemBuilder: (context, index) {
                      final pokemon = favoritesList[index];
                      return PokemonCard(
                        pokemon: pokemon,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokedexPageView(
                                pokemonList: favoritesList,
                                initialIndex: index,
                              ),
                            ),
                          ).then(
                            (_) => _controller.loadFavorites(),
                          ); // Recarrega ao voltar
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
