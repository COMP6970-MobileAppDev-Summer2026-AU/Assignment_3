// =============================================================================
// services/share_service.dart
// Enhancement #13 — Share favorites list via OS share sheet
// iOS requires sharePositionOrigin — pass button's render box rect
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/favorites_provider.dart';

class ShareService {
  /// Share via OS sheet. [buttonKey] is the GlobalKey of the share IconButton
  /// so iOS can anchor the popover to the correct position.
  static Future<void> shareFavorites(
      BuildContext context,
      FavoritesProvider prov, {
        GlobalKey? buttonKey,
      }) async {
    final cities  = prov.favoriteCities;
    final hobbies = prov.favoriteHobbies;
    final books   = prov.favoriteBooks;

    if (cities.isEmpty && hobbies.isEmpty && books.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No favorites to share yet!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final buf = StringBuffer();
    buf.writeln('⭐ My Favorites — Favorites App');
    buf.writeln('');

    if (cities.isNotEmpty) {
      buf.writeln('🌆 Cities (${cities.length})');
      for (final c in cities) {
        buf.writeln('  • ${c.cityName}');
        final note = prov.noteFor('city_${c.id}');
        if (note.isNotEmpty) { buf.writeln('    📝 $note'); }
      }
      buf.writeln('');
    }

    if (hobbies.isNotEmpty) {
      buf.writeln('🎯 Hobbies (${hobbies.length})');
      for (final h in hobbies) {
        buf.writeln('  ${h.hobbyIcon} ${h.hobbyName}');
        final note = prov.noteFor('hobby_${h.id}');
        if (note.isNotEmpty) { buf.writeln('    📝 $note'); }
      }
      buf.writeln('');
    }

    if (books.isNotEmpty) {
      buf.writeln('📚 Books (${books.length})');
      for (final b in books) {
        buf.writeln('  • ${b.bookTitle}');
        buf.writeln('    by ${b.bookAuthor}');
        final note = prov.noteFor('book_${b.id}');
        if (note.isNotEmpty) { buf.writeln('    📝 $note'); }
      }
      buf.writeln('');
    }

    buf.writeln('Total: ${prov.totalFavoriteCount} favorites');
    buf.writeln('Shared from Favorites App — COMP 6910');

    // Resolve button position for iOS popover anchor
    final box = buttonKey?.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 1, 1);

    await Share.share(
      buf.toString(),
      subject: 'My Favorites List',
      sharePositionOrigin: origin,
    );
  }

  /// Copy favorites list to clipboard as fallback
  static Future<void> copyToClipboard(
      BuildContext context,
      FavoritesProvider prov,
      ) async {
    final cities  = prov.favoriteCities;
    final hobbies = prov.favoriteHobbies;
    final books   = prov.favoriteBooks;

    final lines = <String>[
      if (cities.isNotEmpty)
        'Cities: ${cities.map((c) => c.cityName).join(', ')}',
      if (hobbies.isNotEmpty)
        'Hobbies: ${hobbies.map((h) => h.hobbyName).join(', ')}',
      if (books.isNotEmpty)
        'Books: ${books.map((b) => b.bookTitle).join(', ')}',
    ];

    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}