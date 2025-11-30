import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:momo_ajanda/app/momo_app.dart';

// main fonksiyonunu Future<void> ve async olarak güncelliyoruz.
Future<void> main() async {
  // Flutter uygulamasının başlatılmadan önce bazı işlemler yapabilmesi için bu satır gerekli.
  WidgetsFlutterBinding.ensureInitialized();

  // YENİ: Tarih formatlaması için gerekli olan Türkçe yerelleştirme ayarını
  // uygulama başlarken SADECE BİR KERE burada yüklüyoruz.
  await initializeDateFormatting('tr_TR', null);

  // Riverpod'ı kullanabilmek için uygulamamızı ProviderScope ile sarmalıyoruz.
  runApp(const ProviderScope(child: MomoApp()));
}
