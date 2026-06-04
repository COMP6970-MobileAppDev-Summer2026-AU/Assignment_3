// =============================================================================
// screens/settings_screen.dart
// Category 3 Enhancements:
//   #9  Color Theme Picker  — 5 accent colors, saved + applied app-wide
//   #10 Default Category    — remembers last Browse tab between launches
//   #11 Font Size Setting   — Small / Medium / Large, applied via textTheme
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FavoritesProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Settings',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold)),

            const SizedBox(height: 24),

            // ── APPEARANCE ─────────────────────────────────────────────
            _SectionLabel('Appearance'),
            const SizedBox(height: 8),

            // Dark Mode
            Card(
              child: SwitchListTile(
                secondary: Icon(prov.isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  prov.isDarkMode
                      ? 'Dark theme active'
                      : 'Light theme active',
                  style: const TextStyle(fontSize: 12),
                ),
                value: prov.isDarkMode,
                onChanged: prov.toggleDarkMode,
              ),
            ),

            const SizedBox(height: 12),

            // ── Enhancement #9: Color Theme Picker ─────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Accent Color',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const Spacer(),
                        Text(
                          prov.accentColor.label,
                          style: TextStyle(
                              color: prov.accentColor.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: AppAccentColor.values.map((c) {
                        final selected = prov.accentColor == c;
                        return GestureDetector(
                          onTap: () => prov.setAccentColor(c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width:  selected ? 48 : 40,
                            height: selected ? 48 : 40,
                            decoration: BoxDecoration(
                              color: c.color,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline,
                                  width: 3)
                                  : null,
                              boxShadow: selected
                                  ? [
                                BoxShadow(
                                  color: c.color
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                                  : null,
                            ),
                            child: selected
                                ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: AppAccentColor.values
                          .map((c) => SizedBox(
                        width: 48,
                        child: Text(
                          c.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              color: prov.accentColor == c
                                  ? c.color
                                  : Colors.grey,
                              fontWeight:
                              prov.accentColor == c
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Enhancement #11: Font Size ──────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_fields_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Font Size',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const Spacer(),
                        Text(prov.fontSize.label,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Preview text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Preview: The quick brown fox jumps',
                        style: TextStyle(
                            fontSize: 14 * prov.fontSize.scale),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Size buttons
                    Row(
                      children: AppFontSize.values.map((s) {
                        final selected = prov.fontSize == s;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 150),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: selected
                                      ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      : null,
                                  foregroundColor: selected
                                      ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      : null,
                                  side: selected
                                      ? BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      width: 2)
                                      : null,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () =>
                                    prov.setFontSize(s),
                                child: Text(s.label),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── PREFERENCES ────────────────────────────────────────────
            _SectionLabel('Preferences'),
            const SizedBox(height: 8),

            // ── Enhancement #10: Default Category ──────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Default Browse Tab',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The tab shown when you open Browse',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<DefaultCategory>(
                      segments: const [
                        ButtonSegment(
                            value: DefaultCategory.cities,
                            label: Text('Cities'),
                            icon: Icon(Icons.location_city,
                                size: 16)),
                        ButtonSegment(
                            value: DefaultCategory.hobbies,
                            label: Text('Hobbies'),
                            icon: Icon(Icons.interests, size: 16)),
                        ButtonSegment(
                            value: DefaultCategory.books,
                            label: Text('Books'),
                            icon: Icon(Icons.menu_book, size: 16)),
                      ],
                      selected: {prov.defaultCategory},
                      onSelectionChanged: (sel) =>
                          prov.setDefaultCategory(sel.first),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── ACTIVITY ───────────────────────────────────────────────
            _SectionLabel('Your Activity'),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded, size: 18),
                        const SizedBox(width: 8),
                        const Text('All-Time Favorites',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${prov.allTimeFavoriteCount} total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Items you have ever marked as favorite',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    // Three category bars
                    _ActivityBar(
                      label: '🌆 Cities',
                      count: prov.allTimeCities,
                      total: prov.allTimeFavoriteCount,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    _ActivityBar(
                      label: '🎯 Hobbies',
                      count: prov.allTimeHobbies,
                      total: prov.allTimeFavoriteCount,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    _ActivityBar(
                      label: '📚 Books',
                      count: prov.allTimeBooks,
                      total: prov.allTimeFavoriteCount,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── ABOUT ──────────────────────────────────────────────────
            _SectionLabel('About'),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  _AboutRow(Icons.info_outline, 'App', 'Favorites'),
                  const Divider(height: 1),
                  _AboutRow(Icons.school_outlined, 'Course', 'COMP 6910'),
                  const Divider(height: 1),
                  _AboutRow(Icons.assignment_outlined, 'Assignment',
                      'Assignment 3'),
                  const Divider(height: 1),
                  _AboutRow(
                      Icons.person_outline, 'Developer', 'Jahidul Arafat'),
                  const Divider(height: 1),
                  _AboutRow(Icons.tag, 'Version', '1.0.0'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.8),
  );
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _AboutRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 20),
    title: Text(label),
    trailing: Text(value,
        style: const TextStyle(color: Colors.grey)),
    dense: true,
  );
}

// ── Activity bar ──────────────────────────────────────────────────────────────

class _ActivityBar extends StatelessWidget {
  final String label;
  final int    count;
  final int    total;
  final Color  color;

  const _ActivityBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            Text(
              '$count favorited',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}