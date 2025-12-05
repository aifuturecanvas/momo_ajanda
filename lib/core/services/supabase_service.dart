import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momo_ajanda/core/config/supabase_config.dart';

/// Supabase Servis Sınıfı
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase henüz başlatılmadı! initialize() çağırın.');
    }
    return _client!;
  }

  bool get isInitialized => _client != null;

  /// Supabase'i başlat
  Future<void> initialize() async {
    if (_client != null) return;

    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      anonKey: SupabaseConfig.anonKey,
    );

    _client = Supabase.instance.client;
    debugPrint('✅ Supabase başlatıldı');
  }

  /// Mevcut kullanıcı
  User? get currentUser => _client?.auth.currentUser;

  /// Oturum açık mı?
  bool get isAuthenticated => currentUser != null;

  /// Auth state değişikliklerini dinle
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ==================== AUTH İŞLEMLERİ ====================

  /// Email ile kayıt
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Email ile giriş
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Google ile giriş
  Future<bool> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.momoajanda://login-callback/',
      );
      return true;
    } catch (e) {
      debugPrint('Google giriş hatası: $e');
      return false;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // ==================== GÖREV İŞLEMLERİ ====================

  /// Görevleri getir
  Future<List<Map<String, dynamic>>> getTasks() async {
    if (currentUser == null) return [];

    final response = await client
        .from(SupabaseConfig.tasksTable)
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Görev ekle
  Future<Map<String, dynamic>?> addTask(Map<String, dynamic> task) async {
    if (currentUser == null) return null;

    task['user_id'] = currentUser!.id;

    final response = await client
        .from(SupabaseConfig.tasksTable)
        .insert(task)
        .select()
        .single();

    return response;
  }

  /// Görev güncelle
  Future<void> updateTask(String id, Map<String, dynamic> updates) async {
    if (currentUser == null) return;

    updates['updated_at'] = DateTime.now().toIso8601String();

    await client
        .from(SupabaseConfig.tasksTable)
        .update(updates)
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  /// Görev sil
  Future<void> deleteTask(String id) async {
    if (currentUser == null) return;

    await client
        .from(SupabaseConfig.tasksTable)
        .delete()
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  // ==================== NOT İŞLEMLERİ ====================

  /// Notları getir
  Future<List<Map<String, dynamic>>> getNotes() async {
    if (currentUser == null) return [];

    final response = await client
        .from(SupabaseConfig.notesTable)
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Not ekle
  Future<Map<String, dynamic>?> addNote(Map<String, dynamic> note) async {
    if (currentUser == null) return null;

    note['user_id'] = currentUser!.id;

    final response = await client
        .from(SupabaseConfig.notesTable)
        .insert(note)
        .select()
        .single();

    return response;
  }

  /// Not güncelle
  Future<void> updateNote(String id, Map<String, dynamic> updates) async {
    if (currentUser == null) return;

    updates['updated_at'] = DateTime.now().toIso8601String();

    await client
        .from(SupabaseConfig.notesTable)
        .update(updates)
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  /// Not sil
  Future<void> deleteNote(String id) async {
    if (currentUser == null) return;

    await client
        .from(SupabaseConfig.notesTable)
        .delete()
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  // ==================== HATIRLATICI İŞLEMLERİ ====================

  /// Hatırlatıcıları getir
  Future<List<Map<String, dynamic>>> getReminders() async {
    if (currentUser == null) return [];

    final response = await client
        .from(SupabaseConfig.remindersTable)
        .select()
        .eq('user_id', currentUser!.id)
        .order('reminder_time', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Hatırlatıcı ekle
  Future<Map<String, dynamic>?> addReminder(
      Map<String, dynamic> reminder) async {
    if (currentUser == null) return null;

    reminder['user_id'] = currentUser!.id;

    final response = await client
        .from(SupabaseConfig.remindersTable)
        .insert(reminder)
        .select()
        .single();

    return response;
  }

  /// Hatırlatıcı güncelle
  Future<void> updateReminder(String id, Map<String, dynamic> updates) async {
    if (currentUser == null) return;

    await client
        .from(SupabaseConfig.remindersTable)
        .update(updates)
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  /// Hatırlatıcı sil
  Future<void> deleteReminder(String id) async {
    if (currentUser == null) return;

    await client
        .from(SupabaseConfig.remindersTable)
        .delete()
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  // ==================== KULLANICI İSTATİSTİKLERİ ====================

  /// Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>?> getUserStats() async {
    if (currentUser == null) return null;

    try {
      final response = await client
          .from(SupabaseConfig.userStatsTable)
          .select()
          .eq('user_id', currentUser!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Kullanıcı istatistiklerini güncelle
  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    if (currentUser == null) return;

    stats['updated_at'] = DateTime.now().toIso8601String();
    stats['user_id'] = currentUser!.id;

    await client.from(SupabaseConfig.userStatsTable).upsert(stats);
  }

  // ==================== KULLANICI TERCİHLERİ ====================

  /// Kullanıcı tercihlerini getir
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (currentUser == null) return null;

    try {
      final response = await client
          .from(SupabaseConfig.userPreferencesTable)
          .select()
          .eq('user_id', currentUser!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Kullanıcı tercihlerini kaydet
  Future<void> saveUserPreferences(Map<String, dynamic> prefs) async {
    if (currentUser == null) return;

    prefs['updated_at'] = DateTime.now().toIso8601String();
    prefs['user_id'] = currentUser!.id;

    await client.from(SupabaseConfig.userPreferencesTable).upsert(prefs);
  }
}
