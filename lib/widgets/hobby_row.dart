// =============================================================================
// widgets/hobby_row.dart
// Supports 3 view modes: list, grid, compact
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hobby_model.dart';
import '../models/recently_viewed_item.dart';
import '../providers/favorites_provider.dart';
import '../screens/item_detail_screen.dart';
import 'animated_heart_button.dart';
import 'city_card.dart' show ViewMode;

class HobbyRow extends StatelessWidget {
  final HobbyModel hobby;
  final ViewMode   viewMode;

  const HobbyRow({
    super.key,
    required this.hobby,
    this.viewMode = ViewMode.list,
  });

  void _openDetail(BuildContext context, FavoritesProvider prov) {
    prov.recordView(RecentlyViewedItem(
      id: 'hobby_${hobby.id}', category: 'hobby',
      title: hobby.hobbyName, icon: hobby.hobbyIcon,
      viewedAt: DateTime.now(),
    ));
    showItemDetailSheet(context, 'hobby_${hobby.id}',
        title: hobby.hobbyName, icon: hobby.hobbyIcon);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<FavoritesProvider>();
    final note = context.watch<FavoritesProvider>().noteFor('hobby_${hobby.id}');

    return switch (viewMode) {
      ViewMode.list    => _buildList(context, prov, note),
      ViewMode.grid    => _buildGrid(context, prov, note),
      ViewMode.compact => _buildCompact(context, prov, note),
    };
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, FavoritesProvider prov, String note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _openDetail(context, prov),
        leading: Text(hobby.hobbyIcon, style: const TextStyle(fontSize: 28)),
        title: Row(children: [
          Text(hobby.hobbyName,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          if (note.isNotEmpty) ...[
            const SizedBox(width: 6),
            const Icon(Icons.sticky_note_2, color: Colors.amber, size: 14),
          ],
        ]),
        subtitle: const Text('Tap for details', style: TextStyle(fontSize: 11)),
        trailing: AnimatedHeartButton(
          isFavorite: hobby.isFavorite,
          onTap: () => context.read<FavoritesProvider>().toggleHobbyFavorite(hobby.id),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hobby.hobbyIcon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      hobby.hobbyName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    const Icon(Icons.sticky_note_2,
                        color: Colors.amber, size: 10),
                  ],
                ],
              ),
            ),
            AnimatedHeartButton(
              isFavorite: hobby.isFavorite,
              size: 18,
              activeColor: scheme.error,
              onTap: () => context
                  .read<FavoritesProvider>()
                  .toggleHobbyFavorite(hobby.id),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compact ───────────────────────────────────────────────────────────────
  Widget _buildCompact(BuildContext context, FavoritesProvider prov, String note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context, prov),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(hobby.hobbyIcon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Row(children: [
                  Text(hobby.hobbyName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  if (note.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.sticky_note_2, color: Colors.amber, size: 13),
                  ],
                ]),
              ),
              AnimatedHeartButton(
                isFavorite: hobby.isFavorite, size: 22,
                onTap: () => context.read<FavoritesProvider>().toggleHobbyFavorite(hobby.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}