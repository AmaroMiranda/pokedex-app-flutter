// lib/repositories/pokemon_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex_app/models/pokemon_detail_model.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/models/pokemon_move_model.dart';
import 'package:pokedex_app/screens/detail_screen.dart'; // Importa os modelos de dados locais

class PokemonRepository {
  final String _baseUrl = 'https://pokeapi.co/api/v2';

  // Busca uma lista de Pokémon de uma URL específica
  Future<List<Pokemon>> getPokemonList(String apiUrl) async {
    try {
      final listResponse = await http.get(Uri.parse(apiUrl));
      if (listResponse.statusCode != 200) {
        throw Exception('Falha ao carregar a lista de Pokémon');
      }

      final listData = json.decode(listResponse.body);

      // A API retorna a lista em 'pokemon_species' para gerações/regiões
      // e em 'results' para a lista de todos os pokémons.
      final pokemonEntries =
          (listData['pokemon_species'] ?? listData['results']) as List;

      final futures = pokemonEntries.map((entry) {
        // CORREÇÃO: A chave 'url' existe diretamente no objeto 'entry',
        // independentemente de vir de 'pokemon_species' ou 'results'.
        final String urlToFetch = entry['url'];

        // A função _fetchPokemonSummary já sabe como lidar com os dois tipos de URL
        // (/pokemon/ e /pokemon-species/)
        return _fetchPokemonSummary(urlToFetch);
      }).toList();

      final results = await Future.wait(futures);
      // Remove quaisquer resultados nulos que possam ter ocorrido devido a erros
      return results.whereType<Pokemon>().toList();
    } catch (e) {
      print('Erro em getPokemonList: $e');
      throw Exception('Erro ao buscar a lista de Pokémon: $e');
    }
  }

  // Busca os dados resumidos de um único Pokémon para ser exibido nos cartões.
  Future<Pokemon?> _fetchPokemonSummary(String url) async {
    try {
      Map<String, dynamic> pokemonData;
      Map<String, dynamic> speciesData;
      String finalPokemonUrl;

      if (url.contains('pokemon-species')) {
        final speciesResponse = await http.get(Uri.parse(url));
        if (speciesResponse.statusCode != 200) return null;
        speciesData = json.decode(speciesResponse.body);

        finalPokemonUrl = (speciesData['varieties'] as List).firstWhere(
          (v) => v['is_default'],
        )['pokemon']['url'];

        final pokemonResponse = await http.get(Uri.parse(finalPokemonUrl));
        if (pokemonResponse.statusCode != 200) return null;
        pokemonData = json.decode(pokemonResponse.body);
      } else {
        finalPokemonUrl = url;
        final pokemonResponse = await http.get(Uri.parse(finalPokemonUrl));
        if (pokemonResponse.statusCode != 200) return null;
        pokemonData = json.decode(pokemonResponse.body);

        final speciesUrlFromPokemon = pokemonData['species']['url'];
        final speciesResponse = await http.get(
          Uri.parse(speciesUrlFromPokemon),
        );
        if (speciesResponse.statusCode != 200) return null;
        speciesData = json.decode(speciesResponse.body);
      }

      final imageUrl =
          pokemonData['sprites']['other']['official-artwork']['front_default'];
      final finalImageUrl = imageUrl ?? pokemonData['sprites']['front_default'];
      final shinyImageUrl =
          pokemonData['sprites']['other']['official-artwork']['front_shiny'];

      if (finalImageUrl == null) return null;

      return Pokemon(
        name: pokemonData['name'],
        url: finalPokemonUrl,
        types: (pokemonData['types'] as List)
            .map((typeInfo) => typeInfo['type']['name'] as String)
            .toList(),
        imageUrl: finalImageUrl,
        shinyImageUrl: shinyImageUrl,
        isLegendary: speciesData['is_legendary'] ?? false,
        isMythical: speciesData['is_mythical'] ?? false,
      );
    } catch (e) {
      print("Erro ao buscar dados de resumo para a URL: $url. Erro: $e");
      return null;
    }
  }

  // Busca os detalhes de um golpe
  Future<MoveDetail> getMoveDetail(String moveUrl) async {
    final response = await http.get(Uri.parse(moveUrl));
    if (response.statusCode == 200) {
      return MoveDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar detalhes do golpe.');
    }
  }

  // Busca a lista de Pokémon que aprendem um determinado golpe
  Future<List<Pokemon>> getPokemonLearnedByMove(String moveName) async {
    final moveUrl =
        '$_baseUrl/move/${moveName.toLowerCase().replaceAll(' ', '-')}/';
    final moveResponse = await http.get(Uri.parse(moveUrl));
    if (moveResponse.statusCode != 200) {
      throw Exception('Falha ao carregar dados do golpe');
    }

    final moveData = json.decode(moveResponse.body);
    final learnedByList = moveData['learned_by_pokemon'] as List;

    final futures = learnedByList.map((entry) async {
      final pokemonUrl = entry['url'] as String;
      return await _fetchPokemonSummary(pokemonUrl);
    }).toList();

    final results = await Future.wait(futures);
    final pokemonList = results.whereType<Pokemon>().toList();
    pokemonList.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    return pokemonList;
  }

  // Busca todos os dados necessários para a tela de detalhes
  Future<Map<String, dynamic>> getPokemonDetailData(String pokemonUrl) async {
    final detailResponse = await http.get(Uri.parse(pokemonUrl));
    if (detailResponse.statusCode != 200) throw ('Falha ao carregar detalhes');
    final detailJson = json.decode(detailResponse.body);
    final detailData = PokemonDetail.fromApiJson(detailJson);

    final speciesResponse = await http.get(Uri.parse(detailData.speciesUrl));
    if (speciesResponse.statusCode != 200) throw ('Falha ao carregar espécie');
    final speciesData = json.decode(speciesResponse.body);

    final newVarieties = (speciesData['varieties'] as List)
        .map((v) => PokemonVariety.fromJson(v))
        .toList();

    final typeFutures = detailData.types
        .map((type) => http.get(Uri.parse('$_baseUrl/type/$type')))
        .toList();

    final abilityFutures = detailData.abilities
        .map((ability) => http.get(Uri.parse(ability.url)))
        .toList();

    final responses = await Future.wait([...typeFutures, ...abilityFutures]);
    final typeResponses = responses.sublist(0, typeFutures.length);
    final abilityResponses = responses.sublist(typeFutures.length);

    final multipliers = _calculateDamageRelations(typeResponses);

    final newAbilityDetails = {
      for (var res in abilityResponses)
        json.decode(res.body)['name'] as String: AbilityDetail.fromJson(
          json.decode(res.body),
        ),
    };

    final evolutionChainUrl = speciesData['evolution_chain']['url'];
    final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
    if (evolutionResponse.statusCode != 200) {
      throw ('Falha ao carregar evolução');
    }
    final evolutionData = json.decode(evolutionResponse.body)['chain'];
    final newEvolutionLines = _parseEvolutions(evolutionData);

    return {
      'detail': detailData,
      'evolutionLines': newEvolutionLines,
      'damageMultipliers': multipliers,
      'abilityDetails': newAbilityDetails,
      'varieties': newVarieties,
    };
  }

  // Busca uma lista de Pokémon a partir de uma lista de IDs (para os favoritos)
  Future<List<Pokemon>> getPokemonListByIds(List<String> ids) async {
    final futures = ids.map((id) {
      final url = '$_baseUrl/pokemon/$id/';
      return _fetchPokemonSummary(url);
    }).toList();

    final results = await Future.wait(futures);
    return results.whereType<Pokemon>().toList();
  }

  // --- Funções Auxiliares ---

  Map<String, double> _calculateDamageRelations(
    List<http.Response> typeResponses,
  ) {
    const List<String> allTypes = [
      'normal',
      'fire',
      'water',
      'electric',
      'grass',
      'ice',
      'fighting',
      'poison',
      'ground',
      'flying',
      'psychic',
      'bug',
      'rock',
      'ghost',
      'dragon',
      'dark',
      'steel',
      'fairy',
    ];
    final Map<String, double> multipliers = {
      for (var type in allTypes) type: 1.0,
    };
    for (var response in typeResponses) {
      if (response.statusCode == 200) {
        final typeData = json.decode(response.body)['damage_relations'];
        for (var relation in typeData['double_damage_from']) {
          multipliers[relation['name']] =
              (multipliers[relation['name']] ?? 1.0) * 2.0;
        }
        for (var relation in typeData['half_damage_from']) {
          multipliers[relation['name']] =
              (multipliers[relation['name']] ?? 1.0) * 0.5;
        }
        for (var relation in typeData['no_damage_from']) {
          multipliers[relation['name']] =
              (multipliers[relation['name']] ?? 1.0) * 0.0;
        }
      }
    }
    return multipliers;
  }

  List<List<EvolutionInfo>> _parseEvolutions(Map<String, dynamic> chainData) {
    List<List<EvolutionInfo>> lines = [];
    void traverse(
      Map<String, dynamic> current,
      List<EvolutionInfo> currentLine,
    ) {
      final speciesUrl = current['species']['url'] as String;
      final newInfo = EvolutionInfo(
        name: current['species']['name'] as String,
        id: speciesUrl.split('/')[speciesUrl.split('/').length - 2],
      );
      List<EvolutionInfo> newLine = List.from(currentLine)..add(newInfo);
      final evolutionsTo = current['evolves_to'] as List;
      if (evolutionsTo.isEmpty) {
        lines.add(newLine);
      } else {
        for (var nextEvolution in evolutionsTo) {
          traverse(nextEvolution, newLine);
        }
      }
    }

    traverse(chainData, []);
    return lines;
  }
}
