import 'package:flutter/material.dart';
import 'package:momo_ajanda/features/main/presentation/pages/main_screen.dart'; // Yönlendirilecek yeni ekran
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                const FlutterLogo(size: 60),
                const SizedBox(height: 24),
                Text(
                  'Momo\'ya Hoş Geldin!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajandanı yönetmeye başla.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),

                // E-posta alanı
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Şifre alanı
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Giriş Yap butonu
                ElevatedButton(
                  onPressed: () {
                    // Yönlendirmeyi MainScreen'e yapıyoruz.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  child: const Text('Giriş Yap'),
                ),
                const SizedBox(height: 16),
                const Text('VEYA', textAlign: TextAlign.center),
                const SizedBox(height: 16),

                // Google ile Devam Et butonu
                OutlinedButton.icon(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.g_mobiledata), // İkonu güncelleyebiliriz
                  label: const Text('G. Google ile Devam Et'),
                ),
                const SizedBox(height: 12),

                // Apple ile Devam Et butonu
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.apple),
                  label: const Text('Apple ile Devam Et'),
                ),
                const SizedBox(height: 24),

                // Misafir olarak devam et
                TextButton(
                  onPressed: () {
                    // Yönlendirmeyi MainScreen'e yapıyoruz.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  child: const Text('Misafir olarak devam et | Hesap Oluştur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
