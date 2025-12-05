import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ParticleType { confetti, tear, steam }

class Particle {
  ParticleType type;
  double x, y;
  double speedX, speedY;
  double rotation = 0;
  double rotSpeed = 0;
  double scale = 1.0;
  double opacity = 1.0;
  Color color = Colors.white;
  bool isDead = false;

  Particle.confetti()
      : type = ParticleType.confetti,
        x = (math.Random().nextDouble() - 0.5) * 300,
        y = -250 - math.Random().nextDouble() * 100,
        speedX = (math.Random().nextDouble() - 0.5) * 2,
        speedY = 3 + math.Random().nextDouble() * 4,
        rotSpeed = (math.Random().nextDouble() - 0.5) * 0.2,
        color =
            Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

  Particle.tear(Offset startPos)
      : type = ParticleType.tear,
        x = startPos.dx,
        y = startPos.dy + 20,
        speedX = 0,
        speedY = 2,
        color = Colors.blue;

  Particle.steam(Offset startPos)
      : type = ParticleType.steam,
        x = startPos.dx,
        y = startPos.dy,
        speedX = (math.Random().nextDouble() - 0.5) * 1,
        speedY = -2 - math.Random().nextDouble(),
        scale = 0.5;

  void update() {
    if (type == ParticleType.confetti) {
      y += speedY;
      x += speedX + math.sin(y * 0.05);
      rotation += rotSpeed;
      if (y > 300) isDead = true;
    } else if (type == ParticleType.tear) {
      y += speedY;
      speedY *= 1.05;
      opacity -= 0.01;
      if (opacity <= 0) isDead = true;
    } else if (type == ParticleType.steam) {
      y += speedY;
      scale += 0.02;
      opacity -= 0.015;
      if (opacity <= 0) isDead = true;
    }
  }
}
