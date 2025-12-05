import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tarih başlığı widget'ı
class DateHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onDateTap;
  final Color? textColor;

  const DateHeader({
    super.key,
    required this.date,
    this.onPreviousDay,
    this.onNextDay,
    this.onDateTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final dayFormatter = DateFormat('d', 'tr_TR');
    final monthFormatter = DateFormat('MMMM yyyy', 'tr_TR');
    final weekdayFormatter = DateFormat('EEEE', 'tr_TR');

    final isToday = _isToday(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Geri butonu
          IconButton(
            onPressed: onPreviousDay,
            icon: Icon(
              Icons.chevron_left,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
          ),

          // Tarih bilgisi
          Expanded(
            child: GestureDetector(
              onTap: onDateTap,
              child: Column(
                children: [
                  // Gün numarası
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayFormatter.format(date),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Theme.of(context).primaryColor
                              : textColor,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'BUGÜN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Hafta günü
                  Text(
                    weekdayFormatter.format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: (textColor ?? Colors.black).withOpacity(0.7),
                    ),
                  ),

                  // Ay ve yıl
                  Text(
                    monthFormatter.format(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: (textColor ?? Colors.black).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İleri butonu
          IconButton(
            onPressed: onNextDay,
            icon: Icon(
              Icons.chevron_right,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
