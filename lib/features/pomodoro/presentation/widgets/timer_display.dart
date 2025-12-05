import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/pomodoro/models/pomodoro_state.dart';

/// Dairesel zamanlayıcı göstergesi
class TimerDisplay extends StatelessWidget {
  final PomodoroState state;
  final double size;

  const TimerDisplay({
    super.key,
    required this.state,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan dairesi
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.type.color.withOpacity(0.1),
            ),
          ),

          // İlerleme göstergesi
          SizedBox(
            width: size - 20,
            height: size - 20,
            child: CustomPaint(
              painter: _ProgressPainter(
                progress: state.progress,
                color: state.type.color,
                backgroundColor: state.type.color.withOpacity(0.2),
                strokeWidth: 12,
              ),
            ),
          ),

          // Zaman ve durum
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tip ikonu
              Icon(
                state.type.icon,
                size: 32,
                color: state.type.color,
              ),
              const SizedBox(height: 8),

              // Kalan süre
              Text(
                state.formattedTime,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: state.type.color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),

              // Tip etiketi
              Text(
                state.type.label,
                style: TextStyle(
                  fontSize: 18,
                  color: state.type.color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Durum
              if (state.status == PomodoroStatus.paused)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DURAKLATILDI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dairesel ilerleme painter
class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arka plan çemberi
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // İlerleme çemberi
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Üstten başla
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
