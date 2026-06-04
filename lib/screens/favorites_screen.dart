// =============================================================================
// screens/favorites_screen.dart
// Enhancement #2  — Swipe left to unfavorite (Dismissible)
// Enhancement #6  — Note indicator on tiles + note shown on favorites tile
// Enhancement #7  — Recently Viewed section at top
// Enhancement #8  — Favorite Count History stats card
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/city_model.dart';
import '../models/hobby_model.dart';
import '../models/book_model.dart';
import '../models/recently_viewed_item.dart';
import '../services/share_service.dart';
import 'item_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // GlobalKey so iOS can anchor the share popover to the button
  static final _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final prov    = context.watch<FavoritesProvider>();
    final cities  = prov.favoriteCities;
    final hobbies = prov.favoriteHobbies;
    final books   = prov.favoriteBooks;
    final total   = prov.totalFavoriteCount;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Favorites',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        Text(
                          '$total item${total == 1 ? '' : 's'} saved',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    if (total > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Enhancement #13: Share button
                          IconButton(
                            key: _shareKey,
                            onPressed: () => ShareService.shareFavorites(
                                context, prov, buttonKey: _shareKey),
                            icon: const Icon(Icons.share_outlined),
                            tooltip: 'Share favorites',
                          ),
                          // Enhancement #14: haptic on Clear tap
                          TextButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _confirmClear(context, prov);
                            },
                            icon: const Icon(Icons.delete_sweep, size: 18),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade400),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // ── Enhancement #7: Recently Viewed ────────────────────────
            if (prov.recentlyViewed.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _RecentlyViewedSection(
                      items: prov.recentlyViewed),
                ),
              ),

            // ── Swipe hint ─────────────────────────────────────────────
            if (total > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    'Swipe left to remove  •  Tap ♥ to unfavorite  •  Tap tile for notes',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11),
                  ),
                ),
              ),

            // ── Empty state ────────────────────────────────────────────
            if (total == 0)
              SliverFillRemaining(child: _emptyState()),

            // ── Cities ─────────────────────────────────────────────────
            if (cities.isNotEmpty) ...[
              _sectionHeaderSliver(context, '🌆 Cities', cities.length),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _SwipeToDismiss(
                      key: ValueKey('city_${cities[i].id}'),
                      onDismissed: () => prov.toggleCityFavorite(cities[i].id),
                      child: _CityTile(city: cities[i]),
                    ),
                    childCount: cities.length,
                  ),
                ),
              ),
            ],

            // ── Hobbies ────────────────────────────────────────────────
            if (hobbies.isNotEmpty) ...[
              _sectionHeaderSliver(context, '🎯 Hobbies', hobbies.length),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _SwipeToDismiss(
                      key: ValueKey('hobby_${hobbies[i].id}'),
                      onDismissed: () =>
                          prov.toggleHobbyFavorite(hobbies[i].id),
                      child: _HobbyTile(hobby: hobbies[i]),
                    ),
                    childCount: hobbies.length,
                  ),
                ),
              ),
            ],

            // ── Books ──────────────────────────────────────────────────
            if (books.isNotEmpty) ...[
              _sectionHeaderSliver(context, '📚 Books', books.length),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _SwipeToDismiss(
                      key: ValueKey('book_${books[i].id}'),
                      onDismissed: () => prov.toggleBookFavorite(books[i].id),
                      child: _BookTile(book: books[i]),
                    ),
                    childCount: books.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeaderSliver(
      BuildContext context, String title, int count) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.favorite_border,
            size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('No favorites yet',
            style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Browse cities, hobbies, and books\nand tap ♡ to save them here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    ),
  );

  void _confirmClear(BuildContext context, FavoritesProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content: const Text(
            'This will remove all saved cities, hobbies, and books.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              prov.clearAllFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Enhancement #7: Recently Viewed Section
// =============================================================================

class _RecentlyViewedSection extends StatelessWidget {
  final List<RecentlyViewedItem> items;
  const _RecentlyViewedSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, size: 16),
            const SizedBox(width: 6),
            const Text('Recently Viewed',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 4),
            Text('(last ${items.length})',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _RecentChip(item: items[i]),
          ),
        ),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  final RecentlyViewedItem item;
  const _RecentChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showItemDetailSheet(
        context,
        item.id,
        title:    item.title,
        subtitle: item.subtitle,
        icon:     item.icon,
        imageKey: item.imageKey,
      ),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageKey != null
                  ? SizedBox(
                width: 56, height: 56,
                child: Image.asset(
                  'assets/images/${item.imageKey}.jpeg',
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                width: 56, height: 56,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                child: Center(
                  child: item.icon != null
                      ? Text(item.icon!,
                      style: const TextStyle(fontSize: 24))
                      : Icon(Icons.menu_book_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Swipe to Dismiss Wrapper
// =============================================================================

class _SwipeToDismiss extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismissed;

  const _SwipeToDismiss({
    super.key,
    required this.child,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        // Enhancement #14: haptic on swipe dismiss
        HapticFeedback.mediumImpact();
        onDismissed();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.heart_broken, color: Colors.white, size: 26),
            SizedBox(height: 2),
            Text('Remove',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: child,
    );
  }
}

// =============================================================================
// Favorite Tiles (with note indicator)
// =============================================================================

class _CityTile extends StatelessWidget {
  final CityModel city;
  const _CityTile({required this.city});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FavoritesProvider>();
    final note = prov.noteFor('city_${city.id}');

    return GestureDetector(
      onTap: () => showItemDetailSheet(context, 'city_${city.id}',
          title: city.cityName, imageKey: city.cityImage),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            SizedBox(
              height: 80, width: double.infinity,
              child: Image.asset(
                  'assets/images/${city.cityImage}.jpeg',
                  fit: BoxFit.cover),
            ),
            Container(height: 80,
                color: Colors.black.withValues(alpha: 0.35)),
            SizedBox(
              height: 80,
              child: ListTile(
                title: Row(
                  children: [
                    Text(city.cityName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    if (note.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.sticky_note_2,
                          color: Colors.amber, size: 14),
                    ],
                  ],
                ),
                subtitle: Text(
                  note.isNotEmpty ? note : 'City  •  Tap for note',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite,
                      color: Colors.red, size: 22),
                  onPressed: () =>
                      prov.toggleCityFavorite(city.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HobbyTile extends StatelessWidget {
  final HobbyModel hobby;
  const _HobbyTile({required this.hobby});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FavoritesProvider>();
    final note = prov.noteFor('hobby_${hobby.id}');

    return GestureDetector(
      onTap: () => showItemDetailSheet(context, 'hobby_${hobby.id}',
          title: hobby.hobbyName, icon: hobby.hobbyIcon),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Text(hobby.hobbyIcon,
              style: const TextStyle(fontSize: 28)),
          title: Row(
            children: [
              Text(hobby.hobbyName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              if (note.isNotEmpty) ...[
                const SizedBox(width: 6),
                const Icon(Icons.sticky_note_2,
                    color: Colors.amber, size: 14),
              ],
            ],
          ),
          subtitle: Text(
            note.isNotEmpty ? note : 'Tap for note',
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
            onPressed: () => prov.toggleHobbyFavorite(hobby.id),
          ),
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final BookModel book;
  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FavoritesProvider>();
    final note = prov.noteFor('book_${book.id}');

    return GestureDetector(
      onTap: () => showItemDetailSheet(context, 'book_${book.id}',
          title: book.bookTitle, subtitle: book.bookAuthor),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.primary),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(book.bookTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(width: 4),
                const Icon(Icons.sticky_note_2,
                    color: Colors.amber, size: 14),
              ],
            ],
          ),
          subtitle: Text(
            note.isNotEmpty ? note : book.bookAuthor,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
            onPressed: () => prov.toggleBookFavorite(book.id),
          ),
        ),
      ),
    );
  }
}