import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Momo'nun ruh halleri
enum MomoMoodType {
  happy, // Mutlu
  excited, // Heyecanlı
  thinking, // Düşünüyor
  sleeping, // Uyuyor
  proud, // Gururlu
  worried, // Endişeli/Üzgün
  greeting, // Selamlama
  celebrating, // Kutlama
}

/// Yeni Momo Karakteri - Profesyonel Güneş Maskotu
class MomoCharacter extends StatefulWidget {
  final MomoMoodType mood;
  final double size;
  final bool animate;
  final String? message;

  const MomoCharacter({
    super.key,
    this.mood = MomoMoodType.happy,
    this.size = 150,
    this.animate = true,
    this.message,
  });

  @override
  State<MomoCharacter> createState() => _MomoCharacterState();
}

class _MomoCharacterState extends State<MomoCharacter>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  late AnimationController _waveController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _waveAnimation;

  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();

    // Zıplama/nefes alma animasyonu
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Göz kırpma animasyonu
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1, end: 0.05).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // El sallama animasyonu
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: -0.2, end: 0.3).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _bounceController.repeat(reverse: true);
    _startBlinking();

    if (widget.mood == MomoMoodType.greeting ||
        widget.mood == MomoMoodType.celebrating) {
      _waveController.repeat(reverse: true);
    }
  }

  void _startBlinking() async {
    while (mounted && widget.animate) {
      await Future.delayed(
          Duration(milliseconds: 2500 + math.Random().nextInt(2500)));
      if (mounted && widget.mood != MomoMoodType.sleeping && !_isBlinking) {
        _isBlinking = true;
        await _blinkController.forward();
        await _blinkController.reverse();
        _isBlinking = false;
      }
    }
  }

  @override
  void didUpdateWidget(MomoCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mood != widget.mood) {
      if (widget.mood == MomoMoodType.greeting ||
          widget.mood == MomoMoodType.celebrating) {
        _waveController.repeat(reverse: true);
      } else {
        _waveController.stop();
        _waveController.reset();
      }
    }

    if (widget.animate && !_bounceController.isAnimating) {
      _startAnimations();
    } else if (!widget.animate && _bounceController.isAnimating) {
      _bounceController.stop();
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _blinkController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge(
              [_bounceAnimation, _blinkAnimation, _waveAnimation]),
          builder: (context, child) {
            final bounceOffset = math.sin(_bounceAnimation.value * math.pi) * 6;
            final scale =
                1.0 + math.sin(_bounceAnimation.value * math.pi) * 0.02;

            return Transform.translate(
              offset: Offset(0, -bounceOffset),
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: widget.size * 1.4,
                  height: widget.size * 1.5,
                  child: CustomPaint(
                    painter: _MomoProPainter(
                      mood: widget.mood,
                      blinkValue: _blinkAnimation.value,
                      waveValue: _waveAnimation.value,
                      breathValue: _bounceAnimation.value,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Mesaj balonu
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          _MessageBubble(message: widget.message!),
        ],
      ],
    );
  }
}

/// Profesyonel Momo Painter
class _MomoProPainter extends CustomPainter {
  final MomoMoodType mood;
  final double blinkValue;
  final double waveValue;
  final double breathValue;

  _MomoProPainter({
    required this.mood,
    required this.blinkValue,
    required this.waveValue,
    required this.breathValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.38;
    final bodyRadius = size.width * 0.28;

    // Gölge
    _drawShadow(canvas, Offset(centerX, size.height * 0.92), bodyRadius);

    // Bacaklar (gövdeden önce çizilecek)
    _drawLegs(canvas, Offset(centerX, centerY), bodyRadius, size);

    // Kollar (gövdeden önce çizilecek - arkada kalanlar)
    _drawArms(canvas, Offset(centerX, centerY), bodyRadius, size);

    // Güneş ışınları
    _drawSunRays(canvas, Offset(centerX, centerY), bodyRadius);

    // Ana gövde
    _drawBody(canvas, Offset(centerX, centerY), bodyRadius);

    // Yüz
    _drawFace(canvas, Offset(centerX, centerY), bodyRadius);
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 1.8,
        height: radius * 0.3,
      ),
      shadowPaint,
    );
  }

  void _drawSunRays(Canvas canvas, Offset center, double radius) {
    final rayCount = 8;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i - math.pi / 2;
      final nextAngle = (2 * math.pi / rayCount) * (i + 1) - math.pi / 2;
      final midAngle = (angle + nextAngle) / 2;

      // Kavisli, organik ışın şekli
      final rayPath = Path();

      final startRadius = radius * 1.02;
      final endRadius = radius * 1.6;
      final controlRadius = radius * 1.45;

      // Işının başlangıç noktaları (gövdeye yakın)
      final startLeft = Offset(
        center.dx + math.cos(angle + 0.15) * startRadius,
        center.dy + math.sin(angle + 0.15) * startRadius,
      );
      final startRight = Offset(
        center.dx + math.cos(nextAngle - 0.15) * startRadius,
        center.dy + math.sin(nextAngle - 0.15) * startRadius,
      );

      // Işının uç noktası
      final tip = Offset(
        center.dx + math.cos(midAngle) * endRadius,
        center.dy + math.sin(midAngle) * endRadius,
      );

      // Kontrol noktaları (kavis için)
      final controlLeft = Offset(
        center.dx + math.cos(angle + 0.25) * controlRadius,
        center.dy + math.sin(angle + 0.25) * controlRadius,
      );
      final controlRight = Offset(
        center.dx + math.cos(nextAngle - 0.25) * controlRadius,
        center.dy + math.sin(nextAngle - 0.25) * controlRadius,
      );

      rayPath.moveTo(startLeft.dx, startLeft.dy);
      rayPath.quadraticBezierTo(controlLeft.dx, controlLeft.dy, tip.dx, tip.dy);
      rayPath.quadraticBezierTo(
          controlRight.dx, controlRight.dy, startRight.dx, startRight.dy);
      rayPath.close();

      // Gradient dolgu
      final rayPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            const Color(0xFFFFE135),
            const Color(0xFFFFAA00),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: endRadius));

      canvas.drawPath(rayPath, rayPaint);

      // Kalın siyah kontur
      final rayOutline = Paint()
        ..color = const Color(0xFF2D2D2D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(rayPath, rayOutline);
    }
  }

  void _drawBody(Canvas canvas, Offset center, double radius) {
    // Ana gövde gradienti
    final bodyGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        const Color(0xFFFFEE58),
        const Color(0xFFFFD600),
        const Color(0xFFFFC107),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, bodyPaint);

    // Parlama efekti
    final highlightPath = Path();
    highlightPath.addArc(
      Rect.fromCircle(
          center: Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
          radius: radius * 0.7),
      -math.pi * 0.8,
      math.pi * 0.5,
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.15
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(highlightPath, highlightPaint);

    // Kalın siyah kontur
    final outlinePaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, outlinePaint);
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    // Göz pozisyonları
    final leftEyeCenter =
        Offset(center.dx - radius * 0.35, center.dy - radius * 0.1);
    final rightEyeCenter =
        Offset(center.dx + radius * 0.35, center.dy - radius * 0.1);
    final eyeRadius = radius * 0.22;

    // Gözler
    _drawEye(canvas, leftEyeCenter, eyeRadius, isLeft: true);
    _drawEye(canvas, rightEyeCenter, eyeRadius, isLeft: false);

    // Kaşlar (mood'a göre)
    _drawEyebrows(canvas, leftEyeCenter, rightEyeCenter, eyeRadius);

    // Ağız
    _drawMouth(canvas, center, radius);

    // Yanaklar
    if (mood == MomoMoodType.happy ||
        mood == MomoMoodType.excited ||
        mood == MomoMoodType.celebrating ||
        mood == MomoMoodType.greeting) {
      _drawCheeks(canvas, center, radius);
    }

    // Üzgün mood için gözyaşı
    if (mood == MomoMoodType.worried) {
      _drawTears(canvas, leftEyeCenter, rightEyeCenter, eyeRadius);
    }
  }

  void _drawEye(Canvas canvas, Offset center, double radius,
      {required bool isLeft}) {
    final eyeHeight = radius * blinkValue;

    if (mood == MomoMoodType.sleeping) {
      // Kapalı göz
      final closedEyePaint = Paint()
        ..color = const Color(0xFF2D2D2D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(center.dx - radius * 0.8, center.dy);
      path.quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.5,
        center.dx + radius * 0.8,
        center.dy,
      );
      canvas.drawPath(path, closedEyePaint);
      return;
    }

    // Göz beyazı (oval)
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
          center: center, width: radius * 1.8, height: eyeHeight * 1.8),
      whitePaint,
    );

    // Göz konturu
    final eyeOutline = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(
      Rect.fromCenter(
          center: center, width: radius * 1.8, height: eyeHeight * 1.8),
      eyeOutline,
    );

    if (blinkValue > 0.3) {
      // Göz bebeği
      final pupilOffset = mood == MomoMoodType.thinking
          ? Offset(isLeft ? radius * 0.2 : radius * 0.3, -radius * 0.15)
          : Offset.zero;

      final pupilCenter = center + pupilOffset;
      final pupilRadius = radius * 0.55 * blinkValue;

      final pupilPaint = Paint()..color = const Color(0xFF1A1A1A);
      canvas.drawCircle(pupilCenter, pupilRadius, pupilPaint);

      // Göz parlaması (büyük)
      final shine1Paint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(pupilCenter.dx - pupilRadius * 0.35,
            pupilCenter.dy - pupilRadius * 0.35),
        pupilRadius * 0.4,
        shine1Paint,
      );

      // Göz parlaması (küçük)
      canvas.drawCircle(
        Offset(pupilCenter.dx + pupilRadius * 0.25,
            pupilCenter.dy + pupilRadius * 0.2),
        pupilRadius * 0.2,
        shine1Paint,
      );
    }
  }

  void _drawEyebrows(
      Canvas canvas, Offset leftEye, Offset rightEye, double eyeRadius) {
    final browPaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final browOffset = eyeRadius * 1.3;

    if (mood == MomoMoodType.worried) {
      // Üzgün kaşlar (içe doğru eğik)
      // Sol kaş
      canvas.drawLine(
        Offset(leftEye.dx - eyeRadius * 0.7,
            leftEye.dy - browOffset + eyeRadius * 0.3),
        Offset(leftEye.dx + eyeRadius * 0.5,
            leftEye.dy - browOffset - eyeRadius * 0.1),
        browPaint,
      );
      // Sağ kaş
      canvas.drawLine(
        Offset(rightEye.dx - eyeRadius * 0.5,
            rightEye.dy - browOffset - eyeRadius * 0.1),
        Offset(rightEye.dx + eyeRadius * 0.7,
            rightEye.dy - browOffset + eyeRadius * 0.3),
        browPaint,
      );
    } else if (mood == MomoMoodType.excited ||
        mood == MomoMoodType.celebrating) {
      // Yükseltilmiş kaşlar
      final path1 = Path();
      path1.moveTo(leftEye.dx - eyeRadius * 0.6, leftEye.dy - browOffset);
      path1.quadraticBezierTo(
        leftEye.dx,
        leftEye.dy - browOffset - eyeRadius * 0.4,
        leftEye.dx + eyeRadius * 0.6,
        leftEye.dy - browOffset,
      );
      canvas.drawPath(path1, browPaint);

      final path2 = Path();
      path2.moveTo(rightEye.dx - eyeRadius * 0.6, rightEye.dy - browOffset);
      path2.quadraticBezierTo(
        rightEye.dx,
        rightEye.dy - browOffset - eyeRadius * 0.4,
        rightEye.dx + eyeRadius * 0.6,
        rightEye.dy - browOffset,
      );
      canvas.drawPath(path2, browPaint);
    }
  }

  void _drawMouth(Canvas canvas, Offset center, double radius) {
    final mouthY = center.dy + radius * 0.4;

    final mouthOutline = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mouthFill = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.fill;

    Path mouthPath = Path();

    switch (mood) {
      case MomoMoodType.happy:
      case MomoMoodType.greeting:
      case MomoMoodType.proud:
        // Geniş mutlu gülümseme (açık ağız)
        final mouthWidth = radius * 0.55;
        final mouthHeight = radius * 0.35;

        mouthPath.moveTo(center.dx - mouthWidth, mouthY - mouthHeight * 0.2);
        mouthPath.quadraticBezierTo(
          center.dx - mouthWidth * 0.5,
          mouthY - mouthHeight * 0.1,
          center.dx,
          mouthY,
        );
        mouthPath.quadraticBezierTo(
          center.dx + mouthWidth * 0.5,
          mouthY - mouthHeight * 0.1,
          center.dx + mouthWidth,
          mouthY - mouthHeight * 0.2,
        );
        mouthPath.quadraticBezierTo(
          center.dx + mouthWidth * 0.3,
          mouthY + mouthHeight,
          center.dx,
          mouthY + mouthHeight * 0.8,
        );
        mouthPath.quadraticBezierTo(
          center.dx - mouthWidth * 0.3,
          mouthY + mouthHeight,
          center.dx - mouthWidth,
          mouthY - mouthHeight * 0.2,
        );
        mouthPath.close();

        canvas.drawPath(mouthPath, mouthFill);
        canvas.drawPath(mouthPath, mouthOutline);

        // Dil
        final tonguePaint = Paint()..color = const Color(0xFFE57373);
        final tonguePath = Path();
        tonguePath.addOval(Rect.fromCenter(
          center: Offset(center.dx, mouthY + radius * 0.22),
          width: radius * 0.3,
          height: radius * 0.18,
        ));
        canvas.drawPath(tonguePath, tonguePaint);
        break;

      case MomoMoodType.excited:
      case MomoMoodType.celebrating:
        // Çok geniş heyecanlı gülümseme
        final mouthWidth = radius * 0.65;
        final mouthHeight = radius * 0.45;

        mouthPath.moveTo(center.dx - mouthWidth, mouthY - mouthHeight * 0.15);
        mouthPath.quadraticBezierTo(
          center.dx,
          mouthY + mouthHeight * 0.2,
          center.dx + mouthWidth,
          mouthY - mouthHeight * 0.15,
        );
        mouthPath.quadraticBezierTo(
          center.dx + mouthWidth * 0.3,
          mouthY + mouthHeight,
          center.dx,
          mouthY + mouthHeight * 0.9,
        );
        mouthPath.quadraticBezierTo(
          center.dx - mouthWidth * 0.3,
          mouthY + mouthHeight,
          center.dx - mouthWidth,
          mouthY - mouthHeight * 0.15,
        );
        mouthPath.close();

        canvas.drawPath(mouthPath, mouthFill);
        canvas.drawPath(mouthPath, mouthOutline);

        // Dil
        final tonguePaint = Paint()..color = const Color(0xFFE57373);
        final tonguePath = Path();
        tonguePath.addOval(Rect.fromCenter(
          center: Offset(center.dx, mouthY + radius * 0.28),
          width: radius * 0.35,
          height: radius * 0.2,
        ));
        canvas.drawPath(tonguePath, tonguePaint);
        break;

      case MomoMoodType.worried:
        // Üzgün ağız (aşağı kıvrık)
        final mouthWidth = radius * 0.4;

        mouthPath.moveTo(center.dx - mouthWidth, mouthY);
        mouthPath.quadraticBezierTo(
          center.dx,
          mouthY + radius * 0.25,
          center.dx + mouthWidth,
          mouthY,
        );

        canvas.drawPath(mouthPath, mouthOutline);
        break;

      case MomoMoodType.thinking:
        // Düşünceli ağız (düz, hafif eğik)
        final mouthWidth = radius * 0.3;

        mouthPath.moveTo(center.dx - mouthWidth, mouthY + radius * 0.05);
        mouthPath.lineTo(center.dx + mouthWidth, mouthY - radius * 0.05);

        canvas.drawPath(mouthPath, mouthOutline);
        break;

      case MomoMoodType.sleeping:
        // Uyuyan ağız (küçük, hafif açık)
        final mouthWidth = radius * 0.2;

        mouthPath.addOval(Rect.fromCenter(
          center: Offset(center.dx, mouthY),
          width: mouthWidth,
          height: mouthWidth * 0.6,
        ));

        canvas.drawPath(mouthPath, mouthFill);
        canvas.drawPath(mouthPath, mouthOutline);
        break;
    }
  }

  void _drawCheeks(Canvas canvas, Offset center, double radius) {
    final cheekPaint = Paint()
      ..color = const Color(0xFFFFAB91).withOpacity(0.6);

    final cheekY = center.dy + radius * 0.15;
    final cheekRadius = radius * 0.15;

    // Sol yanak
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.6, cheekY),
        width: cheekRadius * 2.2,
        height: cheekRadius * 1.4,
      ),
      cheekPaint,
    );

    // Sağ yanak
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.6, cheekY),
        width: cheekRadius * 2.2,
        height: cheekRadius * 1.4,
      ),
      cheekPaint,
    );
  }

  void _drawTears(
      Canvas canvas, Offset leftEye, Offset rightEye, double eyeRadius) {
    final tearPaint = Paint()..color = const Color(0xFF81D4FA).withOpacity(0.8);

    final tearOutline = Paint()
      ..color = const Color(0xFF29B6F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Sol gözyaşı
    final leftTearPath = Path();
    leftTearPath.moveTo(
        leftEye.dx - eyeRadius * 0.3, leftEye.dy + eyeRadius * 0.9);
    leftTearPath.quadraticBezierTo(
      leftEye.dx - eyeRadius * 0.5,
      leftEye.dy + eyeRadius * 1.5,
      leftEye.dx - eyeRadius * 0.3,
      leftEye.dy + eyeRadius * 1.8,
    );
    leftTearPath.quadraticBezierTo(
      leftEye.dx - eyeRadius * 0.1,
      leftEye.dy + eyeRadius * 1.5,
      leftEye.dx - eyeRadius * 0.3,
      leftEye.dy + eyeRadius * 0.9,
    );
    canvas.drawPath(leftTearPath, tearPaint);
    canvas.drawPath(leftTearPath, tearOutline);

    // Sağ gözyaşı
    final rightTearPath = Path();
    rightTearPath.moveTo(
        rightEye.dx + eyeRadius * 0.3, rightEye.dy + eyeRadius * 0.9);
    rightTearPath.quadraticBezierTo(
      rightEye.dx + eyeRadius * 0.5,
      rightEye.dy + eyeRadius * 1.5,
      rightEye.dx + eyeRadius * 0.3,
      rightEye.dy + eyeRadius * 1.8,
    );
    rightTearPath.quadraticBezierTo(
      rightEye.dx + eyeRadius * 0.1,
      rightEye.dy + eyeRadius * 1.5,
      rightEye.dx + eyeRadius * 0.3,
      rightEye.dy + eyeRadius * 0.9,
    );
    canvas.drawPath(rightTearPath, tearPaint);
    canvas.drawPath(rightTearPath, tearOutline);
  }

  void _drawArms(Canvas canvas, Offset center, double radius, Size size) {
    final armColor = const Color(0xFFFFD600);
    final armOutlineColor = const Color(0xFF2D2D2D);

    final armPaint = Paint()
      ..color = armColor
      ..style = PaintingStyle.fill;

    final armOutline = Paint()
      ..color = armOutlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final armWidth = radius * 0.18;
    final armLength = radius * 0.9;

    // Sol kol
    final leftArmStart =
        Offset(center.dx - radius * 0.85, center.dy + radius * 0.2);
    Path leftArmPath = Path();

    if (mood == MomoMoodType.greeting || mood == MomoMoodType.celebrating) {
      // Yukarı kalkmış kol (el sallama)
      final waveAngle = waveValue;
      final endPoint = Offset(
        leftArmStart.dx - armLength * 0.7 * math.cos(waveAngle),
        leftArmStart.dy - armLength * math.sin(math.pi / 3 + waveAngle),
      );

      leftArmPath = _createArmPath(leftArmStart, endPoint, armWidth,
          isLeft: true, isUp: true);
      canvas.drawPath(leftArmPath, armPaint);
      canvas.drawPath(leftArmPath, armOutline);

      // El
      _drawHand(canvas, endPoint, armWidth * 1.3, armPaint, armOutline);
    } else {
      // Aşağı sarkan kol
      final endPoint = Offset(
        leftArmStart.dx - armLength * 0.5,
        leftArmStart.dy + armLength * 0.7,
      );

      leftArmPath = _createArmPath(leftArmStart, endPoint, armWidth,
          isLeft: true, isUp: false);
      canvas.drawPath(leftArmPath, armPaint);
      canvas.drawPath(leftArmPath, armOutline);

      // El
      _drawHand(canvas, endPoint, armWidth * 1.3, armPaint, armOutline);
    }

    // Sağ kol
    final rightArmStart =
        Offset(center.dx + radius * 0.85, center.dy + radius * 0.2);
    Path rightArmPath;

    if (mood == MomoMoodType.celebrating) {
      // Yukarı kalkmış kol
      final endPoint = Offset(
        rightArmStart.dx + armLength * 0.7 * math.cos(waveValue),
        rightArmStart.dy - armLength * math.sin(math.pi / 3 - waveValue),
      );

      rightArmPath = _createArmPath(rightArmStart, endPoint, armWidth,
          isLeft: false, isUp: true);
      canvas.drawPath(rightArmPath, armPaint);
      canvas.drawPath(rightArmPath, armOutline);

      _drawHand(canvas, endPoint, armWidth * 1.3, armPaint, armOutline);
    } else {
      // Aşağı sarkan kol
      final endPoint = Offset(
        rightArmStart.dx + armLength * 0.5,
        rightArmStart.dy + armLength * 0.7,
      );

      rightArmPath = _createArmPath(rightArmStart, endPoint, armWidth,
          isLeft: false, isUp: false);
      canvas.drawPath(rightArmPath, armPaint);
      canvas.drawPath(rightArmPath, armOutline);

      _drawHand(canvas, endPoint, armWidth * 1.3, armPaint, armOutline);
    }
  }

  Path _createArmPath(Offset start, Offset end, double width,
      {required bool isLeft, required bool isUp}) {
    final path = Path();
    final direction = (end - start);
    final length = direction.distance;
    final normalized = Offset(direction.dx / length, direction.dy / length);
    final perpendicular = Offset(-normalized.dy, normalized.dx);

    final startLeft = start + perpendicular * width;
    final startRight = start - perpendicular * width;
    final endLeft = end + perpendicular * width * 0.8;
    final endRight = end - perpendicular * width * 0.8;

    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + (isLeft ? -width : width) * 0.5,
      (start.dy + end.dy) / 2,
    );

    path.moveTo(startLeft.dx, startLeft.dy);
    path.quadraticBezierTo(controlPoint.dx + perpendicular.dx * width,
        controlPoint.dy + perpendicular.dy * width, endLeft.dx, endLeft.dy);
    path.lineTo(endRight.dx, endRight.dy);
    path.quadraticBezierTo(
        controlPoint.dx - perpendicular.dx * width,
        controlPoint.dy - perpendicular.dy * width,
        startRight.dx,
        startRight.dy);
    path.close();

    return path;
  }

  void _drawHand(Canvas canvas, Offset center, double radius, Paint fillPaint,
      Paint outlinePaint) {
    // Basit yuvarlak el
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, outlinePaint);
  }

  void _drawLegs(Canvas canvas, Offset center, double radius, Size size) {
    final legColor = const Color(0xFFFFD600);
    final legOutlineColor = const Color(0xFF2D2D2D);

    final legPaint = Paint()
      ..color = legColor
      ..style = PaintingStyle.fill;

    final legOutline = Paint()
      ..color = legOutlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final legWidth = radius * 0.2;
    final legLength = radius * 1.1;
    final legY = center.dy + radius * 0.7;

    // Sol bacak
    final leftLegPath = Path();
    final leftLegX = center.dx - radius * 0.3;

    leftLegPath.moveTo(leftLegX - legWidth, legY);
    leftLegPath.lineTo(leftLegX - legWidth * 0.9, legY + legLength);
    leftLegPath.quadraticBezierTo(
      leftLegX,
      legY + legLength + legWidth * 0.8,
      leftLegX + legWidth * 0.9,
      legY + legLength,
    );
    leftLegPath.lineTo(leftLegX + legWidth, legY);
    leftLegPath.close();

    canvas.drawPath(leftLegPath, legPaint);
    canvas.drawPath(leftLegPath, legOutline);

    // Sol ayak
    final leftFootPath = Path();
    leftFootPath.addOval(Rect.fromCenter(
      center: Offset(leftLegX, legY + legLength + legWidth * 0.3),
      width: legWidth * 2.5,
      height: legWidth * 1.2,
    ));
    canvas.drawPath(leftFootPath, legPaint);
    canvas.drawPath(leftFootPath, legOutline);

    // Sağ bacak
    final rightLegPath = Path();
    final rightLegX = center.dx + radius * 0.3;

    rightLegPath.moveTo(rightLegX - legWidth, legY);
    rightLegPath.lineTo(rightLegX - legWidth * 0.9, legY + legLength);
    rightLegPath.quadraticBezierTo(
      rightLegX,
      legY + legLength + legWidth * 0.8,
      rightLegX + legWidth * 0.9,
      legY + legLength,
    );
    rightLegPath.lineTo(rightLegX + legWidth, legY);
    rightLegPath.close();

    canvas.drawPath(rightLegPath, legPaint);
    canvas.drawPath(rightLegPath, legOutline);

    // Sağ ayak
    final rightFootPath = Path();
    rightFootPath.addOval(Rect.fromCenter(
      center: Offset(rightLegX, legY + legLength + legWidth * 0.3),
      width: legWidth * 2.5,
      height: legWidth * 1.2,
    ));
    canvas.drawPath(rightFootPath, legPaint);
    canvas.drawPath(rightFootPath, legOutline);
  }

  @override
  bool shouldRepaint(covariant _MomoProPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.blinkValue != blinkValue ||
        oldDelegate.waveValue != waveValue ||
        oldDelegate.breathValue != breathValue;
  }
}

/// Mesaj balonu
class _MessageBubble extends StatelessWidget {
  final String message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2D2D2D),
          height: 1.4,
        ),
      ),
    );
  }
}
