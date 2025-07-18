// lib/controllers/pokemon_list_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/repositories/pokemon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOrder { id, name }

class PokemonListController {
  final PokemonRepository _repository = PokemonRepository();
  final String _apiUrl;
  final String _cacheFileName;

  // Notifiers para o estado que a View irá ouvir
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<String> error = ValueNotifier('');
  final ValueNotifier<List<Pokemon>> filteredPokemonList = ValueNotifier([]);

  // Estados internos do controller
  List<Pokemon> _pokemonList = [];
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.id;
  String? _selectedType;
  bool _showLegendaries = false;
  bool _showMythicals = false;

  // Flag pública (via notifier) para a UI saber se deve mostrar shiny
  final ValueNotifier<bool> showShinies = ValueNotifier(false);

  // CORREÇÃO: Getters públicos para expor o estado interno à View
  String? get selectedType => _selectedType;
  SortOrder get sortOrder => _sortOrder;
  bool get showLegendaries => _showLegendaries;
  bool get showMythicals => _showMythicals;

  PokemonListController(this._apiUrl, String title)
    : _cacheFileName = 'pokemon_cache_${title.replaceAll(' ', '_')}.json' {
    loadData();
  }

  // --- LÓGICA DE DADOS ---

  Future<void> loadData() async {
    isLoading.value = true;
    error.value = '';

    final cachedData = await _loadPokemonFromCache();
    if (cachedData != null) {
      _pokemonList = cachedData;
      _applyFiltersAndSort();
      isLoading.value = false;
      return;
    }

    await _fetchFromApi();
  }

  Future<void> _fetchFromApi() async {
    try {
      final fetchedList = await _repository.getPokemonList(_apiUrl);
      _pokemonList = fetchedList;
      await _savePokemonToCache(fetchedList);
      _applyFiltersAndSort();
    } catch (e) {
      error.value = 'Erro ao buscar dados. Verifique a conexão.';
    } finally {
      isLoading.value = false;
    }
  }

  // --- LÓGICA DE FILTROS E ORDENAÇÃO ---

  void _applyFiltersAndSort() {
    List<Pokemon> tempList = List.from(_pokemonList);

    if (_searchQuery.isNotEmpty) {
      tempList = tempList.where((pokemon) {
        return pokemon.name.toLowerCase().contains(_searchQuery) ||
            pokemon.id.contains(_searchQuery);
      }).toList();
    }

    if (_selectedType != null) {
      tempList = tempList
          .where((p) => p.types.contains(_selectedType))
          .toList();
    }

    if (_showLegendaries) {
      tempList = tempList.where((p) => p.isLegendary && !p.isMythical).toList();
    }

    if (_showMythicals) {
      tempList = tempList.where((p) => p.isMythical).toList();
    }

    if (_sortOrder == SortOrder.name) {
      tempList.sort((a, b) => a.name.compareTo(b.name));
    } else {
      tempList.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    }

    filteredPokemonList.value = tempList;
  }

  void onSearchChanged(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndSort();
  }

  void updateFilters({
    String? newSelectedType,
    SortOrder? newSortOrder,
    bool? newShowLegendaries,
    bool? newShowMythicals,
    bool? newShowShinies,
  }) {
    // Atualiza as variáveis privadas
    _selectedType = newSelectedType;
    _sortOrder = newSortOrder ?? _sortOrder;
    _showLegendaries = newShowLegendaries ?? _showLegendaries;
    _showMythicals = newShowMythicals ?? _showMythicals;
    showShinies.value = newShowShinies ?? showShinies.value;

    _applyFiltersAndSort();
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_cacheFileName');
  }

  Future<void> _savePokemonToCache(List<Pokemon> pokemonList) async {
    final file = await _getLocalFile();
    final jsonList = pokemonList.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheFileName, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Pokemon>?> _loadPokemonFromCache() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return null;

      final prefs = await SharedPreferences.getInstance();
      final cacheTimestamp = prefs.getInt(_cacheFileName) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - cacheTimestamp > const Duration(hours: 24).inMilliseconds) {
        return null;
      }
      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List;
      return jsonList.map((json) => Pokemon.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    isLoading.dispose();
    error.dispose();
    filteredPokemonList.dispose();
    showShinies.dispose();
  }
}
