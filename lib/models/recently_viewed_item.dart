// =============================================================================
// models/recently_viewed_item.dart
// Enhancement #7 — Recently Viewed tracking
// =============================================================================

class RecentlyViewedItem {
  final String  id;          // e.g. 'city_1', 'hobby_3', 'book_2'
  final String  category;    // 'city' | 'hobby' | 'book'
  final String  title;       // display name
  final String? subtitle;    // author for books, null for others
  final String? icon;        // emoji for hobbies, null for others
  final String? imageKey;    // image filename for cities, null for others
  final DateTime viewedAt;

  const RecentlyViewedItem({
    required this.id,
    required this.category,
    required this.title,
    this.subtitle,
    this.icon,
    this.imageKey,
    required this.viewedAt,
  });

  // Serialize to/from SharedPreferences string
  // Format: "id|category|title|subtitle|icon|imageKey|viewedAt"
  String toStorageString() =>
      '$id|$category|$title|${subtitle ?? ''}|${icon ?? ''}|${imageKey ?? ''}|${viewedAt.millisecondsSinceEpoch}';

  factory RecentlyViewedItem.fromStorageString(String s) {
    final parts = s.split('|');
    return RecentlyViewedItem(
      id:        parts[0],
      category:  parts[1],
      title:     parts[2],
      subtitle:  parts[3].isEmpty ? null : parts[3],
      icon:      parts[4].isEmpty ? null : parts[4],
      imageKey:  parts[5].isEmpty ? null : parts[5],
      viewedAt:  DateTime.fromMillisecondsSinceEpoch(int.parse(parts[6])),
    );
  }
}
