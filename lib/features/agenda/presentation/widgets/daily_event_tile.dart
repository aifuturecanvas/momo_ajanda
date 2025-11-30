import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/agenda/models/event_model.dart';

// Ajandanın günlük görünümündeki her bir satırı temsil eden widget.
// Saat bilgisi ve etkinlik kartını bir araya getirir.
class DailyEventTile extends StatelessWidget {
  final Event event;

  const DailyEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Kartlar arasına dikey boşluk ekliyoruz.
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Zaman Sütunu (SOL TARAF)
          SizedBox(
            width: 70, // Saatin kaplayacağı sabit alan
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 2.0), // Başlıkla hizalamak için küçük ayar
              child: Text(
                event.startTime,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 2. Etkinlik Kartı (SAĞ TARAF)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                // Rengin hafif opak bir versiyonunu arka plan olarak kullanıyoruz.
                color: event.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                // Sol kenara etkinliğin ana renginde bir şerit ekliyoruz.
                border: Border(
                  left: BorderSide(
                    color: event.color,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // Eğer alt başlık varsa, onu da ekle.
                  if (event.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      event.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(0.6),
                          ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
