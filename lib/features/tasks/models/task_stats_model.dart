// Görev istatistiklerini tutan basit bir veri sınıfı.
class TaskStats {
  final int totalTasks;
  final int completedTasks;

  TaskStats({this.totalTasks = 0, this.completedTasks = 0});

  // YENİ: Tamamlanma yüzdesini hesaplayan getter.
  // Bu, 'completionPercentage' hatasını çözer.
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
}
