import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;
import 'momo_enums.dart';
import 'momo_particle.dart';
import 'momo_painter.dart';

class MomoActor extends StatefulWidget {
  final MomoMood mood;
  final double intensity;
  final bool isSpeaking;
  final double simulatedAudioLevel;
  final VoidCallback? onTap;

  const MomoActor({
    super.key,
    required this.mood,
    required this.intensity,
    this.isSpeaking = false,
    this.simulatedAudioLevel = 0.0,
    this.onTap,
  });

  @override
  State<MomoActor> createState() => _MomoActorState();
}

class _MomoActorState extends State<MomoActor> with TickerProviderStateMixin {
  late AnimationController _mainLoop;

  Offset _dragOffset = Offset.zero;
  Offset _velocity = Offset.zero;
  double _squashY = 1.0;
  double _squashX = 1.0;
  double _tilt = 0.0;

  Offset _handTargetLeft = const Offset(-90, 50);
  Offset _handTargetRight = const Offset(90, 50);
  Offset _lookTarget = Offset.zero;

  double _breathTime = 0.0;
  Timer? _blinkTimer;
  double _blinkValue = 0.0;

  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _mainLoop =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _mainLoop.addListener(_gameLoop);
    _startBlinkRoutine();
  }

  @override
  void didUpdateWidget(MomoActor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      if (widget.mood == MomoMood.celebrate) {
        _spawnConfetti();
        _velocity += const Offset(0, -5);
        _squashY = 1.1;
        _squashX = 0.95;
      } else if (widget.mood == MomoMood.surprised) {
        _velocity += Offset(0, -10 * widget.intensity);
        _squashY = 1.0 + (0.4 * widget.intensity);
        _squashX = 1.0 - (0.2 * widget.intensity);
      } else if (widget.mood != MomoMood.angry) {
        _particles.clear();
      }
    }
  }

  void _spawnConfetti() {
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle.confetti());
    }
  }

  void _startBlinkRoutine() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(
        Duration(milliseconds: 2000 + math.Random().nextInt(2000)), () async {
      if (widget.mood != MomoMood.surprised) {
        for (double i = 0; i <= 1.0; i += 0.25) {
          if (!mounted) return;
          setState(() => _blinkValue = i);
          await Future.delayed(const Duration(milliseconds: 16));
        }
        for (double i = 1.0; i >= 0.0; i -= 0.25) {
          if (!mounted) return;
          setState(() => _blinkValue = i);
          await Future.delayed(const Duration(milliseconds: 16));
        }
      }
      _startBlinkRoutine();
    });
  }

  void _gameLoop() {
    double dt = 0.016;
    _breathTime += dt * (1 + widget.intensity * 0.5);

    if (_dragOffset.distance > 0.1) {
      var force = -_dragOffset * 0.2;
      _velocity += force;
      _velocity *= 0.85;
      _dragOffset += _velocity;
    } else {
      _dragOffset = Offset.zero;
      _velocity = Offset.zero;
    }

    double targetSx = 1.0 + (_velocity.dy.abs() * 0.005).clamp(-0.1, 0.1);
    double targetSy = 1.0 - (_velocity.dy.abs() * 0.005).clamp(-0.1, 0.1);

    if (widget.mood == MomoMood.sad) {
      targetSy *= 0.98;
    } else if (widget.mood == MomoMood.surprised) {
      double surpriseFactor = widget.intensity * 0.3;
      targetSy *= (1.0 + surpriseFactor);
      targetSx *= (1.0 - surpriseFactor * 0.5);
    }

    _squashX = ui.lerpDouble(_squashX, targetSx, 0.2)!;
    _squashY = ui.lerpDouble(_squashY, targetSy, 0.2)!;

    double targetTilt = _velocity.dx * 0.05;
    if (widget.mood == MomoMood.thinking) targetTilt += 0.15;

    _tilt = ui.lerpDouble(_tilt, targetTilt, 0.1)!;

    _updateHandTargets();

    Offset targetLook = Offset(_dragOffset.dx / 30, _dragOffset.dy / 30);

    if (widget.mood == MomoMood.thinking) {
      targetLook = const Offset(1.5, -1.5);
    } else if (widget.mood == MomoMood.sad) {
      targetLook = Offset(0, 1.5 + widget.intensity * 0.5);
    } else if (widget.mood == MomoMood.listening ||
        widget.mood == MomoMood.angry ||
        widget.mood == MomoMood.surprised) {
      targetLook = Offset.zero;
    }

    _lookTarget = Offset.lerp(_lookTarget, targetLook, 0.1)!;

    for (var p in _particles) {
      p.update();
    }
    _particles.removeWhere((p) => p.isDead);

    if (widget.mood == MomoMood.sad && widget.intensity > 0.5) {
      if (math.Random().nextDouble() < 0.02) {
        _particles.add(Particle.tear(const Offset(40, 10)));
      }
    }
    if (widget.mood == MomoMood.angry && widget.intensity > 0.3) {
      if (math.Random().nextDouble() < (0.05 * widget.intensity)) {
        _particles.add(Particle.steam(
            Offset((math.Random().nextDouble() - 0.5) * 100, -80)));
      }
    }

    if (mounted) setState(() {});
  }

  void _updateHandTargets() {
    MomoPose pose = _getPoseForMood(widget.mood);
    Offset targetL = const Offset(-90, 50);
    Offset targetR = const Offset(90, 50);

    switch (pose) {
      case MomoPose.surprisedDynamic:
        Offset neutralL = const Offset(-95, 40);
        Offset cheeksL = const Offset(-50, 10);
        Offset neutralR = const Offset(95, 40);
        Offset cheeksR = const Offset(50, 10);

        targetL = Offset.lerp(neutralL, cheeksL, widget.intensity)!;
        targetR = Offset.lerp(neutralR, cheeksR, widget.intensity)!;
        break;
      case MomoPose.handsOnCheeks:
        targetL = const Offset(-50, 10);
        targetR = const Offset(50, 10);
        break;
      case MomoPose.thinking:
        targetL = const Offset(-90, 60);
        targetR = const Offset(35, 45);
        break;
      case MomoPose.handsDown:
        targetL = const Offset(-80, 90);
        targetR = const Offset(80, 90);
        break;
      case MomoPose.celebrateUp:
        double wave = math.sin(_breathTime * 10) * 10;
        targetL = Offset(-100, -80 + wave);
        targetR = Offset(100, -80 - wave);
        break;
      case MomoPose.listeningEar:
        targetL = const Offset(-90, 50);
        targetR = const Offset(80, -30);
        break;
      default:
        double breathY = math.sin(_breathTime * 2) * 3;
        targetL += Offset(0, breathY);
        targetR += Offset(0, breathY);
    }

    double lerpSpeed = 0.1;
    if (widget.mood == MomoMood.surprised) lerpSpeed = 0.2;

    _handTargetLeft = Offset.lerp(_handTargetLeft, targetL, lerpSpeed)!;
    _handTargetRight = Offset.lerp(_handTargetRight, targetR, lerpSpeed)!;
  }

  MomoPose _getPoseForMood(MomoMood mood) {
    switch (mood) {
      case MomoMood.surprised:
        return MomoPose.surprisedDynamic;
      case MomoMood.thinking:
        return MomoPose.thinking;
      case MomoMood.angry:
        return MomoPose.neutral;
      case MomoMood.celebrate:
        return MomoPose.celebrateUp;
      case MomoMood.listening:
        return MomoPose.listeningEar;
      case MomoMood.sad:
        return MomoPose.handsDown;
      default:
        return MomoPose.neutral;
    }
  }

  @override
  void dispose() {
    _mainLoop.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double hoverY = math.sin(_breathTime) * 6;

    double jitterX = 0;
    if (widget.mood == MomoMood.angry) {
      jitterX = math.sin(_breathTime * 5) * 1.0;
    }

    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        _dragOffset += d.delta;
        _velocity = d.delta;
      }),
      onTap: widget.onTap,
      child: CustomPaint(
        size: const Size(300, 400),
        painter: AdvancedMomoPainter(
          offset: _dragOffset + Offset(jitterX, hoverY),
          tilt: _tilt,
          squashX: _squashX,
          squashY: _squashY,
          lookTarget: _lookTarget,
          handL: _handTargetLeft,
          handR: _handTargetRight,
          mood: widget.mood,
          intensity: widget.intensity,
          blinkValue: _blinkValue,
          breathTime: _breathTime,
          audioLevel: widget.simulatedAudioLevel,
          particles: _particles,
        ),
      ),
    );
  }
}
