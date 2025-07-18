// lib/models/pokemon_detail_model.dart

class PokemonMove {
  final String name;
  final String url;

  PokemonMove({required this.name, required this.url});

  factory PokemonMove.fromJson(Map<String, dynamic> json) {
    return PokemonMove(name: json['name'], url: json['url']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}

class PokemonAbility {
  final String name;
  final String url;
  PokemonAbility({required this.name, required this.url});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(name: json['name'], url: json['url']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}

class AbilityDetail {
  final String name;
  final String description;
  AbilityDetail({required this.name, required this.description});

  factory AbilityDetail.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('description')) {
      return AbilityDetail(
        name: json['name'],
        description: json['description'],
      );
    }
    final effectEntry = (json['effect_entries'] as List).firstWhere(
      (entry) => entry['language']['name'] == 'en',
      orElse: () => {'short_effect': 'Descrição não encontrada.'},
    );
    return AbilityDetail(
      name: json['name'],
      description: effectEntry['short_effect'].replaceAll('\n', ' '),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class PokemonStat {
  final String name;
  final int value;
  PokemonStat({required this.name, required this.value});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(name: json['name'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<PokemonAbility> abilities;
  final List<PokemonMove> moves;
  final String imageUrl;
  final String? shinyImageUrl;
  final String soundUrl;
  final List<PokemonStat> stats;
  final String speciesUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.moves,
    required this.imageUrl,
    this.shinyImageUrl,
    required this.soundUrl,
    required this.stats,
    required this.speciesUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: List<String>.from(json['types']),
      abilities: (json['abilities'] as List)
          .map((ability) => PokemonAbility.fromJson(ability))
          .toList(),
      moves: (json['moves'] as List)
          .map((move) => PokemonMove.fromJson(move))
          .toList(),
      imageUrl: json['imageUrl'],
      shinyImageUrl: json['shinyImageUrl'],
      soundUrl: json['soundUrl'],
      stats: (json['stats'] as List)
          .map((stat) => PokemonStat.fromJson(stat))
          .toList(),
      speciesUrl: json['speciesUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'types': types,
      'abilities': abilities.map((a) => a.toJson()).toList(),
      'moves': moves.map((m) => m.toJson()).toList(),
      'imageUrl': imageUrl,
      'shinyImageUrl': shinyImageUrl,
      'soundUrl': soundUrl,
      'stats': stats.map((s) => s.toJson()).toList(),
      'speciesUrl': speciesUrl,
    };
  }

  factory PokemonDetail.fromApiJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List)
        .map((typeInfo) => typeInfo['type']['name'] as String)
        .toList();
    final abilitiesList = (json['abilities'] as List)
        .map(
          (abilityInfo) => PokemonAbility(
            name: abilityInfo['ability']['name'],
            url: abilityInfo['ability']['url'],
          ),
        )
        .toList();
    final movesList = (json['moves'] as List)
        .map(
          (moveInfo) => PokemonMove(
            name: moveInfo['move']['name'],
            url: moveInfo['move']['url'],
          ),
        )
        .toList();
    final statsList = (json['stats'] as List).map((statInfo) {
      return PokemonStat(
        name: statInfo['stat']['name'],
        value: statInfo['base_stat'],
      );
    }).toList();

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: typesList,
      abilities: abilitiesList,
      moves: movesList,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
      shinyImageUrl:
          json['sprites']['other']['official-artwork']['front_shiny'],
      soundUrl: json['cries']['latest'] ?? json['cries']['legacy'],
      stats: statsList,
      speciesUrl: json['species']['url'],
    );
  }
}
