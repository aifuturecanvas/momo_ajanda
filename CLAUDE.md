# CLAUDE.md - Momo Akıllı Ajanda Geliştirici Rehberi

## 📋 Proje Genel Bakış

**Momo Akıllı Ajanda**, Flutter tabanlı, AI destekli bir kişisel üretkenlik uygulamasıdır. Supabase backend ve OpenAI entegrasyonu ile çalışır.

### Temel Özellikler
- 📅 **Ajanda**: Etkinlik ve takvim yönetimi
- ✅ **Görevler**: Task tracking ve yönetimi
- 🌞 **Momo Hub**: AI asistan ile etkileşim
- 🔔 **Hatırlatıcılar**: Zamanlı hatırlatmalar
- ⏱️ **Pomodoro**: Odaklanma ve çalışma takibi
- 📝 **Notlar**: Not alma ve düzenleme
- 📊 **İstatistikler**: Kullanıcı performans analizi
- 🏆 **Başarılar**: Gamification sistemi
- 👤 **Profil**: Kullanıcı ayarları ve tercihleri

---

## 🏗️ Mimari ve Dizin Yapısı

Proje **Feature-Based Architecture** (Clean Architecture benzeri) kullanır:

```
lib/
├── app/                          # Uygulama seviyesi yapılandırma
│   ├── momo_app.dart            # Ana MaterialApp widget
│   ├── app_theme.dart           # Tema yapılandırması
│   └── providers/
│       └── momo_providers.dart  # Global provider'lar
│
├── core/                         # Paylaşılan çekirdek katman
│   ├── config/                  # Yapılandırma dosyaları
│   │   ├── supabase_config.dart # Supabase ayarları
│   │   └── openai_config.dart   # OpenAI ayarları
│   ├── services/                # Global servisler
│   │   ├── supabase_service.dart
│   │   ├── openai_service.dart
│   │   ├── auth_service.dart
│   │   └── notification_service.dart
│   └── theme/                   # Tema tanımlamaları
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── features/                     # Özellik modülleri
│   ├── [feature_name]/
│   │   ├── application/         # Business logic & providers
│   │   ├── data/                # Data layer (repositories)
│   │   ├── domain/              # Domain models & entities
│   │   ├── models/              # Data models
│   │   └── presentation/        # UI layer
│   │       ├── pages/           # Ekranlar
│   │       └── widgets/         # Özel widget'lar
│   │
│   ├── agenda/                  # Ajanda özelliği
│   ├── tasks/                   # Görev yönetimi
│   ├── momo_hub/               # AI asistan hub
│   ├── reminders/              # Hatırlatıcılar
│   ├── pomodoro/               # Pomodoro timer
│   ├── notes/                  # Not yönetimi
│   ├── stats/                  # İstatistikler
│   ├── achievements/           # Başarı sistemi
│   ├── profile/                # Kullanıcı profili
│   ├── assistant/              # AI asistan (Momo karakteri)
│   ├── auth/                   # Kimlik doğrulama
│   ├── main/                   # Ana ekran
│   ├── onboarding/            # Onboarding/Splash
│   └── splash/                # Splash screen
│
└── main.dart                    # Uygulama giriş noktası
```

---

## 🛠️ Teknoloji Stack'i

### Framework & Dil
- **Flutter**: 3.0.0+
- **Dart**: 3.0.0+

### State Management
- **flutter_riverpod**: ^2.4.9 - Reaktif state management

### Backend & Database
- **supabase_flutter**: ^2.3.0 - Backend as a Service
  - Authentication (Email, Google OAuth)
  - PostgreSQL database
  - Real-time subscriptions
  - Row Level Security (RLS)

### AI & ML
- **OpenAI API**: GPT modeli ile AI asistan
- **http**: ^1.1.0 - API istekleri için

### Ses İşleme
- **speech_to_text**: ^6.6.0 - Sesli giriş
- **flutter_tts**: ^3.8.5 - Text-to-speech

### Bildirimler
- **flutter_local_notifications**: ^17.0.0
- **timezone**: ^0.9.2

### UI & Görselleştirme
- **fl_chart**: ^0.63.0 - Grafikler
- **table_calendar**: ^3.0.9 - Takvim widget'ı
- **card_swiper**: ^3.0.1 - Swiper efekti
- **google_fonts**: ^6.1.0 - Özel fontlar

### Utilities
- **shared_preferences**: ^2.2.2 - Local storage
- **uuid**: ^4.2.1 - Unique ID oluşturma
- **intl**: ^0.18.1 - Internationalization
- **connectivity_plus**: ^5.0.2 - Network durumu

---

## 🔑 Önemli Kavramlar ve Konvansiyonlar

### 1. Feature-Based Structure
Her özellik kendi klasöründe izole edilmiştir:
- **application/**: Provider'lar ve business logic
- **data/**: Repository'ler ve veri kaynakları
- **domain/**: Domain modelleri (business entities)
- **models/**: Data transfer objects (DTO)
- **presentation/**: UI katmanı (pages, widgets)

### 2. Provider Naming Convention
```dart
// Provider tanımlamaları features/[feature]/application/ içinde:
final taskListProvider = StateNotifierProvider...
final taskRepositoryProvider = Provider...

// Global provider'lar app/providers/ içinde:
final authProvider = StateNotifierProvider...
final themeModeProvider = StateProvider...
```

### 3. Model Yapısı
```dart
class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // fromJson, toJson, copyWith metodları
}
```

### 4. Repository Pattern
```dart
class TaskRepository {
  final SupabaseService _supabase;

  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask(TaskModel task);
  Future<void> updateTask(String id, Map<String, dynamic> updates);
  Future<void> deleteTask(String id);
}
```

### 5. Service Sınıfları (Singleton)
```dart
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Servis metodları...
}
```

---

## 🗄️ Supabase Database Şeması

### Tablolar
1. **tasks** - Görevler
2. **notes** - Notlar
3. **reminders** - Hatırlatıcılar
4. **events** - Ajanda etkinlikleri (varsayılan)
5. **user_stats** - Kullanıcı istatistikleri
6. **user_preferences** - Kullanıcı tercihleri

### Ortak Alanlar
Tüm tablolarda:
- `id` (UUID, PK)
- `user_id` (UUID, FK -> auth.users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Row Level Security (RLS)
Tüm tablolarda kullanıcı bazlı erişim kontrolü:
```sql
-- Kullanıcılar sadece kendi verilerine erişebilir
WHERE user_id = auth.uid()
```

---

## 🤖 Momo AI Asistan

### OpenAI Entegrasyonu
- **Model**: GPT-3.5 veya GPT-4 (config'de tanımlı)
- **Sistem Prompt**: `core/config/openai_config.dart` içinde
- **Konuşma Geçmişi**: Son 20 mesaj tutulur
- **Aksiyon Sistemi**: `[ACTION:TYPE|param:value]` formatı

### Aksiyon Tipleri
```dart
enum MomoActionType {
  createTask,      // Görev oluştur
  createNote,      // Not oluştur
  createReminder,  // Hatırlatıcı oluştur
  showTasks,       // Görevleri göster
  showNotes,       // Notları göster
  showReminders,   // Hatırlatıcıları göster
  completeTask,    // Görevi tamamla
  deleteTask,      // Görevi sil
  setTheme,        // Tema değiştir
  navigate,        // Sayfa geçişi
  unknown          // Tanımsız
}
```

### Örnek Kullanım
```dart
// Kullanıcı: "Yarın sabah 9'da toplantı hatırlat"
// AI Response: "Tamam, yarın sabah 9:00 için toplantı hatırlatıcısı oluşturdum! 📅 [ACTION:CREATE_REMINDER|title:Toplantı|time:2024-12-07 09:00]"
```

---

## 📱 Ana Ekran ve Navigasyon

### MainScreen (TabBar Navigation)
6 ana sekme:
1. **Ajanda** (AgendaScreen)
2. **Görevler** (TasksScreen)
3. **Momo Hub** (MomoHubScreen) - AI asistan merkezi
4. **Hatırlatıcılar** (RemindersScreen)
5. **Odaklan** (PomodoroScreen)
6. **Profil** (ProfileScreen)

### Navigasyon Provider'ı
```dart
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Kullanım:
ref.read(selectedTabProvider.notifier).state = 2; // Momo Hub'a geç
```

---

## 🎨 Tema ve Stil

### Tema Modu
```dart
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
```

### Renkler
- `core/theme/app_colors.dart` - Renk paletleri
- `core/theme/app_theme.dart` - Light/Dark tema tanımları

### Font
- **Google Fonts** kullanılır
- Ana font ailesi config'de tanımlı

---

## 🔐 Authentication Flow

### Auth States
```dart
enum AuthStatus {
  initial,         // Başlangıç durumu
  loading,         // Yükleniyor
  authenticated,   // Giriş yapılmış
  unauthenticated, // Giriş yapılmamış
  error            // Hata durumu
}
```

### Auth Akışı
1. **SplashScreen** - Başlangıç ve oturum kontrolü
2. **LoginScreen** - Email/Google ile giriş
3. **MainScreen** - Authenticated kullanıcılar için

### Login Methodları
```dart
// Email/Password
await SupabaseService().signInWithEmail(email, password);

// Google OAuth
await SupabaseService().signInWithGoogle();

// Logout
await SupabaseService().signOut();
```

---

## 🚀 Başlangıç ve Çalıştırma

### Gereksinimler
```bash
# Flutter SDK 3.0.0+
flutter --version

# Bağımlılıkları yükle
flutter pub get
```

### Ortam Değişkenleri
`lib/core/config/` içinde:
- `supabase_config.dart` - Supabase URL ve anon key
- `openai_config.dart` - OpenAI API key

⚠️ **ÖNEMLİ**: Bu dosyalar `.gitignore`'a eklenmelidir!

### Çalıştırma
```bash
# Geliştirme modu
flutter run

# Release build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Uygulama İnit
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase'i başlat
  await SupabaseService().initialize();

  runApp(const ProviderScope(child: MomoApp()));
}
```

---

## 🧪 Test ve Debugging

### Test Klasörü
```
test/
└── widget_test.dart  # Başlangıç widget testi
```

### Debug Logging
```dart
debugPrint('✅ Supabase başlatıldı');
debugPrint('OpenAI API hatası: ${response.statusCode}');
```

---

## 📝 Kod Yazma Kuralları ve Best Practices

### 1. Dosya İsimlendirme
- **Snake case**: `task_repository.dart`, `momo_hub_screen.dart`
- **Suffix kullanımı**:
  - `_screen.dart` - Sayfalar için
  - `_model.dart` - Modeller için
  - `_provider.dart` - Provider'lar için
  - `_repository.dart` - Repository'ler için
  - `_service.dart` - Servisler için

### 2. Class İsimlendirme
- **PascalCase**: `TaskRepository`, `MomoHubScreen`
- **Suffix**: `TaskModel`, `TaskRepository`, `TaskScreen`

### 3. Provider İsimlendirme
```dart
// StateProvider
final selectedTabProvider = StateProvider...

// StateNotifierProvider
final taskListProvider = StateNotifierProvider...

// FutureProvider
final userStatsProvider = FutureProvider...

// StreamProvider
final authStateProvider = StreamProvider...
```

### 4. Import Sıralaması
```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter framework
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 4. Proje içi import'lar
import 'package:momo_ajanda/core/services/auth_service.dart';
import 'package:momo_ajanda/features/tasks/models/task_model.dart';
```

### 5. Widget Organization
```dart
// StatelessWidget tercih edilir (state yoksa)
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// State varsa ConsumerWidget (Riverpod)
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);
    return Container();
  }
}

// StatefulWidget gerekiyorsa ConsumerStatefulWidget
class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}
```

### 6. Error Handling
```dart
try {
  final result = await repository.getData();
  return result;
} catch (e) {
  debugPrint('Hata: $e');
  // Kullanıcıya hata mesajı göster
  return null;
}
```

### 7. Null Safety
```dart
// Null check
if (user != null) {
  print(user.name);
}

// Null-aware operators
final name = user?.name ?? 'Misafir';
final length = items?.length ?? 0;

// Late initialization (dikkatli kullan)
late final String userId;
```

### 8. Async/Await
```dart
// Future fonksiyonlar
Future<void> loadData() async {
  final data = await repository.getData();
  // İşlemler...
}

// FutureProvider kullanımı
final dataProvider = FutureProvider((ref) async {
  return await repository.getData();
});
```

---

## 🔄 State Management (Riverpod)

### Provider Types

#### 1. StateProvider - Basit state
```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Kullanım:
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).state = 10;
```

#### 2. StateNotifierProvider - Kompleks state
```dart
class TaskListNotifier extends StateNotifier<List<TaskModel>> {
  TaskListNotifier() : super([]);

  void addTask(TaskModel task) {
    state = [...state, task];
  }

  void removeTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<TaskModel>>(
  (ref) => TaskListNotifier(),
);
```

#### 3. FutureProvider - Async data
```dart
final userStatsProvider = FutureProvider((ref) async {
  return await SupabaseService().getUserStats();
});

// Widget içinde:
final statsAsync = ref.watch(userStatsProvider);
statsAsync.when(
  data: (stats) => Text('Stats loaded'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

#### 4. StreamProvider - Real-time data
```dart
final authStateProvider = StreamProvider((ref) {
  return SupabaseService().authStateChanges;
});
```

---

## 📦 Yeni Özellik Ekleme Rehberi

### 1. Feature Klasörü Oluştur
```
lib/features/my_feature/
├── application/
│   └── my_feature_providers.dart
├── data/
│   └── repositories/
│       └── my_feature_repository.dart
├── domain/
│   └── my_feature_model.dart
├── models/
│   └── my_feature_model.dart
└── presentation/
    ├── pages/
    │   └── my_feature_screen.dart
    └── widgets/
        └── my_feature_card.dart
```

### 2. Model Oluştur
```dart
// lib/features/my_feature/models/my_feature_model.dart
class MyFeatureModel {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;

  MyFeatureModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  factory MyFeatureModel.fromJson(Map<String, dynamic> json) {
    return MyFeatureModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### 3. Repository Oluştur
```dart
// lib/features/my_feature/data/repositories/my_feature_repository.dart
class MyFeatureRepository {
  final SupabaseService _supabase = SupabaseService();

  Future<List<MyFeatureModel>> getItems() async {
    final data = await _supabase.client
      .from('my_feature_table')
      .select()
      .eq('user_id', _supabase.currentUser!.id);

    return data.map((e) => MyFeatureModel.fromJson(e)).toList();
  }

  Future<void> addItem(MyFeatureModel item) async {
    await _supabase.client
      .from('my_feature_table')
      .insert(item.toJson());
  }
}
```

### 4. Provider Oluştur
```dart
// lib/features/my_feature/application/my_feature_providers.dart
final myFeatureRepositoryProvider = Provider((ref) => MyFeatureRepository());

final myFeatureListProvider = FutureProvider((ref) async {
  final repo = ref.read(myFeatureRepositoryProvider);
  return await repo.getItems();
});
```

### 5. Screen Oluştur
```dart
// lib/features/my_feature/presentation/pages/my_feature_screen.dart
class MyFeatureScreen extends ConsumerWidget {
  const MyFeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(myFeatureListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: itemsAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index].title),
          ),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
```

### 6. Navigation'a Ekle
MainScreen'e yeni tab eklemek için:
```dart
// lib/features/main/presentation/pages/main_screen.dart
static const List<Widget> _screens = <Widget>[
  // ...mevcut ekranlar
  MyFeatureScreen(), // Yeni ekran
];
```

---

## 🛡️ Güvenlik Konuları

### 1. API Key Güvenliği
```dart
// ❌ YANLIŞ: Hardcoded API key
const apiKey = 'sk-proj-abc123...';

// ✅ DOĞRU: Ortam değişkenleri veya config dosyası
// Config dosyasını .gitignore'a ekle!
class OpenAIConfig {
  static String apiKey = const String.fromEnvironment('OPENAI_API_KEY');
}
```

### 2. Supabase RLS
- Her tablo için Row Level Security aktif olmalı
- Kullanıcılar sadece kendi verilerine erişmeli

### 3. Input Validation
```dart
// Kullanıcı girdilerini validate et
if (title.isEmpty || title.length > 200) {
  throw Exception('Geçersiz başlık');
}
```

---

## 📊 Database Migration ve Şema

### Supabase'de Yeni Tablo Oluşturma

#### SQL Template
```sql
-- Örnek: my_feature tablosu
CREATE TABLE public.my_feature (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index'ler
CREATE INDEX idx_my_feature_user_id ON public.my_feature(user_id);
CREATE INDEX idx_my_feature_created_at ON public.my_feature(created_at DESC);

-- RLS (Row Level Security)
ALTER TABLE public.my_feature ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own data"
  ON public.my_feature FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
  ON public.my_feature FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own data"
  ON public.my_feature FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own data"
  ON public.my_feature FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_my_feature_updated_at
  BEFORE UPDATE ON public.my_feature
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## 🐛 Bilinen Sorunlar ve Çözümler

### 1. Supabase Bağlantı Hatası
```dart
// Problem: Supabase client null
// Çözüm: main.dart'ta initialize çağrıldığından emin ol
await SupabaseService().initialize();
```

### 2. Provider Döngüsü
```dart
// Problem: Circular dependency
// Çözüm: Provider bağımlılıklarını kontrol et, gerekirse family kullan
final itemProvider = FutureProvider.family<Item, String>((ref, id) async {
  return await repository.getItem(id);
});
```

### 3. Build Context Hatası
```dart
// Problem: BuildContext across async gap
// Çözüm: mounted check veya Navigator.of(context) yerine ref kullan
if (mounted) {
  Navigator.pop(context);
}
```

---

## 📚 Önemli Dosyalar

### Mutlaka Bilinmesi Gerekenler
1. **main.dart** - Uygulama başlangıcı
2. **app/momo_app.dart** - Ana MaterialApp
3. **core/services/supabase_service.dart** - Backend işlemleri
4. **core/services/openai_service.dart** - AI entegrasyonu
5. **features/main/presentation/pages/main_screen.dart** - Ana navigasyon
6. **core/theme/app_theme.dart** - Tema tanımları

---

## 🔧 Troubleshooting

### Flutter Issues
```bash
# Cache temizle
flutter clean
flutter pub get

# Build sorunları
flutter pub upgrade
flutter pub outdated
```

### Supabase Issues
- Supabase Dashboard'dan RLS policy'lerini kontrol et
- API key'in doğru olduğundan emin ol
- Network connectivity'yi kontrol et

### Build Errors
```bash
# iOS pod issues
cd ios && pod install && cd ..

# Android issues
flutter build apk --debug --verbose
```

---

## 📖 Faydalı Komutlar

```bash
# Kod analizi
flutter analyze

# Formatter
flutter format lib/

# Test çalıştır
flutter test

# Build
flutter build apk --release
flutter build ios --release

# Clean install
flutter clean && flutter pub get && flutter run
```

---

## 🎯 Geliştirme Checklist'i

### Yeni Feature Eklerken
- [ ] Feature klasör yapısını oluştur
- [ ] Model sınıfını yaz (fromJson, toJson, copyWith)
- [ ] Repository oluştur
- [ ] Provider'ları tanımla
- [ ] UI ekranlarını oluştur
- [ ] Supabase'de tablo ve RLS policy'lerini ekle
- [ ] Navigation'a entegre et
- [ ] Test et

### Code Review Öncesi
- [ ] Kod formatlandı mı? (`flutter format`)
- [ ] Lint hatası var mı? (`flutter analyze`)
- [ ] Debug print'ler kaldırıldı mı?
- [ ] Null safety uygulandı mı?
- [ ] Error handling eklendi mi?
- [ ] Provider'lar dispose ediliyor mu?
- [ ] Performans optimize edildi mi?

---

## 📞 İletişim ve Kaynaklar

### Dökümantasyon
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [OpenAI API Docs](https://platform.openai.com/docs)

### Proje Git Geçmişi
```
ed879d2 - 5.12.2025
3b2fbb2 - Supabase ve OpenAI entegrasyonu
f4970f0 - Reminders özelliği dosya yapısı eklendi
7d51478 - İlk yükleme
```

---

## 🌟 AI Asistan Notları

### AI (Claude/GPT) ile Çalışırken:
1. **Bağlam sağla**: Hangi feature üzerinde çalışıyorsun belirt
2. **Dosya yollarını belirt**: Tam dosya yolunu kullan
3. **Mevcut kodu oku**: Değişiklik yapmadan önce ilgili dosyaları oku
4. **Kod stilini koru**: Mevcut kod stiline uy
5. **Test et**: Değişikliklerden sonra uygulamayı çalıştır

### Örnek Promptlar:
```
"lib/features/tasks/presentation/pages/tasks_screen.dart dosyasını oku ve task ekleme özelliğini iyileştir"

"Yeni bir habits özelliği ekle. Feature-based architecture'a uygun şekilde klasör yapısı oluştur"

"Supabase'de habits tablosu için RLS policy'leri oluştur"

"Momo AI'ın yeni bir aksiyon tipi ekle: CREATE_HABIT"
```

---

## ⚙️ Ortam Yapılandırması

### Config Dosyası Şablonları

#### supabase_config.dart
```dart
class SupabaseConfig {
  static const String projectUrl = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';

  // Table names
  static const String tasksTable = 'tasks';
  static const String notesTable = 'notes';
  static const String remindersTable = 'reminders';
  static const String userStatsTable = 'user_stats';
  static const String userPreferencesTable = 'user_preferences';
}
```

#### openai_config.dart
```dart
class OpenAIConfig {
  static const String apiKey = 'your-openai-api-key';
  static const String chatModel = 'gpt-3.5-turbo';
  static const double temperature = 0.7;
  static const int maxTokens = 500;

  static const String momoSystemPrompt = '''
Sen Momo, kullanıcının akıllı ajanda asistanısın.
Görevler: [ACTION:CREATE_TASK|title:...|priority:...]
// ... sistem promptu
''';
}
```

---

**Son Güncelleme**: 6 Aralık 2025
**Versiyon**: 1.0.0
**Flutter SDK**: 3.0.0+

---

Bu döküman, AI asistanların Momo Akıllı Ajanda projesinde etkili çalışabilmesi için gerekli tüm bilgileri içermektedir. Yeni feature eklerken veya mevcut kodu değiştirirken bu rehbere başvurulmalıdır.
