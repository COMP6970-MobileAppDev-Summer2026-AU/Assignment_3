// =============================================================================
// main.dart
// Flow: HomeScreen → OnboardingScreen (first launch) → ContentView
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: const FavoritesApp(),
    ),
  );
}

class FavoritesApp extends StatelessWidget {
  const FavoritesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prov      = context.watch<FavoritesProvider>();
    final textTheme = _scaledTextTheme(prov.fontSize.scale);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Favorite Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: prov.accentColor.color,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: textTheme,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: prov.accentColor.color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: textTheme,
      ),
      themeMode: prov.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Always show HomeScreen first — it routes to onboarding or main app
      home: const HomeScreen(),
    );
  }

  TextTheme _scaledTextTheme(double scale) {
    return TextTheme(
      bodyLarge:   TextStyle(fontSize: 16 * scale),
      bodyMedium:  TextStyle(fontSize: 14 * scale),
      bodySmall:   TextStyle(fontSize: 12 * scale),
      titleLarge:  TextStyle(fontSize: 22 * scale),
      titleMedium: TextStyle(fontSize: 16 * scale),
      titleSmall:  TextStyle(fontSize: 14 * scale),
      labelLarge:  TextStyle(fontSize: 14 * scale),
      labelMedium: TextStyle(fontSize: 12 * scale),
      labelSmall:  TextStyle(fontSize: 11 * scale),
    );
  }
}