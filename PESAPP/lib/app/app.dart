import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import '../core/di/bloc_providers.dart';

/// Main application widget for Hospital Massage System
class HospitalMassageApp extends StatelessWidget {
  const HospitalMassageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProviders.configure(
      child: MaterialApp.router(
        // App Configuration
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Theme Configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // For now, always use light theme
        
        // Localization Configuration
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Spanish
          Locale('en', 'US'), // English (fallback)
        ],
        
        // Router Configuration
        routerConfig: AppRouter.router,
        
        // Builder for global configurations
        builder: (context, child) {
          return MediaQuery(
            // Ensure text scaling doesn't exceed accessibility limits
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.4)),
            ),
            child: child!,
          );
        },
      ),
    );
  }
} 