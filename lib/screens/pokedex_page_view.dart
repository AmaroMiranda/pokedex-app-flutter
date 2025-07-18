// lib/screens/pokedex_page_view.dart
import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import 'detail_screen.dart';

class PokedexPageView extends StatefulWidget {
  final List<Pokemon> pokemonList;
  final int initialIndex;

  const PokedexPageView({
    super.key,
    required this.pokemonList,
    required this.initialIndex,
  });

  @override
  State<PokedexPageView> createState() => _PokedexPageViewState();
}

class _PokedexPageViewState extends State<PokedexPageView> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = widget.pokemonList[index];
        // --- CORREÇÃO AQUI ---
        // Adicionamos uma Key única para cada tela, usando o nome do Pokémon.
        // Isso ajuda o Flutter a gerenciar as telas corretamente.
        return DetailScreen(
          key: ValueKey(pokemon.name), // Chave única
          pokemonList: widget.pokemonList,
          currentIndex: index,
        );
      },
    );
  }
}
