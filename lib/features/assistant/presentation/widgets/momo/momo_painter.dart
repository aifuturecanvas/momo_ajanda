import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'momo_enums.dart';
import 'momo_particle.dart';

class AdvancedMomoPainter extends CustomPainter {
  final Offset offset;
  final double tilt;
  final double squashX;
  final double squashY;
  final Offset lookTarget;
  final Offset handL;
  final Offset handR;
  final MomoMood mood;
  final double intensity;
  final double blinkValue;
  final double breathTime;
  final double audioLevel;
  final List<Particle> particles;

  AdvancedMomoPainter({
    required this.offset,
    required this.tilt,
    required this.squashX,
    required this.squashY,
    required this.lookTarget,
    required this.handL,
    required this.handR,
    required this.mood,
    required this.intensity,
    required this.blinkValue,
    required this.breathTime,
    required this.audioLevel,
    required this.particles,
  });

  final Color cSkin = const Color(0xFFFFFFFF);
  final Color cDark = const Color(0xFF263238);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
    canvas.rotate(tilt);
    canvas.scale(squashX, squashY);

    _drawShadow(canvas);
    _drawArmIK(canvas, const Offset(-70, 0), handL);
    _drawArmIK(canvas, const Offset(70, 0), handR);

    _drawBody(canvas);
    _drawAntenna(canvas);

    canvas.save();
    canvas.translate(lookTarget.dx * 12, lookTarget.dy * 12);
    _drawFace(canvas);
    canvas.restore();

    _drawHand(canvas, handL);
    _drawHand(canvas, handR);

    if (mood == MomoMood.listening) _drawAudioViz(canvas);

    canvas.restore();

    _drawParticles(canvas, center);
  }

  void _drawShadow(Canvas canvas) {
    double s = 1.0 - (offset.dy.clamp(-50, 50) / 200);
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(0, 130), width: 140 * s, height: 25 * s),
      Paint()
        ..color = Colors.black.withOpacity(0.15 * s)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
  }

  void _drawBody(Canvas canvas) {
    final rect = Rect.fromCenter(center: Offset.zero, width: 180, height: 150);
    Color bodyColor = const Color(0xFFECEFF1);
    if (mood == MomoMood.angry) {
      bodyColor = Color.lerp(
          const Color(0xFFECEFF1), const Color(0xFFFFCDD2), intensity)!;
    }

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cSkin, bodyColor],
      ).createShader(rect);

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(65)), paint);

    final screenRect =
        Rect.fromCenter(center: const Offset(0, 5), width: 150, height: 110);
    canvas.drawRRect(
        RRect.fromRectAndRadius(screenRect, const Radius.circular(45)),
        Paint()..color = cDark);

    double pulse = 0.5 + math.sin(breathTime * 5) * 0.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect.inflate(2), const Radius.circular(47)),
      Paint()
        ..color = mood.accentColor.withOpacity(pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4),
    );
  }

  void _drawArmIK(Canvas canvas, Offset shoulder, Offset hand) {
    Path path = Path();
    path.moveTo(shoulder.dx, shoulder.dy);
    double elbowX = (shoulder.dx + hand.dx) / 2 + (shoulder.dx < 0 ? -40 : 40);
    double elbowY = (shoulder.dy + hand.dy) / 2 + 10;

    if (mood == MomoMood.thinking && hand.dx > 0) {
      elbowX += 20;
      elbowY += 20;
    }
    if (mood == MomoMood.surprised) {
      double spread = 20 * intensity;
      elbowX += (shoulder.dx < 0 ? -spread : spread);
    }

    path.quadraticBezierTo(elbowX, elbowY, hand.dx, hand.dy);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round);
  }

  void _drawHand(Canvas canvas, Offset pos) {
    Color handColor = Colors.white;
    if (mood == MomoMood.angry) {
      handColor = Color.lerp(Colors.white, const Color(0xFFFFCDD2), intensity)!;
    }
    canvas.drawCircle(pos, 18, Paint()..color = handColor);
  }

  void _drawAntenna(Canvas canvas) {
    double angle = 0;
    if (mood == MomoMood.listening) {
      angle = breathTime * 8;
    } else if (mood == MomoMood.surprised) {
      angle = 0;
    } else {
      angle = math.sin(breathTime) * 0.1;
    }

    canvas.save();
    canvas.translate(0, -75);
    canvas.rotate(angle);
    canvas.translate(0, 75);

    canvas.drawLine(
        const Offset(0, -75),
        const Offset(0, -95),
        Paint()
          ..color = Colors.grey[400]!
          ..strokeWidth = 4);

    Color glowColor = mood.accentColor;
    if (mood == MomoMood.listening && audioLevel > 0.2)
      glowColor = Colors.redAccent;

    canvas.drawCircle(const Offset(0, -100), 12, Paint()..color = glowColor);
    canvas.drawCircle(const Offset(0, -100), 12 + audioLevel * 10,
        Paint()..color = glowColor.withOpacity(0.3));
    canvas.restore();
  }

  void _drawAudioViz(Canvas canvas) {
    Paint wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Path wavePath = Path();
    double startX = -40;
    for (double i = 0; i <= 80; i += 2) {
      double x = startX + i;
      double y =
          60 + math.sin(i * 0.2 + breathTime * 20) * (10 * audioLevel + 2);
      if (i == 0) {
        wavePath.moveTo(x, y);
      } else {
        wavePath.lineTo(x, y);
      }
    }
    canvas.drawPath(wavePath, wavePaint);
  }

  void _drawFace(Canvas canvas) {
    _drawEye(canvas, Offset(-40, -10) + lookTarget);
    _drawEye(canvas, Offset(40, -10) + lookTarget);
    _drawMouth(canvas, const Offset(0, 35));
  }

  void _drawEye(Canvas canvas, Offset pos) {
    double eyeScale = 1.0;
    if (mood == MomoMood.surprised) {
      eyeScale = 1.0 + (0.35 * intensity);
    }

    final eyeRect = Rect.fromCenter(
        center: pos, width: 34 * eyeScale, height: 44 * eyeScale);
    canvas.drawOval(eyeRect, Paint()..color = mood.accentColor);

    double openAmount = (1.0 - blinkValue);
    if (mood == MomoMood.angry) openAmount *= 0.7;
    if (mood == MomoMood.thinking) openAmount *= 0.9;
    if (mood == MomoMood.surprised) openAmount = 1.0;

    canvas.save();
    canvas.clipPath(Path()..addOval(eyeRect));

    bool useHappyEyes = (mood == MomoMood.happy && intensity > 0.4) ||
        mood == MomoMood.celebrate;

    if (useHappyEyes) {
      _drawHappyEye(canvas, pos);
    } else if (openAmount > 0.1) {
      Offset pupilOffset = lookTarget * 10;
      double pupilSize = 12;

      if (mood == MomoMood.surprised) {
        pupilSize = 12 - (6 * intensity);
      }

      canvas.drawCircle(pos + pupilOffset, pupilSize,
          Paint()..color = const Color(0xFF01579B));
      canvas.drawCircle(pos + pupilOffset + const Offset(-2, -2), 3,
          Paint()..color = Colors.white);

      double lidHeight = eyeRect.height * (1.0 - openAmount);
      canvas.drawRect(
          Rect.fromLTWH(eyeRect.left, eyeRect.top, eyeRect.width, lidHeight),
          Paint()..color = cDark);
    } else {
      canvas.drawLine(
          Offset(pos.dx - 15, pos.dy),
          Offset(pos.dx + 15, pos.dy),
          Paint()
            ..color = cDark
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
    }
    canvas.restore();

    _drawEyebrows(canvas, pos);
  }

  void _drawHappyEye(Canvas canvas, Offset pos) {
    double curve = 5 + intensity * 8;
    final p = Path();
    p.moveTo(pos.dx - 12, pos.dy);
    p.quadraticBezierTo(pos.dx, pos.dy - curve, pos.dx + 12, pos.dy);
    canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
  }

  void _drawEyebrows(Canvas canvas, Offset eyePos) {
    double yOff = -28;
    double tiltAngle = 0;

    if (mood == MomoMood.angry) {
      yOff = -22 + intensity * 5;
      tiltAngle = eyePos.dx < 0 ? 0.5 : -0.5;
    } else if (mood == MomoMood.sad) {
      yOff = -25;
      tiltAngle = eyePos.dx < 0 ? -0.2 : 0.2;
    } else if (mood == MomoMood.surprised) {
      yOff = -28 - (20 * intensity);
    } else if (mood == MomoMood.thinking) {
      yOff = -26;
      if (eyePos.dx > 0) yOff = -32;
    }

    canvas.save();
    canvas.translate(eyePos.dx, eyePos.dy + yOff);
    canvas.rotate(tiltAngle);

    Paint browPaint = Paint()
      ..color = cDark
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    Path p = Path();
    if (mood == MomoMood.surprised) {
      double curve = 5 + 5 * intensity;
      p.moveTo(-10, 0);
      p.quadraticBezierTo(0, -curve, 10, 0);
    } else {
      p.moveTo(-12, 0);
      p.quadraticBezierTo(0, -5, 12, 0);
    }
    canvas.drawPath(p, browPaint);
    canvas.restore();
  }

  void _drawMouth(Canvas canvas, Offset pos) {
    Paint paint = Paint()
      ..color = mood.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    Path p = Path();

    if (mood == MomoMood.happy || mood == MomoMood.celebrate) {
      double width = 15 + intensity * 5;
      double height = 10 + intensity * 15;

      p.moveTo(pos.dx - width, pos.dy - 5);
      p.quadraticBezierTo(pos.dx, pos.dy + height, pos.dx + width, pos.dy - 5);

      if (intensity > 0.7) {
        p.close();
        canvas.drawPath(
            p,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill);
        canvas.drawPath(p, paint);
        return;
      }
    } else if (mood == MomoMood.sad) {
      p.moveTo(pos.dx - 12, pos.dy + 8);
      p.quadraticBezierTo(pos.dx, pos.dy + 3, pos.dx + 12, pos.dy + 8);
    } else if (mood == MomoMood.angry) {
      if (intensity < 0.4) {
        p.moveTo(pos.dx - 12, pos.dy + 5);
        p.lineTo(pos.dx + 12, pos.dy + 5);
      } else if (intensity < 0.8) {
        p.moveTo(pos.dx - 15, pos.dy + 5);
        for (double i = 0; i <= 30; i += 10) {
          p.lineTo(pos.dx - 15 + i, pos.dy + (i % 20 == 0 ? 2 : 8));
        }
        paint.strokeWidth = 3;
      } else {
        canvas.drawOval(
            Rect.fromCenter(
                center: pos + const Offset(0, 5), width: 20, height: 15),
            paint..style = PaintingStyle.fill);
        return;
      }
    } else if (mood == MomoMood.surprised) {
      double w = 10 + (6 * intensity);
      double h = 10 + (15 * intensity);
      canvas.drawOval(Rect.fromCenter(center: pos, width: w, height: h), paint);
      return;
    } else if (mood == MomoMood.thinking) {
      p.moveTo(pos.dx - 8, pos.dy);
      p.lineTo(pos.dx + 8, pos.dy);
    } else {
      p.moveTo(pos.dx - 10, pos.dy);
      p.quadraticBezierTo(pos.dx, pos.dy + 2, pos.dx + 10, pos.dy);
    }
    canvas.drawPath(p, paint);
  }

  void _drawParticles(Canvas canvas, Offset center) {
    for (var p in particles) {
      canvas.save();
      canvas.translate(
          center.dx + offset.dx + p.x, center.dy + offset.dy + p.y);

      if (p.type == ParticleType.confetti) {
        canvas.rotate(p.rotation);
        canvas.drawRect(
            const Rect.fromLTWH(-4, -2, 8, 4), Paint()..color = p.color);
      } else if (p.type == ParticleType.tear) {
        Paint tp = Paint()
          ..color = Colors.lightBlueAccent.withOpacity(p.opacity);
        canvas.drawCircle(Offset.zero, 5 * p.scale, tp);
      } else if (p.type == ParticleType.steam) {
        Paint sp = Paint()
          ..color = Colors.white.withOpacity(p.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset.zero, 8 * p.scale, sp);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant AdvancedMomoPainter oldDelegate) => true;
}

class AdvancedBackgroundPainter extends CustomPainter {
  final Color color;
  final double intensity;
  final bool isListening;

  AdvancedBackgroundPainter(
      {required this.color,
      required this.intensity,
      required this.isListening});

  @override
  void paint(Canvas canvas, Size size) {
    if (isListening) {
      Paint lineP = Paint()
        ..color = color.withOpacity(0.1)
        ..strokeWidth = 1;
      double gap = 30;
      for (double i = 0; i < size.width; i += gap) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), lineP);
      }
      for (double i = 0; i < size.height; i += gap) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), lineP);
      }
      return;
    }

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    final random = math.Random(42);

    for (int i = 0; i < 12; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double r = random.nextDouble() * 50 + 20;
      double time = DateTime.now().millisecondsSinceEpoch / 4000.0;

      double offX = math.sin(time + i) * 30 * (1 + intensity);
      double offY = math.cos(time + i * 0.5) * 30 * (1 + intensity);

      paint.color = color.withOpacity(0.1 + intensity * 0.1);
      canvas.drawCircle(Offset(x + offX, y + offY), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AdvancedBackgroundPainter oldDelegate) => true;
}
