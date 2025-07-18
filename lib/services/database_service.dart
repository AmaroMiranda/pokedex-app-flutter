import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtém o UID do utilizador atual. Retorna null se ninguém estiver logado.
  String? get _uid => _auth.currentUser?.uid;

  // Retorna a referência para o documento do utilizador atual.
  DocumentReference? get _userDocRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  // --- MÉTODOS CORRIGIDOS E MAIS ROBUSTOS ---

  // Adiciona um Pokémon aos favoritos.
  Future<void> addFavorite(String pokemonId) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    final docSnapshot = await docRef.get();

    // Se o documento do utilizador não existir, cria-o com o primeiro favorito.
    if (!docSnapshot.exists) {
      await docRef.set({
        'favorites': [pokemonId],
      });
    } else {
      // Se o documento já existir, apenas atualiza o array.
      await docRef.update({
        'favorites': FieldValue.arrayUnion([pokemonId]),
      });
    }
  }

  // Remove um Pokémon aos favoritos.
  Future<void> removeFavorite(String pokemonId) async {
    final docRef = _userDocRef;
    if (docRef == null) return;

    // A operação de remoção só faz sentido se o documento existir.
    // O arrayRemove não causa erro se o item não estiver no array.
    await docRef.update({
      'favorites': FieldValue.arrayRemove([pokemonId]),
    });
  }

  // Verifica se um Pokémon específico é favorito.
  Future<bool> isFavorite(String pokemonId) async {
    final docRef = _userDocRef;
    if (docRef == null) return false;

    final snapshot = await docRef.get();
    if (!snapshot.exists) return false;

    final data = snapshot.data() as Map<String, dynamic>;
    // O 'as List' pode falhar se o campo não for uma lista, adicionamos segurança extra.
    final favorites = List<String>.from(data['favorites'] as List? ?? []);
    return favorites.contains(pokemonId);
  }

  // Obtém a lista completa de IDs de Pokémon favoritos.
  Future<List<String>> getFavoriteIds() async {
    final docRef = _userDocRef;
    if (docRef == null) return [];

    final snapshot = await docRef.get();
    if (!snapshot.exists) return [];

    final data = snapshot.data() as Map<String, dynamic>;
    return List<String>.from(data['favorites'] as List? ?? []);
  }
}
