// =============================================================================
// screens/item_detail_screen.dart
// Enhancement #6  — Notes on Favorites
// Enhancement #7  — Favorite toggle from detail sheet (recently viewed → fav)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/animated_heart_button.dart';

/// Call this from any widget to open the item detail sheet.
void showItemDetailSheet(
    BuildContext context,
    String itemKey, {
      required String title,
      String? subtitle,
      String? icon,
      String? imageKey,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<FavoritesProvider>(),
      child: _ItemDetailSheet(
        itemKey:  itemKey,
        title:    title,
        subtitle: subtitle,
        icon:     icon,
        imageKey: imageKey,
      ),
    ),
  );
}

class _ItemDetailSheet extends StatefulWidget {
  final String  itemKey;
  final String  title;
  final String? subtitle;
  final String? icon;
  final String? imageKey;

  const _ItemDetailSheet({
    required this.itemKey,
    required this.title,
    this.subtitle,
    this.icon,
    this.imageKey,
  });

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  late TextEditingController _noteCtrl;
  bool _editing = false;

  // ── Resolve isFavorite from the itemKey (e.g. 'city_1', 'hobby_3') ───────
  bool _isFavorite(FavoritesProvider prov) {
    final parts = widget.itemKey.split('_');
    if (parts.length < 2) return false;
    final category = parts[0];
    final id       = int.tryParse(parts[1]);
    if (id == null) return false;

    return switch (category) {
      'city'  => prov.cities.any((c) => c.id == id && c.isFavorite),
      'hobby' => prov.hobbies.any((h) => h.id == id && h.isFavorite),
      'book'  => prov.books.any((b) => b.id == id && b.isFavorite),
      _       => false,
    };
  }

  // ── Toggle favorite for any category ─────────────────────────────────────
  void _toggleFavorite(FavoritesProvider prov) {
    final parts = widget.itemKey.split('_');
    if (parts.length < 2) return;
    final category = parts[0];
    final id       = int.tryParse(parts[1]);
    if (id == null) return;

    HapticFeedback.lightImpact();

    switch (category) {
      case 'city':
        prov.toggleCityFavorite(id);
      case 'hobby':
        prov.toggleHobbyFavorite(id);
      case 'book':
        prov.toggleBookFavorite(id);
    }

    // Show feedback snackbar
    final nowFavorite = _isFavorite(prov);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowFavorite
            ? '❤️ Added to favorites'
            : '💔 Removed from favorites'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final existing =
    context.read<FavoritesProvider>().noteFor(widget.itemKey);
    _noteCtrl = TextEditingController(text: existing);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _saveNote() {
    context.read<FavoritesProvider>().setNote(widget.itemKey, _noteCtrl.text);
    setState(() => _editing = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _deleteNote() {
    _noteCtrl.clear();
    context.read<FavoritesProvider>().setNote(widget.itemKey, '');
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final prov    = context.watch<FavoritesProvider>();
    final note    = prov.noteFor(widget.itemKey);
    final hasNote = note.isNotEmpty;
    final isFav   = _isFavorite(prov);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────
          const SizedBox(height: 12),
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

          // ── Image banner (cities only) ─────────────────────────────────
          if (widget.imageKey != null)
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/${widget.imageKey}.jpeg',
                      fit: BoxFit.cover,
                    ),
                    // Favorite button overlay on image
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedHeartButton(
                          isFavorite: isFav,
                          size: 28,
                          activeColor: Colors.red,
                          onTap: () => _toggleFavorite(prov),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row with favorite button ─────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.icon != null) ...[
                      Text(widget.icon!,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          if (widget.subtitle != null)
                            Text(widget.subtitle!,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14)),
                        ],
                      ),
                    ),
                    // ── Favorite toggle (for non-city items — cities
                    //    already have the overlay on the image) ──────────
                    if (widget.imageKey == null)
                      AnimatedHeartButton(
                        isFavorite: isFav,
                        size: 28,
                        onTap: () => _toggleFavorite(prov),
                      ),
                  ],
                ),

                // Favorite status label
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 13,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isFav ? 'In your favorites' : 'Not in favorites yet',
                      style: TextStyle(
                          fontSize: 12,
                          color: isFav ? Colors.red : Colors.grey,
                          fontWeight: isFav
                              ? FontWeight.w600
                              : FontWeight.normal),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // ── Notes section ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, size: 18),
                        const SizedBox(width: 6),
                        const Text('My Note',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasNote && !_editing)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            onPressed: _deleteNote,
                            tooltip: 'Delete note',
                            visualDensity: VisualDensity.compact,
                          ),
                        IconButton(
                          icon: Icon(
                            _editing ? Icons.check : Icons.edit_outlined,
                            size: 18,
                          ),
                          onPressed: _editing
                              ? _saveNote
                              : () => setState(() => _editing = true),
                          tooltip: _editing ? 'Save note' : 'Edit note',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Note display / edit
                if (_editing)
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    maxLength: 200,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Write something about ${widget.title}…',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  )
                else if (hasNote)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(note,
                        style: const TextStyle(fontSize: 14, height: 1.4)),
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add,
                              color: Colors.grey.shade400, size: 18),
                          const SizedBox(width: 8),
                          Text('Add a personal note…',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                if (_editing) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final existing =
                            prov.noteFor(widget.itemKey);
                            _noteCtrl.text = existing;
                            setState(() => _editing = false);
                            FocusScope.of(context).unfocus();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveNote,
                          child: const Text('Save Note'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}