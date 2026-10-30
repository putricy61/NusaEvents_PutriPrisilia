import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_events_screen.dart';

void main() {
  runApp(const NusaEventHubApp());
}

class NusaEventHubApp extends StatelessWidget {
  const NusaEventHubApp({super.key});

  static const Color _quantumBlue = Color(0xFF1F4FE0);
  static const Color _quantumDeep = Color(0xFF173DB5);

  static ColorScheme get _lightScheme =>
      ColorScheme.fromSeed(seedColor: _quantumBlue).copyWith(
        primary: _quantumBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD9E5FF),
        onPrimaryContainer: const Color(0xFF0E2A94),
        secondaryContainer: const Color(0xFFD3EAFB),
        onSecondaryContainer: const Color(0xFF0E2A94),
        // Ice glass
        surface: const Color(0xFFF2F9FF),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF8FCFF),
        surfaceContainer: const Color(0xFFE8F4FD),
        surfaceContainerHigh: const Color(0xFFDCEEFA),
        surfaceContainerHighest: const Color(0xFFD3E9F9),
        outline: const Color(0xFF6F93B8),
        outlineVariant: const Color(0xFFBBD9F0),
      );

  static ColorScheme get _darkScheme => ColorScheme.fromSeed(
        seedColor: _quantumBlue,
        brightness: Brightness.dark,
      );

  static ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _quantumDeep,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 44,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaEvent Hub',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _theme(_lightScheme),
      darkTheme: _theme(_darkScheme),
      home: const HomeEventsScreen(),
    );
  }
}
