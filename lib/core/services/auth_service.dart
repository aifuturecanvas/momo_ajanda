import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momo_ajanda/core/services/supabase_service.dart';

/// Auth durumu
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Auth state
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabase = SupabaseService();

  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    // Supabase başlatılmamışsa bekle
    if (!_supabase.isInitialized) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // Mevcut oturumu kontrol et
    final user = _supabase.currentUser;
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Auth değişikliklerini dinle
    _supabase.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      debugPrint('Auth event: $event');

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session!.user,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
      }
    });
  }

  /// Email ile kayıt
  Future<bool> signUpWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _supabase.signUpWithEmail(email, password);

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Kayıt başarısız. Lütfen bilgilerinizi kontrol edin.',
        );
        return false;
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Bir hata oluştu: $e',
      );
      return false;
    }
  }

  /// Email ile giriş
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _supabase.signInWithEmail(email, password);

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Giriş başarısız',
        );
        return false;
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Bir hata oluştu: $e',
      );
      return false;
    }
  }

  /// Google ile giriş
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final success = await _supabase.signInWithGoogle();

      if (!success) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Google girişi iptal edildi',
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google giriş hatası: $e',
      );
      return false;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    await _supabase.signOut();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  /// Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.resetPassword(email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Şifre sıfırlama hatası: $e');
      return false;
    }
  }

  /// Hatayı temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Hata mesajlarını Türkçeleştir
  String _getAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email veya şifre hatalı';
    } else if (message.contains('Email not confirmed')) {
      return 'Lütfen email adresinizi doğrulayın';
    } else if (message.contains('User already registered')) {
      return 'Bu email adresi zaten kayıtlı';
    } else if (message.contains('Password should be')) {
      return 'Şifre en az 6 karakter olmalı';
    } else if (message.contains('Invalid email')) {
      return 'Geçersiz email adresi';
    }
    return message;
  }
}
