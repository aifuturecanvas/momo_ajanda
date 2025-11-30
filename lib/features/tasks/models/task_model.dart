// Bir görevin sahip olacağı özellikleri tanımlayan sınıf.
class Task {
  final String id;
  final String title;
  final String category;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
  });

  // Notifier'da durumu güncellemeyi kolaylaştırmak için copyWith metodu ekliyoruz.
  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Veriyi kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  // Kaydedilmiş veriden Task nesnesi oluşturma
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Başlıksız Görev',
      category: json['category'] ?? 'Genel',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
