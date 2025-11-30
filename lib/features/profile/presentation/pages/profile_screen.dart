import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temadan renkleri ve stilleri daha kolay erişim için alıyoruz.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil ve Ayarlar'),
      ),
      body: ListView(
        children: [
          // === KULLANICI BİLGİLERİ KARTI ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanıcı Adı',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'kullanici@momoajanda.com',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    // Premium Etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // === AYARLAR LİSTESİ ===
          _buildSectionTitle(context, 'Genel'),
          _buildSettingsTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Genel Ayarlar',
            subtitle: 'Haftanın ilk günü, saat formatı...',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Tema & Görünüm',
            subtitle: 'Açık/Koyu mod, defter stilleri...',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: 'Dil & Bölge',
            subtitle: 'Uygulama dili, resmi tatiller...',
            onTap: () {},
          ),

          _buildSectionTitle(context, 'Bildirimler'),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Bildirim Ayarları',
            subtitle: 'Etkinlik, görev ve özet hatırlatmaları',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.smart_toy_outlined,
            title: 'Momo Asistan Ayarları',
            subtitle: 'Sesli yanıt, proaktif öneriler...',
            onTap: () {},
          ),

          _buildSectionTitle(context, 'Hesap & Veri'),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Güvenlik',
            subtitle: 'Uygulama kilidi, 2FA...',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.cloud_sync_outlined,
            title: 'Veri & Yedekleme',
            subtitle: 'Senkronizasyon, dışa aktarma...',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Hakkında',
            subtitle: 'Uygulama sürümü, lisanslar...',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Ayar listesi elemanlarını oluşturan yardımcı bir fonksiyon. Kod tekrarını önler.
  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Bölüm başlıklarını oluşturan yardımcı bir fonksiyon.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
