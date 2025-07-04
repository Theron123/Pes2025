import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/network/supabase_client.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for iOS status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
    // Continue app execution even if Supabase fails to initialize
    // This allows the app to work in offline mode or with placeholder data
  }

  // Initialize dependency injection
  try {
    await di.init();
    debugPrint('✅ Dependency injection initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize dependency injection: $e');
    // This is critical - the app cannot function without proper DI
    return;
  }

  // Run the Hospital Massage System app
  runApp(const HospitalMassageApp());
}
