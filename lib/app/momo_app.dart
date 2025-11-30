import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:momo_ajanda/app/app_theme.dart';
import 'package:momo_ajanda/features/splash/presentation/pages/splash_screen.dart';

class MomoApp extends StatelessWidget {
  const MomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momo Ajanda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),

      // Türkçe dil desteği için gerekli ayarlar
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('tr', 'TR'),

      home: const SplashScreen(),
    );
  }
}
