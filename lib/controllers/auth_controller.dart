// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:pokedex_app/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> error = ValueNotifier('');

  // Função auxiliar para evitar duplicação de código try/catch/finally
  Future<void> _handleAuthRequest(Future<void> Function() authFunction) async {
    isLoading.value = true;
    error.value = '';
    try {
      await authFunction();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    await _handleAuthRequest(() => _authService.signInWithGoogle());
  }

  Future<void> signInAnonymously() async {
    await _handleAuthRequest(() => _authService.signInAnonymously());
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void dispose() {
    isLoading.dispose();
    error.dispose();
  }
}
