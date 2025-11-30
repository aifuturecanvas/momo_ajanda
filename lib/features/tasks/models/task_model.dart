/// Bir görevin sahip olacağı özellikleri tanımlayan sınıf.
class Task {
  final String id;
  final String title;
  final String category;
  final bool isCompleted;
  final List<String> tags; // YENİ: Etiketler
  final DateTime? dueDate; // YENİ: Son tarih
  final DateTime createdAt; // YENİ: Oluşturulma tarihi

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.tags = const [],
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Durumu güncellemeyi kolaylaştıran copyWith metodu
  Task copyWith({
    String? title,
    String? category,
    bool? isCompleted,
    List<String>? tags,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
    );
  }

  // Veriyi kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'tags': tags,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Kaydedilmiş veriden Task nesnesi oluşturma
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Başlıksız Görev',
      category: json['category'] ?? 'Genel',
      isCompleted: json['isCompleted'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      dueDate:
          json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Görevin bugün mü olduğunu kontrol eder
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Görevin gecikmiş olup olmadığını kontrol eder
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
