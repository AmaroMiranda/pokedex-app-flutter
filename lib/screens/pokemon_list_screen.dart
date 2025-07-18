// lib/screens/pokemon_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/controllers/pokemon_list_controller.dart';
import 'package:pokedex_app/models/pokemon_model.dart';
import 'package:pokedex_app/screens/pokedex_page_view.dart';
import 'package:pokedex_app/theme/app_theme.dart';
import 'package:pokedex_app/widgets/loading_screen.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart';

// A extensão para capitalizar a primeira letra
extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class PokemonListScreen extends StatefulWidget {
  final String title;
  final String apiUrl;

  const PokemonListScreen({
    super.key,
    required this.title,
    required this.apiUrl,
  });

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late final PokemonListController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PokemonListController(widget.apiUrl, widget.title);
    _searchController.addListener(() {
      _controller.onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // CORREÇÃO: Função para mostrar o modal de filtros restaurada ao original
  void _showFilterModal() {
    String? tempSelectedType = _controller.selectedType;
    SortOrder tempSortOrder = _controller.sortOrder;
    bool tempShowLegendaries = _controller.showLegendaries;
    bool tempShowMythicals = _controller.showMythicals;
    bool tempShowShinies = _controller.showShinies.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final List<String> allTypes = [
              'grass',
              'fire',
              'water',
              'bug',
              'normal',
              'poison',
              'electric',
              'ground',
              'fairy',
              'fighting',
              'psychic',
              'rock',
              'ghost',
              'ice',
              'dragon',
              'dark',
              'steel',
            ];

            void resetTempFilters() {
              setModalState(() {
                tempSelectedType = null;
                tempShowLegendaries = false;
                tempShowMythicals = false;
                tempShowShinies = false;
                tempSortOrder = SortOrder.id;
              });
            }

            void confirmFilters() {
              _controller.updateFilters(
                newSelectedType: tempSelectedType,
                newSortOrder: tempSortOrder,
                newShowLegendaries: tempShowLegendaries,
                newShowMythicals: tempShowMythicals,
                newShowShinies: tempShowShinies,
              );
              Navigator.pop(context);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros e Ordenação',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: resetTempFilters,
                        child: Text(
                          'Limpar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSectionTitle('Opções de Visualização'),
                          SwitchListTile(
                            title: const Text('Mostrar versões Shiny'),
                            value: tempShowShinies,
                            onChanged: (value) =>
                                setModalState(() => tempShowShinies = value),
                            secondary: Icon(
                              Icons.auto_awesome_rounded,
                              color: tempShowShinies
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            activeColor: AppTheme.primaryRed,
                          ),
                          const Divider(height: 16),
                          _buildFilterSectionTitle('Ordenar por'),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<SortOrder>(
                                  title: const Text('Número'),
                                  value: SortOrder.id,
                                  groupValue: tempSortOrder,
                                  onChanged: (v) =>
                                      setModalState(() => tempSortOrder = v!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<SortOrder>(
                                  title: const Text('Nome'),
                                  value: SortOrder.name,
                                  groupValue: tempSortOrder,
                                  onChanged: (v) =>
                                      setModalState(() => tempSortOrder = v!),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          _buildFilterSectionTitle('Categorias Especiais'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FilterChip(
                                label: const Text('Lendários'),
                                selected: tempShowLegendaries,
                                onSelected: (selected) => setModalState(() {
                                  tempShowLegendaries = selected;
                                  if (selected) tempShowMythicals = false;
                                }),
                                selectedColor: AppTheme.primaryRed.withOpacity(
                                  0.9,
                                ),
                                labelStyle: TextStyle(
                                  color: tempShowLegendaries
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilterChip(
                                label: const Text('Míticos'),
                                selected: tempShowMythicals,
                                onSelected: (selected) => setModalState(() {
                                  tempShowMythicals = selected;
                                  if (selected) tempShowLegendaries = false;
                                }),
                                selectedColor: AppTheme.primaryRed.withOpacity(
                                  0.9,
                                ),
                                labelStyle: TextStyle(
                                  color: tempShowMythicals
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildFilterSectionTitle('Filtrar por Tipo'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: allTypes.map((type) {
                              final isSelected = tempSelectedType == type;
                              return ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      getIconForType(type),
                                      height: 16,
                                      width: 16,
                                      colorFilter: ColorFilter.mode(
                                        isSelected
                                            ? Colors.white
                                            : getColorForType(type),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(type.capitalize()),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) => setModalState(
                                  () =>
                                      tempSelectedType = selected ? type : null,
                                ),
                                selectedColor: getColorForType(type),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: confirmFilters,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.darkText.withOpacity(0.9),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou número...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const LoadingScreen(message: 'Capturando Pokémon...');
        }
        return ValueListenableBuilder<String>(
          valueListenable: _controller.error,
          builder: (context, error, child) {
            if (error.isNotEmpty) {
              return Center(
                child: Text(error, style: const TextStyle(color: Colors.red)),
              );
            }
            return ValueListenableBuilder<List<Pokemon>>(
              valueListenable: _controller.filteredPokemonList,
              builder: (context, pokemonList, child) {
                if (pokemonList.isEmpty) {
                  return const Center(
                    child: Text("Nenhum Pokémon encontrado."),
                  );
                }
                return ValueListenableBuilder<bool>(
                  valueListenable: _controller.showShinies,
                  builder: (context, showShinies, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: pokemonList.length,
                      itemBuilder: (context, index) {
                        final pokemon = pokemonList[index];
                        return PokemonCard(
                          pokemon: pokemon,
                          showShiny: showShinies,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PokedexPageView(
                                  pokemonList: pokemonList,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
