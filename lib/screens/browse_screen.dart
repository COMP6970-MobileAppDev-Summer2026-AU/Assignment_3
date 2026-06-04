// =============================================================================
// screens/browse_screen.dart
// Enhancement #1 — Sort & Filter (A→Z, Z→A, Favorites first)
// Enhancement #4 — Pull to refresh (resets search + scroll)
// Enhancement #5 — Item count badge on each segment
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/city_card.dart';
import '../widgets/hobby_row.dart';
import '../widgets/book_row.dart';
import '../models/city_model.dart';
import '../models/hobby_model.dart';
import '../models/book_model.dart';

enum ContentCategory { cities, hobbies, books }
enum SortOrder { none, aToZ, zToA, favoritesFirst }

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late ContentCategory _selected;
  SortOrder _sortOrder = SortOrder.none;
  ViewMode  _viewMode  = ViewMode.list;
  String    _search    = '';
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Enhancement #10: start on the user's preferred default category
    final prov = context.read<FavoritesProvider>();
    _selected = switch (prov.defaultCategory) {
      DefaultCategory.cities  => ContentCategory.cities,
      DefaultCategory.hobbies => ContentCategory.hobbies,
      DefaultCategory.books   => ContentCategory.books,
    };
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String get _hint => switch (_selected) {
    ContentCategory.cities  => 'Search cities…',
    ContentCategory.hobbies => 'Search hobbies…',
    ContentCategory.books   => 'Search books or authors…',
  };

  // ── Sort helpers ───────────────────────────────────────────────────────────
  List<CityModel> _sortedCities(List<CityModel> src) {
    final list = List<CityModel>.from(src);
    switch (_sortOrder) {
      case SortOrder.aToZ:
        list.sort((a, b) => a.cityName.compareTo(b.cityName));
      case SortOrder.zToA:
        list.sort((a, b) => b.cityName.compareTo(a.cityName));
      case SortOrder.favoritesFirst:
        list.sort((a, b) {
          if (a.isFavorite == b.isFavorite) return 0;
          return a.isFavorite ? -1 : 1;
        });
      case SortOrder.none:
        break;
    }
    return list;
  }

  List<HobbyModel> _sortedHobbies(List<HobbyModel> src) {
    final list = List<HobbyModel>.from(src);
    switch (_sortOrder) {
      case SortOrder.aToZ:
        list.sort((a, b) => a.hobbyName.compareTo(b.hobbyName));
      case SortOrder.zToA:
        list.sort((a, b) => b.hobbyName.compareTo(a.hobbyName));
      case SortOrder.favoritesFirst:
        list.sort((a, b) {
          if (a.isFavorite == b.isFavorite) return 0;
          return a.isFavorite ? -1 : 1;
        });
      case SortOrder.none:
        break;
    }
    return list;
  }

  List<BookModel> _sortedBooks(List<BookModel> src) {
    final list = List<BookModel>.from(src);
    switch (_sortOrder) {
      case SortOrder.aToZ:
        list.sort((a, b) => a.bookTitle.compareTo(b.bookTitle));
      case SortOrder.zToA:
        list.sort((a, b) => b.bookTitle.compareTo(a.bookTitle));
      case SortOrder.favoritesFirst:
        list.sort((a, b) {
          if (a.isFavorite == b.isFavorite) return 0;
          return a.isFavorite ? -1 : 1;
        });
      case SortOrder.none:
        break;
    }
    return list;
  }

  // ── Pull to refresh ────────────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _search    = '';
      _searchCtrl.clear();
      _sortOrder = SortOrder.none;
      _viewMode  = ViewMode.list;
    });
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  // ── Sort bottom sheet ──────────────────────────────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Sort by',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _SortOption(
              icon: Icons.sort_by_alpha,
              label: 'A → Z',
              selected: _sortOrder == SortOrder.aToZ,
              onTap: () {
                setState(() => _sortOrder = SortOrder.aToZ);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.sort_by_alpha,
              label: 'Z → A',
              selected: _sortOrder == SortOrder.zToA,
              onTap: () {
                setState(() => _sortOrder = SortOrder.zToA);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.favorite,
              label: 'Favorites first',
              selected: _sortOrder == SortOrder.favoritesFirst,
              onTap: () {
                setState(() => _sortOrder = SortOrder.favoritesFirst);
                Navigator.pop(context);
              },
            ),
            _SortOption(
              icon: Icons.replay,
              label: 'Default order',
              selected: _sortOrder == SortOrder.none,
              onTap: () {
                setState(() => _sortOrder = SortOrder.none);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FavoritesProvider>();
    final q    = _search.toLowerCase();

    // filtered + sorted lists
    final cities = _sortedCities(
      _search.isEmpty
          ? prov.cities
          : prov.cities.where((c) =>
          c.cityName.toLowerCase().contains(q)).toList(),
    );
    final hobbies = _sortedHobbies(
      _search.isEmpty
          ? prov.hobbies
          : prov.hobbies.where((h) =>
          h.hobbyName.toLowerCase().contains(q)).toList(),
    );
    final books = _sortedBooks(
      _search.isEmpty
          ? prov.books
          : prov.books.where((b) =>
      b.bookTitle.toLowerCase().contains(q) ||
          b.bookAuthor.toLowerCase().contains(q)).toList(),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Enhancement #5: Segmented button with item counts ──────
              SegmentedButton<ContentCategory>(
                segments: [
                  ButtonSegment(
                    value: ContentCategory.cities,
                    label: Text('Cities (${prov.cities.length})'),
                  ),
                  ButtonSegment(
                    value: ContentCategory.hobbies,
                    label: Text('Hobbies (${prov.hobbies.length})'),
                  ),
                  ButtonSegment(
                    value: ContentCategory.books,
                    label: Text('Books (${prov.books.length})'),
                  ),
                ],
                selected: {_selected},
                onSelectionChanged: (sel) {
                  final next = sel.first;
                  setState(() {
                    _selected = next;
                    _search   = '';
                    _searchCtrl.clear();
                  });
                  // Enhancement #10: persist last-used category
                  context.read<FavoritesProvider>().setDefaultCategory(
                    switch (next) {
                      ContentCategory.cities  => DefaultCategory.cities,
                      ContentCategory.hobbies => DefaultCategory.hobbies,
                      ContentCategory.books   => DefaultCategory.books,
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              // ── Search + Sort row ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: _hint,
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _search = '';
                            _searchCtrl.clear();
                          }),
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort button
                  IconButton.filledTonal(
                    onPressed: _showSortSheet,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.sort),
                        if (_sortOrder != SortOrder.none)
                          Positioned(
                            top: -4, right: -4,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Sort',
                  ),
                  const SizedBox(width: 4),
                  // View mode toggle
                  IconButton.filledTonal(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _viewMode = switch (_viewMode) {
                          ViewMode.list    => ViewMode.grid,
                          ViewMode.grid    => ViewMode.compact,
                          ViewMode.compact => ViewMode.list,
                        };
                      });
                    },
                    icon: Icon(switch (_viewMode) {
                      ViewMode.list    => Icons.grid_view_rounded,
                      ViewMode.grid    => Icons.view_agenda_outlined,
                      ViewMode.compact => Icons.view_list_rounded,
                    }),
                    tooltip: switch (_viewMode) {
                      ViewMode.list    => 'Switch to Grid',
                      ViewMode.grid    => 'Switch to Compact',
                      ViewMode.compact => 'Switch to List',
                    },
                  ),
                ],
              ),

              // Active sort chip
              if (_sortOrder != SortOrder.none) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      switch (_sortOrder) {
                        SortOrder.aToZ          => 'A → Z',
                        SortOrder.zToA          => 'Z → A',
                        SortOrder.favoritesFirst => 'Favorites first',
                        SortOrder.none          => '',
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    avatar: const Icon(Icons.sort, size: 14),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () =>
                        setState(() => _sortOrder = SortOrder.none),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // ── Enhancement #4: Pull to refresh ───────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: switch (_selected) {
                    ContentCategory.cities => cities.isEmpty
                        ? _empty('No cities match "$_search"')
                        : _viewMode == ViewMode.grid
                        ? GridView.builder(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: cities.length,
                      itemBuilder: (_, i) => CityCard(
                          city: cities[i], viewMode: _viewMode),
                    )
                        : ListView.builder(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: cities.length,
                      itemBuilder: (_, i) => CityCard(
                          city: cities[i], viewMode: _viewMode),
                    ),
                    ContentCategory.hobbies => hobbies.isEmpty
                        ? _empty('No hobbies match "$_search"')
                        : _viewMode == ViewMode.grid
                        ? GridView.builder(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: hobbies.length,
                      itemBuilder: (_, i) => HobbyRow(
                          hobby: hobbies[i], viewMode: _viewMode),
                    )
                        : ListView.builder(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: hobbies.length,
                      itemBuilder: (_, i) => HobbyRow(
                          hobby: hobbies[i], viewMode: _viewMode),
                    ),
                    ContentCategory.books => books.isEmpty
                        ? _empty('No books match "$_search"')
                        : _viewMode == ViewMode.grid
                        ? GridView.builder(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: books.length,
                      itemBuilder: (_, i) => BookRow(
                          book: books[i], viewMode: _viewMode),
                    )
                        : ListView.builder(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: books.length,
                      itemBuilder: (_, i) => BookRow(
                          book: books[i], viewMode: _viewMode),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(String msg) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(msg, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              const Text(
                'Pull down to reset',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ── Sort option tile ──────────────────────────────────────────────────────────

class _SortOption extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: selected
              ? Theme.of(context).colorScheme.primary
              : null),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check,
          color: Theme.of(context).colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: selected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      onTap: onTap,
    );
  }
}

// NOTE: The browse_screen already imports provider —
// recordView calls are added via GestureDetector wrapping in city_card,
// hobby_row, book_row. See updated widgets below.