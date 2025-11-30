import 'dart:async';
import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/auth/presentation/pages/login_screen.dart';

// Sınıf adını projenin geri kalanıyla tutarlı olacak şekilde düzeltiyoruz.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State sınıfının adını da yeni yapıya uygun hale getiriyoruz.
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() {
    // Gelecekte burada ayarları yükleme, kullanıcı oturumunu kontrol etme
    // gibi işlemler yapılabilir. Şimdilik sadece bekliyoruz.
    Timer(const Duration(seconds: 3), () {
      // 'mounted' kontrolü, widget hala ekranda mı diye kontrol eder.
      // Bu, zamanlayıcı bittiğinde ekran çoktan geçilmişse hata almayı önler.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold'un arka plan rengini artık merkezi temamızdan alıyoruz.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Buraya ileride kendi logomuz gelecek.
            const FlutterLogo(size: 100),
            const SizedBox(height: 24),
            // Yazı stilini de temamızdan alarak tutarlılık sağlıyoruz.
            Text(
              'Momo Akıllı Ajanda',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 48),
            // Kullanıcıya bir işlem yapıldığı hissini vermek için yükleme göstergesi.
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
