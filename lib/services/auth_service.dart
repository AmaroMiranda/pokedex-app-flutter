// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Login com Google ---
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O utilizador cancelou o fluxo de login
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _getAuthExceptionMessage(e.code);
    } catch (e) {
      throw 'Ocorreu um erro ao fazer login com o Google. Tente novamente.';
    }
  }

  // --- Login Anónimo ---
  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _getAuthExceptionMessage(e.code);
    }
  }

  // --- Logout ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // --- Tratamento de Erros ---
  String _getAuthExceptionMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com um método de login diferente.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
