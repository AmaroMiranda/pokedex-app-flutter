import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokedex_app/models/pokemon_detail_model.dart';
import 'package:pokedex_app/repositories/pokemon_repository.dart';
import 'package:pokedex_app/screens/detail_screen.dart';
import 'package:pokedex_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailController {
  final PokemonRepository _repository = PokemonRepository();
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _initialPokemonUrl;

  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<String> error = ValueNotifier('');
  final ValueNotifier<bool> isFavorite = ValueNotifier(false);
  final ValueNotifier<bool> isShowingShiny = ValueNotifier(false);
  final ValueNotifier<PokemonDetail?> pokemonDetail = ValueNotifier(null);
  final ValueNotifier<List<List<EvolutionInfo>>> evolutionLines = ValueNotifier(
    [],
  );
  final ValueNotifier<Map<String, double>> damageMultipliers = ValueNotifier(
    {},
  );
  final ValueNotifier<Map<String, AbilityDetail>> abilityDetails =
      ValueNotifier({});
  final ValueNotifier<List<PokemonVariety>> varieties = ValueNotifier([]);

  DetailController(this._initialPokemonUrl) {
    loadPokemonData(_initialPokemonUrl);
  }

  bool get _isAnonymousUser => _auth.currentUser?.isAnonymous ?? true;

  void toggleShiny() {
    isShowingShiny.value = !isShowingShiny.value;
  }

  Future<void> toggleFavorite() async {
    if (pokemonDetail.value == null) return;
    final pokemonId = pokemonDetail.value!.id.toString();

    final currentValue = isFavorite.value;
    isFavorite.value = !currentValue; // Atualiza a UI imediatamente

    try {
      if (_isAnonymousUser) {
        await _toggleFavoriteLocally(pokemonId);
      } else {
        await _toggleFavoriteOnFirestore(pokemonId);
      }
    } catch (e) {
      isFavorite.value = currentValue; // Reverte em caso de erro
    }
  }

  Future<void> _loadFavoriteStatus() async {
    if (pokemonDetail.value == null) return;
    final pokemonId = pokemonDetail.value!.id.toString();

    if (_isAnonymousUser) {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorite_pokemon') ?? [];
      isFavorite.value = favoriteIds.contains(pokemonId);
    } else {
      isFavorite.value = await _dbService.isFavorite(pokemonId);
    }
  }

  // Funções auxiliares para maior clareza
  Future<void> _toggleFavoriteLocally(String pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_pokemon') ?? [];
    if (isFavorite.value) {
      favoriteIds.add(pokemonId);
    } else {
      favoriteIds.remove(pokemonId);
    }
    await prefs.setStringList('favorite_pokemon', favoriteIds);
  }

  Future<void> _toggleFavoriteOnFirestore(String pokemonId) async {
    if (isFavorite.value) {
      await _dbService.addFavorite(pokemonId);
    } else {
      await _dbService.removeFavorite(pokemonId);
    }
  }

  Future<void> loadPokemonData(String pokemonUrl) async {
    isLoading.value = true;
    error.value = '';
    pokemonDetail.value = null;
    isShowingShiny.value = false;

    try {
      final pokemonId = pokemonUrl.split('/')[pokemonUrl.split('/').length - 2];
      final cachedData = await _loadJsonFromCache(
        'pokemon_full_data_$pokemonId',
      );

      if (cachedData != null) {
        _loadAllDataFromCache(cachedData);
      } else {
        await _fetchAllDataFromApi(pokemonUrl);
      }
    } catch (e) {
      debugPrint("Erro no DetailController: $e"); // Para ajudar a depurar
      error.value = 'Erro ao buscar dados. Verifique a conexão.';
    } finally {
      isLoading.value = false;
    }
  }

  void _loadAllDataFromCache(Map<String, dynamic> cachedData) async {
    pokemonDetail.value = PokemonDetail.fromJson(cachedData['detail']);
    evolutionLines.value = (cachedData['evolutionLines'] as List)
        .map(
          (line) => (line as List)
              .map((info) => EvolutionInfo.fromJson(info))
              .toList(),
        )
        .toList();
    damageMultipliers.value = Map<String, double>.from(
      cachedData['damageMultipliers'],
    );
    abilityDetails.value = (cachedData['abilityDetails'] as Map).map(
      (k, v) => MapEntry(k, AbilityDetail.fromJson(v)),
    );
    varieties.value = (cachedData['varieties'] as List)
        .map((v) => PokemonVariety.fromJson(v))
        .toList();
    await _loadFavoriteStatus();
  }

  Future<void> _fetchAllDataFromApi(String pokemonUrl) async {
    final allData = await _repository.getPokemonDetailData(pokemonUrl);

    pokemonDetail.value = allData['detail'];
    evolutionLines.value = allData['evolutionLines'];
    damageMultipliers.value = allData['damageMultipliers'];
    abilityDetails.value = allData['abilityDetails'];
    varieties.value = allData['varieties'];

    await _loadFavoriteStatus();

    final fullDataToCache = {
      'detail': (allData['detail'] as PokemonDetail).toJson(),
      'evolutionLines': (allData['evolutionLines'] as List<List<EvolutionInfo>>)
          .map((line) => line.map((info) => info.toJson()).toList())
          .toList(),
      'damageMultipliers': allData['damageMultipliers'],
      'abilityDetails':
          (allData['abilityDetails'] as Map<String, AbilityDetail>).map(
            (k, v) => MapEntry(k, v.toJson()),
          ),
      'varieties': (allData['varieties'] as List<PokemonVariety>)
          .map((v) => v.toJson())
          .toList(),
    };
    final pokemonId = (allData['detail'] as PokemonDetail).id.toString();
    await _saveJsonToCache('pokemon_full_data_$pokemonId', fullDataToCache);
  }

  Future<File> _getCacheFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<void> _saveJsonToCache(String key, Map<String, dynamic> data) async {
    final file = await _getCacheFile('$key.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> _loadJsonFromCache(String key) async {
    try {
      final file = await _getCacheFile('$key.json');
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    isLoading.dispose();
    error.dispose();
    isFavorite.dispose();
    isShowingShiny.dispose();
    pokemonDetail.dispose();
    evolutionLines.dispose();
    damageMultipliers.dispose();
    abilityDetails.dispose();
    varieties.dispose();
  }
}
