import 'package:flutter/material.dart';

/// Momo'nun ruh halleri
enum MomoMood {
  idle("Beklemede", Color(0xFFF0F4F8), Color(0xFF00B0FF)),
  happy("Mutlu", Color(0xFFFFF8E1), Color(0xFFFFAB40)),
  sad("Üzgün", Color(0xFFE1F5FE), Color(0xFF546E7A)),
  angry("Öfkeli", Color(0xFFFFEBEE), Color(0xFFC62828)),
  surprised("Şaşkın", Color(0xFFE8F5E9), Color(0xFF2E7D32)),
  thinking("Düşünüyor", Color(0xFFF3E5F5), Color(0xFF8E24AA)),
  listening("Dinliyor", Color(0xFFE0F7FA), Color(0xFF00BCD4)),
  celebrate("KUTLAMA!", Color(0xFFE0F2F1), Color(0xFF1DE9B6));

  final String label;
  final Color bgColor;
  final Color accentColor;
  const MomoMood(this.label, this.bgColor, this.accentColor);
}

/// İskelet Pozları
enum MomoPose {
  neutral,
  handsDown,
  thinking,
  handsOnCheeks,
  celebrateUp,
  listeningEar,
  surprisedDynamic,
}
