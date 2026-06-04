// =============================================================================
// providers/favorites_provider.dart
// Category 2 Enhancements:
//   #6  Notes on Favorites
//   #7  Recently Viewed
//   #8  Favorite Count History
// Category 3 Enhancements:
//   #9  Color Theme Picker  — accent color saved to SharedPreferences
//   #10 Default Category    — last selected Browse tab saved
//   #11 Font Size Setting   — Small / Medium / Large saved
// =============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sample_data.dart';
import '../models/city_model.dart';
import '../models/hobby_model.dart';
import '../models/book_model.dart';
import '../models/recently_viewed_item.dart';

// ── Enhancement #9: Accent color options ─────────────────────────────────────
enum AppAccentColor {
  deepPurple,
  teal,
  orange,
  rose,
  indigo,
}

extension AppAccentColorX on AppAccentColor {
  Color get color => switch (this) {
    AppAccentColor.deepPurple => Colors.deepPurple,
    AppAccentColor.teal       => Colors.teal,
    AppAccentColor.orange     => Colors.orange,
    AppAccentColor.rose       => const Color(0xFFE91E8C),
    AppAccentColor.indigo     => Colors.indigo,
  };

  String get label => switch (this) {
    AppAccentColor.deepPurple => 'Purple',
    AppAccentColor.teal       => 'Teal',
    AppAccentColor.orange     => 'Orange',
    AppAccentColor.rose       => 'Rose',
    AppAccentColor.indigo     => 'Indigo',
  };
}

// ── Enhancement #11: Font size options ───────────────────────────────────────
enum AppFontSize { small, medium, large }

extension AppFontSizeX on AppFontSize {
  double get scale => switch (this) {
    AppFontSize.small  => 0.85,
    AppFontSize.medium => 1.0,
    AppFontSize.large  => 1.2,
  };

  String get label => switch (this) {
    AppFontSize.small  => 'Small',
    AppFontSize.medium => 'Medium',
    AppFontSize.large  => 'Large',
  };
}

// ── Enhancement #10: Default category enum ───────────────────────────────────
enum DefaultCategory { cities, hobbies, books }

class FavoritesProvider extends ChangeNotifier {
  // ── Core state ────────────────────────────────────────────────────────────
  bool isDarkMode = false;

  // Category 3
  AppAccentColor accentColor    = AppAccentColor.deepPurple;
  DefaultCategory defaultCategory = DefaultCategory.cities;
  AppFontSize fontSize           = AppFontSize.medium;

  final List<CityModel>  cities  = sampleCities;
  final List<HobbyModel> hobbies = sampleHobbies;
  final List<BookModel>  books   = sampleBooks;

  // Category 2: Notes
  final Map<String, String> _notes = {};
  String noteFor(String key) => _notes[key] ?? '';
  void setNote(String key, String note) {
    if (note.trim().isEmpty) {
      _notes.remove(key);
    } else {
      _notes[key] = note.trim();
    }
    _saveNotes();
    notifyListeners();
  }

  // Category 2: Recently Viewed
  static const int _maxRecent = 5;
  final List<RecentlyViewedItem> _recentlyViewed = [];
  List<RecentlyViewedItem> get recentlyViewed =>
      List.unmodifiable(_recentlyViewed);

  void recordView(RecentlyViewedItem item) {
    _recentlyViewed.removeWhere((r) => r.id == item.id);
    _recentlyViewed.insert(0, item);
    if (_recentlyViewed.length > _maxRecent) {
      _recentlyViewed.removeLast();
    }
    _saveRecentlyViewed();
    notifyListeners();
  }

  // Category 2: Stats
  int _allTimeFavoriteCount = 0;
  int _allTimeCities  = 0;
  int _allTimeHobbies = 0;
  int _allTimeBooks   = 0;
  int get allTimeFavoriteCount => _allTimeFavoriteCount;
  int get allTimeCities        => _allTimeCities;
  int get allTimeHobbies       => _allTimeHobbies;
  int get allTimeBooks         => _allTimeBooks;

  // ── Constructor ───────────────────────────────────────────────────────────
  FavoritesProvider() {
    _loadAll();
  }

  // ── Computed ──────────────────────────────────────────────────────────────
  List<CityModel>  get favoriteCities  =>
      cities.where((c) => c.isFavorite).toList();
  List<HobbyModel> get favoriteHobbies =>
      hobbies.where((h) => h.isFavorite).toList();
  List<BookModel>  get favoriteBooks   =>
      books.where((b) => b.isFavorite).toList();
  int get totalFavoriteCount =>
      favoriteCities.length + favoriteHobbies.length + favoriteBooks.length;

  // ── Toggle favorites ──────────────────────────────────────────────────────
  void toggleCityFavorite(int id) {
    final item = cities.firstWhere((c) => c.id == id);
    item.isFavorite = !item.isFavorite;
    if (item.isFavorite) { _allTimeFavoriteCount++; _allTimeCities++; _saveStats(); }
    _saveAll();
    notifyListeners();
  }

  void toggleHobbyFavorite(int id) {
    final item = hobbies.firstWhere((h) => h.id == id);
    item.isFavorite = !item.isFavorite;
    if (item.isFavorite) { _allTimeFavoriteCount++; _allTimeHobbies++; _saveStats(); }
    _saveAll();
    notifyListeners();
  }

  void toggleBookFavorite(int id) {
    final item = books.firstWhere((b) => b.id == id);
    item.isFavorite = !item.isFavorite;
    if (item.isFavorite) { _allTimeFavoriteCount++; _allTimeBooks++; _saveStats(); }
    _saveAll();
    notifyListeners();
  }

  void clearAllFavorites() {
    for (final c in cities)  { c.isFavorite = false; }
    for (final h in hobbies) { h.isFavorite = false; }
    for (final b in books)   { b.isFavorite = false; }
    _saveAll();
    notifyListeners();
  }

  // ── Category 3: Theme ─────────────────────────────────────────────────────
  void toggleDarkMode(bool value) {
    isDarkMode = value;
    _saveTheme();
    notifyListeners();
  }

  void setAccentColor(AppAccentColor color) {
    accentColor = color;
    _saveTheme();
    notifyListeners();
  }

  void setFontSize(AppFontSize size) {
    fontSize = size;
    _saveTheme();
    notifyListeners();
  }

  // ── Category 3: Default Category ─────────────────────────────────────────
  void setDefaultCategory(DefaultCategory cat) {
    defaultCategory = cat;
    _savePreferences();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCities',
        cities.where((c) => c.isFavorite).map((c) => c.id.toString()).toList());
    await prefs.setStringList('favoriteHobbies',
        hobbies.where((h) => h.isFavorite).map((h) => h.id.toString()).toList());
    await prefs.setStringList('favoriteBooks',
        books.where((b) => b.isFavorite).map((b) => b.id.toString()).toList());
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setInt('accentColor', accentColor.index);
    await prefs.setInt('fontSize',    fontSize.index);
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultCategory', defaultCategory.index);
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(_notes));
  }

  Future<void> _saveRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentlyViewed',
        _recentlyViewed.map((r) => r.toStorageString()).toList());
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('allTimeFavoriteCount', _allTimeFavoriteCount);
    await prefs.setInt('allTimeCities',  _allTimeCities);
    await prefs.setInt('allTimeHobbies', _allTimeHobbies);
    await prefs.setInt('allTimeBooks',   _allTimeBooks);
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    isDarkMode  = prefs.getBool('isDarkMode') ?? false;
    accentColor = AppAccentColor.values[
    prefs.getInt('accentColor') ?? 0];
    fontSize    = AppFontSize.values[
    prefs.getInt('fontSize') ?? 1];

    // Preferences
    defaultCategory = DefaultCategory.values[
    prefs.getInt('defaultCategory') ?? 0];

    // Favorites
    final cityIds  = prefs.getStringList('favoriteCities')  ?? [];
    final hobbyIds = prefs.getStringList('favoriteHobbies') ?? [];
    final bookIds  = prefs.getStringList('favoriteBooks')   ?? [];
    for (final c in cities)  { c.isFavorite = cityIds.contains(c.id.toString()); }
    for (final h in hobbies) { h.isFavorite = hobbyIds.contains(h.id.toString()); }
    for (final b in books)   { b.isFavorite = bookIds.contains(b.id.toString()); }

    // Notes
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final decoded = jsonDecode(notesJson) as Map<String, dynamic>;
      _notes.addAll(decoded.map((k, v) => MapEntry(k, v.toString())));
    }

    // Recently viewed
    final recentStrs = prefs.getStringList('recentlyViewed') ?? [];
    _recentlyViewed.addAll(
        recentStrs.map(RecentlyViewedItem.fromStorageString));

    // Stats
    _allTimeFavoriteCount = prefs.getInt('allTimeFavoriteCount') ?? 0;
    _allTimeCities        = prefs.getInt('allTimeCities')  ?? 0;
    _allTimeHobbies       = prefs.getInt('allTimeHobbies') ?? 0;
    _allTimeBooks         = prefs.getInt('allTimeBooks')   ?? 0;

    notifyListeners();
  }
}