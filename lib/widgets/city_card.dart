// =============================================================================
// widgets/city_card.dart
// Supports 3 view modes: list (default), grid, compact
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../models/recently_viewed_item.dart';
import '../providers/favorites_provider.dart';
import '../screens/item_detail_screen.dart';
import 'animated_heart_button.dart';

enum ViewMode { list, grid, compact }

class CityCard extends StatelessWidget {
  final CityModel city;
  final ViewMode  viewMode;

  const CityCard({
    super.key,
    required this.city,
    this.viewMode = ViewMode.list,
  });

  void _openDetail(BuildContext context, FavoritesProvider prov) {
    prov.recordView(RecentlyViewedItem(
      id: 'city_${city.id}', category: 'city',
      title: city.cityName, imageKey: city.cityImage,
      viewedAt: DateTime.now(),
    ));
    showItemDetailSheet(context, 'city_${city.id}',
        title: city.cityName, imageKey: city.cityImage);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<FavoritesProvider>();
    final note = context.watch<FavoritesProvider>().noteFor('city_${city.id}');

    return switch (viewMode) {
      ViewMode.list    => _buildList(context, prov, note),
      ViewMode.grid    => _buildGrid(context, prov, note),
      ViewMode.compact => _buildCompact(context, prov, note),
    };
  }

  // ── List (original tall card with image) ─────────────────────────────────
  Widget _buildList(BuildContext context, FavoritesProvider prov, String note) {
    return GestureDetector(
      onTap: () => _openDetail(context, prov),
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox.expand(
                child: Image.asset(
                  'assets/images/${city.cityImage}.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6, left: 14, right: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text(city.cityName,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                    if (note.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.sticky_note_2, color: Colors.amber, size: 16),
                    ],
                  ]),
                  AnimatedHeartButton(
                    isFavorite: city.isFavorite, size: 26,
                    onTap: () => context.read<FavoritesProvider>().toggleCityFavorite(city.id),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 8, right: 12,
              child: Text('Tap for details',
                  style: TextStyle(color: Colors.white60, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid (square card, image fills, name at bottom) ───────────────────────
  Widget _buildGrid(BuildContext context, FavoritesProvider prov, String note) {
    return GestureDetector(
      onTap: () => _openDetail(context, prov),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/${city.cityImage}.jpeg',
              fit: BoxFit.cover,
            ),
            // Bottom gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent,
                      Colors.black.withValues(alpha: 0.65)],
                  ),
                ),
              ),
            ),
            // Name + heart at bottom
            Positioned(
              bottom: 8, left: 10, right: 4,
              child: Row(
                children: [
                  Expanded(
                    child: Row(children: [
                      Flexible(
                        child: Text(city.cityName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.sticky_note_2, color: Colors.amber, size: 12),
                      ],
                    ]),
                  ),
                  AnimatedHeartButton(
                    isFavorite: city.isFavorite, size: 20,
                    onTap: () => context.read<FavoritesProvider>().toggleCityFavorite(city.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compact (thin row: small thumbnail + name + heart) ────────────────────
  Widget _buildCompact(BuildContext context, FavoritesProvider prov, String note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context, prov),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 52, height: 42,
                  child: Image.asset(
                    'assets/images/${city.cityImage}.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(children: [
                  Text(city.cityName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  if (note.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.sticky_note_2, color: Colors.amber, size: 13),
                  ],
                ]),
              ),
              AnimatedHeartButton(
                isFavorite: city.isFavorite, size: 22,
                onTap: () => context.read<FavoritesProvider>().toggleCityFavorite(city.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}