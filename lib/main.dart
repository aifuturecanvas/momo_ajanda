import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/app/momo_app.dart';
import 'package:momo_ajanda/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase'i başlat
  await SupabaseService().initialize();

  runApp(
    const ProviderScope(
      child: MomoApp(),
    ),
  );
}
