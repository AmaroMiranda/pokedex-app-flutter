import 'package:flutter/foundation.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/repositories/pokemon_repository.dart';
import 'package:pokedex_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController {
  final PokemonRepository _repository = PokemonRepository();
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<String> error = ValueNotifier('');
  final ValueNotifier<List<Pokemon>> favoritePokemonList = ValueNotifier([]);

  FavoritesController() {
    loadFavorites();
  }

  bool get _isAnonymousUser => _auth.currentUser?.isAnonymous ?? true;

  Future<void> loadFavorites() async {
    isLoading.value = true;
    error.value = '';

    try {
      List<String> favoriteIds;

      if (_isAnonymousUser) {
        final prefs = await SharedPreferences.getInstance();
        favoriteIds = prefs.getStringList('favorite_pokemon') ?? [];
      } else {
        favoriteIds = await _dbService.getFavoriteIds();
      }

      if (favoriteIds.isEmpty) {
        favoritePokemonList.value = [];
      } else {
        final pokemonList = await _repository.getPokemonListByIds(favoriteIds);
        favoritePokemonList.value = pokemonList;
      }
    } catch (e) {
      debugPrint("Erro no FavoritesController: $e");
      error.value = 'Erro ao carregar favoritos.';
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    isLoading.dispose();
    error.dispose();
    favoritePokemonList.dispose();
  }
}
