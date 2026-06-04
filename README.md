# 🌟 Favorite Explorer
### Assignment 3 — State & Architecture
### COMP 6970 — Mobile Applications Development

---

## 👨‍💻 Developer Information

| Field | Details                                                            |
|---|--------------------------------------------------------------------|
| **Name** | Jahidul Arafat                                                     |
| **Username** | JAJI                                                               |
| **Title** | PhD Student, Department of Computer Science & Software Engineering |
| **Fellowship** | Presidential & Woltosz Graduate Research Fellow                    |
| **Industry** | Former L3 Senior Solution Architect (MLOps), Oracle (Singapore)    |
| **Course** | COMP 6970 — Mobile Applications Development                        |
| **Module** | M3 — State & Architecture                                          |
| **Assignment** | Assignment 3                                                       |
| **Track** | Flutter / Dart                                                     |
| **Version** | 1.0.0+1                                                            |

---

## 📱 App Overview

**Favorite Explorer** is a production-quality Flutter app for discovering and saving favorite cities, hobbies, and books. Built around Module 3 concepts — shared state, local persistence, and clean architecture — it goes well beyond the base requirements with 14 additional enhancements across 4 categories.

### Key Highlights
- 3 content categories: **9 Cities · 12 Hobbies · 12 Books**
- **3 view modes**: List, Grid, Compact — switchable per category
- **Notes** on any item — add, edit, delete personal notes
- **Recently Viewed** tracking with quick favorite toggle
- **14 beyond-requirements enhancements** across UX, Data, Settings, and Polish

---

## 🗂 Project Structure

```
Favorites-flutter/
├── lib/
│   ├── main.dart                          # App entry → HomeScreen
│   ├── data/
│   │   └── sample_data.dart               # 9 cities, 12 hobbies, 12 books
│   ├── models/
│   │   ├── city_model.dart
│   │   ├── hobby_model.dart
│   │   ├── book_model.dart
│   │   └── recently_viewed_item.dart      # Enhancement #7
│   ├── providers/
│   │   └── favorites_provider.dart        # All state + SharedPreferences
│   ├── services/
│   │   └── share_service.dart             # Enhancement #13 — iOS-safe share
│   ├── screens/
│   │   ├── home_screen.dart               # App landing page (every launch)
│   │   ├── onboarding_screen.dart         # Enhancement #12 — first launch
│   │   ├── content_view.dart              # Bottom nav shell + badge
│   │   ├── browse_screen.dart             # Search + Sort + 3 view modes
│   │   ├── favorites_screen.dart          # All favorites + recently viewed
│   │   ├── settings_screen.dart           # Theme + font + category + activity
│   │   └── item_detail_screen.dart        # Notes sheet + favorite toggle
│   └── widgets/
│       ├── animated_heart_button.dart     # Enhancement #3 — bounce + haptic
│       ├── city_card.dart                 # List / Grid / Compact views
│       ├── hobby_row.dart                 # List / Grid / Compact views
│       └── book_row.dart                  # List / Grid / Compact views
├── assets/
│   └── images/
│       ├── app_logo.png                   # App logo
│       └── [amsterdam/capetown/...].jpeg  # 9 city images
└── pubspec.yaml
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Xcode (iOS) or Android Studio (Android)
- A connected device or simulator

### Clone & Run

```bash
# 1. Clone the repository
git clone https://github.com/COMP6970-MobileAppDev-Summer2026-AU/Assignment_3.git
cd Favorites-flutter

# 2. Install dependencies
flutter pub get

# 3. Run analysis
flutter analyze

# 4. Run the app
flutter run

# Target a specific platform
flutter run -d ios       # iPhone Simulator
flutter run -d android   # Android Emulator
```

### Dependencies

```yaml
dependencies:
  provider: ^6.1.2           # Shared state (ChangeNotifier)
  shared_preferences: ^2.2.3 # Local persistence
  share_plus: ^10.0.0        # OS share sheet (Enhancement #13)
```

---

## 📋 Assignment Requirements Coverage

### ✅ Required Feature 1 — Hobbies Category
The Hobbies section displays all 12 hobby items, each showing its name and emoji icon. Users can tap the heart to favorite or unfavorite any hobby. Changes sync instantly across the app via `FavoritesProvider`.

```dart
// HobbyRow widget — list, grid, and compact layouts
// Provider call: context.read<FavoritesProvider>().toggleHobbyFavorite(id)
```

### ✅ Required Feature 2 — Books Category
A fully functional Books category was added using the existing hardcoded book data. Each book shows its title and author. Users can favorite and unfavorite books just like cities and hobbies.

```dart
// BookRow widget — list, grid, and compact layouts
// 12 books from BookModel (title + author)
```

### ✅ Required Feature 3 — Favorites Screen (All Categories)
The Favorites screen displays all favorited items grouped into three sections — Cities, Hobbies, and Books — each with a count badge. The screen rebuilds instantly when any item is toggled anywhere in the app.

```dart
// context.watch<FavoritesProvider>() — reactive rebuilds
// Sections only shown when non-empty
```

### ✅ Required Feature 4 — Remove from Favorites Screen
Users can remove items directly from the Favorites screen in two ways: tapping the red heart button on any tile, or swiping left (Dismissible). Both update the screen immediately.

### ✅ Required Feature 5 — Search Filter
The search bar on the Browse screen filters the currently selected category in real time. Cities filter by name, hobbies by name, books by both title and author. A clear button appears when text is entered.

```dart
prov.books.where((b) =>
    b.bookTitle.toLowerCase().contains(q) ||
    b.bookAuthor.toLowerCase().contains(q))
```

### ✅ Required Feature 6 — Settings & Dark Mode Persistence
The Settings screen includes a dark mode toggle. The preference is saved to `SharedPreferences` immediately on change and restored on every app launch.

```dart
// Key: 'isDarkMode' (bool)
await prefs.setBool('isDarkMode', isDarkMode);
```

### ✅ Required Feature 7 — Clear Favorites with Confirmation
A "Clear" button on the Favorites screen opens an `AlertDialog` confirmation before removing all saved favorites. A SnackBar confirms the action.

### ✅ Required Feature 8 — Synchronized Favorites
All changes are managed through a single `FavoritesProvider extends ChangeNotifier`. Every screen and widget observes the same state — toggling a favorite anywhere immediately reflects everywhere.

---

## 🚀 Beyond-Requirements Enhancements (14 Total)

### Category 1 — User Experience

#### #1 Sort & Filter
A sort button (next to the search bar) opens a bottom sheet with 4 options: A→Z, Z→A, Favorites First, and Default Order. An active sort is shown as a removable chip below the search bar, and a red dot on the sort button indicates an active sort.

#### #2 Swipe to Unfavorite
On the Favorites screen, swipe any item left to reveal a red "Remove" background and dismiss it. Uses Flutter's `Dismissible` widget with `endToStart` direction.

#### #3 Animated Heart Button
Every heart button uses a custom `AnimatedHeartButton` widget: tapping triggers a `ScaleTransition` bounce to 1.35× with `elasticOut` curve, the icon swaps with `AnimatedSwitcher`, and `HapticFeedback.lightImpact()` fires on every tap.

#### #4 Pull to Refresh
Pull down on any Browse list to reset the search text, clear the active sort, reset the view mode to List, and scroll back to top.

#### #5 Item Count Badge
The segmented category selector shows the item count for each category: `Cities (9)`, `Hobbies (12)`, `Books (12)`.

---

### Category 2 — Data & State

#### #6 Notes on Favorites
Tapping any item (from Browse, Favorites, or Recently Viewed) opens a detail bottom sheet. The sheet lets users write, edit, save, or delete a personal note (up to 200 characters). Notes are stored as JSON in `SharedPreferences` and displayed as a preview on Favorites tiles. An amber 📝 indicator appears on any item that has a note.

#### #7 Recently Viewed
The last 5 browsed items across all categories are tracked and shown as a horizontal scroll row of chips at the top of the Favorites screen. Tapping any chip reopens the detail sheet — where the user can immediately favorite the item without going back to Browse.

#### #8 Favorite Count History (in Settings)
The Settings screen shows an "Your Activity" card with an all-time favorites counter and `LinearProgressIndicator` bars showing the proportion of cities, hobbies, and books ever favorited. This count never decrements, so clearing favorites doesn't reset it.

---

### Category 3 — Settings & Personalization

#### #9 Color Theme Picker
5 accent color options (Purple, Teal, Orange, Rose, Indigo) shown as animated circles in Settings. Selecting a color applies it instantly app-wide via `ColorScheme.fromSeed()`. The selection is persisted to `SharedPreferences`.

#### #10 Default Browse Tab
A segmented button in Settings lets users choose which tab (Cities, Hobbies, or Books) opens by default when they go to Browse. The preference is also updated automatically whenever the user switches tabs.

#### #11 Font Size Setting
Small (0.85×), Medium (1.0×), and Large (1.2×) options in Settings. A live preview text updates as the user selects a size. The scale is applied app-wide via `MaterialApp textTheme`. Persisted to `SharedPreferences`.

---

### Category 4 — Polish

#### #12 Onboarding Screen
A 4-page full-screen onboarding tour shown only on the first launch. Each page has a colored gradient background, emoji illustration, title, and body text. Navigation uses dot indicators and Skip / Next / Get Started buttons. On completion, `onboardingDone=true` is saved to `SharedPreferences` so it never shows again.

#### #13 Share Favorites
A share icon button in the Favorites screen header opens the OS share sheet with a formatted text list of all favorited items, including any personal notes. Uses `share_plus` with `sharePositionOrigin` for correct iOS popover positioning.

#### #14 Haptic Feedback
Subtle haptic feedback is wired throughout the app:
- `lightImpact` — heart tap, pull to refresh, sort selection, view mode toggle
- `mediumImpact` — swipe to dismiss, Clear All tap

---

## 🔄 App Launch Flow

```
Every launch:
    HomeScreen
        │
        ├── First launch  →  OnboardingScreen (4 pages)  →  ContentView
        └── Returning     →  ContentView directly

ContentView (bottom nav)
    ├── Browse    — Search + Sort + 3 View Modes (List / Grid / Compact)
    ├── Favorites — Stats · Recently Viewed · Cities · Hobbies · Books
    └── Settings  — Dark Mode · Accent Color · Font Size · Default Tab · Activity
```

---

## 🎨 View Modes

All three content categories support three view modes, toggled via the view button (next to Sort):

| Mode | Cities | Hobbies | Books |
|---|---|---|---|
| **List** | Tall 150px image card with gradient overlay | ListTile with emoji icon | ListTile with book icon |
| **Grid** | 2-column square with name at bottom | 3-column emoji cards | 2-column book cover cards |
| **Compact** | Thin row with small thumbnail | Single row with emoji | Single row with small icon |

---

## 💾 Persistence — SharedPreferences Keys

| Key | Type | Used For |
|---|---|---|
| `isDarkMode` | `bool` | Dark mode toggle |
| `accentColor` | `int` (index) | Selected accent color |
| `fontSize` | `int` (index) | Font size preference |
| `defaultCategory` | `int` (index) | Default Browse tab |
| `favoriteCities` | `List<String>` | Favorited city IDs |
| `favoriteHobbies` | `List<String>` | Favorited hobby IDs |
| `favoriteBooks` | `List<String>` | Favorited book IDs |
| `notes` | `String` (JSON) | All personal notes |
| `recentlyViewed` | `List<String>` | Last 5 viewed items |
| `allTimeFavoriteCount` | `int` | Lifetime favorite count |
| `allTimeCities` | `int` | Lifetime city count |
| `allTimeHobbies` | `int` | Lifetime hobby count |
| `allTimeBooks` | `int` | Lifetime book count |
| `onboardingDone` | `bool` | Onboarding seen flag |

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────┐
│              PRESENTATION LAYER                   │
│         (screens + widgets)                       │
│                                                   │
│  HomeScreen  OnboardingScreen  ContentView        │
│  BrowseScreen  FavoritesScreen  SettingsScreen    │
│  ItemDetailScreen                                 │
│                                                   │
│  Widgets: CityCard · HobbyRow · BookRow           │
│           AnimatedHeartButton                     │
└─────────────────┬────────────────────────────────┘
                  │  context.watch / context.read
                  ▼
┌──────────────────────────────────────────────────┐
│               SERVICE LAYER                       │
│                                                   │
│  FavoritesProvider (ChangeNotifier)               │
│  ShareService                                     │
└─────────────────┬────────────────────────────────┘
                  │  reads / writes
                  ▼
┌──────────────────────────────────────────────────┐
│               DATA LAYER                          │
│                                                   │
│  Models: CityModel · HobbyModel · BookModel       │
│          RecentlyViewedItem                       │
│  Data:   sample_data.dart (33 items)              │
│  Storage: SharedPreferences (14 keys)             │
└──────────────────────────────────────────────────┘
```

---

## 📦 Content Catalog

### 🌆 Cities (9)
Cape Town · Copenhagen · Lisbon · Reykjavik · Warsaw · London · Monaco · Amsterdam · Los Angeles

### 🎯 Hobbies (12)
Painting 🎨 · Photography 📷 · Guitar 🎸 · Yoga 🧘 · Gardening 🪴 · Cooking 🍳 · Hiking 🥾 · Writing ✍️ · Dancing 💃 · Knitting 🧶 · Gaming 🎮 · Calligraphy ✒️

### 📚 Books (12)
To Kill a Mockingbird · 1984 · Pride and Prejudice · The Great Gatsby · The Catcher in the Rye · The Hobbit · Fahrenheit 451 · Jane Eyre · The Alchemist · The Book Thief · Moby-Dick · Crime and Punishment

---

*Built with Flutter & ❤️ — COMP 6910 Assignment 3 — State & Architecture — Summer 2026*