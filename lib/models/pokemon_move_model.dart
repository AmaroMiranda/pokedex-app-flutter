// lib/models/pokemon_move_model.dart

class MoveDetail {
  final String name;
  final int? power; // Pode ser nulo (ex: golpes de status)
  final int? accuracy; // Pode ser nulo
  final int pp; // Power Points
  final String type;
  final String damageClass; // physical, special, ou status
  final String effect;

  MoveDetail({
    required this.name,
    this.power,
    this.accuracy,
    required this.pp,
    required this.type,
    required this.damageClass,
    required this.effect,
  });

  factory MoveDetail.fromJson(Map<String, dynamic> json) {
    // Encontra a descrição do efeito em inglês
    final effectEntry = (json['effect_entries'] as List).firstWhere(
      (entry) => entry['language']['name'] == 'en',
      orElse: () => {'short_effect': 'Sem descrição.'},
    );

    return MoveDetail(
      name: json['name'],
      power: json['power'],
      accuracy: json['accuracy'],
      pp: json['pp'],
      type: json['type']['name'],
      damageClass: json['damage_class']['name'],
      // Substitui uma variável da API pelo valor de "chance" do efeito
      effect: (effectEntry['short_effect'] as String).replaceAll(
        '\$effect_chance',
        json['effect_chance'].toString(),
      ),
    );
  }
}
