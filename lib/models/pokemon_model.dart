// lib/models/pokemon_model.dart

class PokemonMove {
  final String name;
  final String url;

  PokemonMove({required this.name, required this.url});
}

class Pokemon {
  final String name;
  final String url;
  final List<String> types;
  final String imageUrl;
  final String? shinyImageUrl;
  final bool isLegendary;
  final bool isMythical;

  Pokemon({
    required this.name,
    required this.url,
    required this.types,
    required this.imageUrl,
    this.shinyImageUrl,
    required this.isLegendary,
    required this.isMythical,
  });

  String get id {
    final parts = url.split('/');
    return parts[parts.length - 2];
  }

  // NOVO: Construtor de fábrica para criar um Pokémon a partir de um JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
      types: List<String>.from(json['types']),
      imageUrl: json['imageUrl'],
      shinyImageUrl: json['shinyImageUrl'],
      isLegendary: json['isLegendary'] ?? false,
      isMythical: json['isMythical'] ?? false,
    );
  }

  // NOVO: Método para converter um Pokémon para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'types': types,
      'imageUrl': imageUrl,
      'shinyImageUrl': shinyImageUrl,
      'isLegendary': isLegendary,
      'isMythical': isMythical,
    };
  }
}
