// =============================================================================
// widgets/book_row.dart
// Supports 3 view modes: list, grid, compact
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../models/recently_viewed_item.dart';
import '../providers/favorites_provider.dart';
import '../screens/item_detail_screen.dart';
import 'animated_heart_button.dart';
import 'city_card.dart' show ViewMode;

class BookRow extends StatelessWidget {
  final BookModel book;
  final ViewMode  viewMode;

  const BookRow({
    super.key,
    required this.book,
    this.viewMode = ViewMode.list,
  });

  void _openDetail(BuildContext context, FavoritesProvider prov) {
    prov.recordView(RecentlyViewedItem(
      id: 'book_${book.id}', category: 'book',
      title: book.bookTitle, subtitle: book.bookAuthor,
      viewedAt: DateTime.now(),
    ));
    showItemDetailSheet(context, 'book_${book.id}',
        title: book.bookTitle, subtitle: book.bookAuthor);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<FavoritesProvider>();
    final note = context.watch<FavoritesProvider>().noteFor('book_${book.id}');

    return switch (viewMode) {
      ViewMode.list    => _buildList(context, prov, note),
      ViewMode.grid    => _buildGrid(context, prov, note),
      ViewMode.compact => _buildCompact(context, prov, note),
    };
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, FavoritesProvider prov, String note) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _openDetail(context, prov),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.menu_book_rounded, color: scheme.primary),
        ),
        title: Row(children: [
          Expanded(
            child: Text(book.bookTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(width: 4),
            const Icon(Icons.sticky_note_2, color: Colors.amber, size: 14),
          ],
        ]),
        subtitle: Text(book.bookAuthor,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: AnimatedHeartButton(
          isFavorite: book.isFavorite,
          onTap: () => context.read<FavoritesProvider>().toggleBookFavorite(book.id),
        ),
      ),
    );
  }

  // ── Grid ─────────────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, FavoritesProvider prov, String note) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _openDetail(context, prov),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.menu_book_rounded,
                        color: scheme.primary, size: 36),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Row(children: [
                Expanded(
                  child: Text(book.bookTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
                if (note.isNotEmpty)
                  const Icon(Icons.sticky_note_2, color: Colors.amber, size: 12),
              ]),
              const SizedBox(height: 2),
              Text(book.bookAuthor,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedHeartButton(
                    isFavorite: book.isFavorite, size: 20,
                    activeColor: scheme.error,
                    onTap: () => context.read<FavoritesProvider>().toggleBookFavorite(book.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact ───────────────────────────────────────────────────────────────
  Widget _buildCompact(BuildContext context, FavoritesProvider prov, String note) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context, prov),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.menu_book_rounded,
                    color: scheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(book.bookTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.sticky_note_2, color: Colors.amber, size: 12),
                      ],
                    ]),
                    Text(book.bookAuthor,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              AnimatedHeartButton(
                isFavorite: book.isFavorite, size: 22,
                onTap: () => context.read<FavoritesProvider>().toggleBookFavorite(book.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}