// lib/screens/moveset_screen.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/models/pokemon_detail_model.dart';
import 'package:pokedex_app/models/pokemon_move_model.dart';
import 'package:pokedex_app/repositories/pokemon_repository.dart'; // Importa o repositório
import 'package:pokedex_app/screens/move_detail_screen.dart';
import 'package:pokedex_app/theme/app_theme.dart';
import 'package:pokedex_app/widgets/loading_screen.dart';
import 'package:pokedex_app/widgets/move_card.dart';
import 'package:pokedex_app/utils/string_extensions.dart';

class MovesetScreen extends StatefulWidget {
  final PokemonDetail pokemonDetail;

  const MovesetScreen({super.key, required this.pokemonDetail});

  @override
  State<MovesetScreen> createState() => _MovesetScreenState();
}

class _MovesetScreenState extends State<MovesetScreen> {
  // NOVO: Instância do nosso repositório
  final PokemonRepository _repository = PokemonRepository();

  bool _isLoading = true;
  String _error = '';
  List<MoveDetail> _moveDetails = [];
  List<MoveDetail> _filteredMoveDetails = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMoveDetails();
    _searchController.addListener(_filterMoves);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMoves);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMoves() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMoveDetails = _moveDetails.where((move) {
        return move.name.toLowerCase().replaceAll('-', ' ').contains(query);
      }).toList();
    });
  }

  // MÉTODO ATUALIZADO: Agora usa o repositório
  Future<void> _fetchMoveDetails() async {
    try {
      // Usa o repositório para buscar cada golpe em paralelo
      final moveFutures = widget.pokemonDetail.moves.map((move) {
        return _repository.getMoveDetail(move.url);
      }).toList();

      final fetchedMoves = await Future.wait(moveFutures);
      fetchedMoves.sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _moveDetails = fetchedMoves;
          _filteredMoveDetails = fetchedMoves;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao carregar os golpes.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (O resto do build permanece igual)
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text('Golpes de ${widget.pokemonDetail.name.capitalize()}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar golpe...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingScreen(message: 'Analisando golpes...')
                : _error.isNotEmpty
                ? Center(
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredMoveDetails.length,
                    itemBuilder: (context, index) {
                      final move = _filteredMoveDetails[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MoveDetailScreen(moveDetail: move),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: MoveCard(move: move),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
