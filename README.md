# 💸 Expense Tracker — Flutter App

A beautiful, dark-themed personal expense tracking app built with Flutter and Provider. Features a sleek fintech-inspired UI with category breakdowns, swipe-to-delete, and a smooth bottom sheet form.

---

## ✨ Features

- **Dashboard Overview** — Total spending summary with transaction count for the current month
- **Category Breakdown** — Horizontal scroll chips showing per-category totals and percentages
- **Add / Edit / Delete Expenses** — Full CRUD via an elegant bottom sheet form
- **Swipe to Delete** — Dismissible tiles with a confirmation dialog
- **Category Picker** — Visual toggle chips with emoji icons instead of a plain dropdown
- **Dark Luxury Theme** — Deep navy-black base with glowing indigo/purple accents

---

## 🗂️ Project Structure
```
lib/
└── main.dart          # All-in-one: models, provider, UI widgets
```

| Section | Description |
|---|---|
| `AppColors` | Centralized design tokens (palette, category colors) |
| `Expense` | Data model with id, title, amount, category, date |
| `ExpensesProvider` | ChangeNotifier managing CRUD state |
| `ExpenseHomePage` | Root scaffold with CustomScrollView |
| `_Header` | App logo, greeting, month label |
| `_TotalCard` | Gradient summary card |
| `_CategoryBreakdown` | Horizontal category chips |
| `_ExpenseTile` | Dismissible list tile with popup menu |
| `_AddFAB` | Full-width gradient floating action button |
| `_ExpenseForm` | Reusable bottom sheet for add/edit |
| `_Field` | Styled text input widget |
| `_ConfirmDeleteDialog` | Delete confirmation alert |
| `_EmptyState` | Shown when expense list is empty |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`

### Installation

\`\`\`bash
# 1. Clone the repository
git clone https://github.com/your-username/expense-tracker.git
cd expense-tracker

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
\`\`\`

### Dependencies

Add the following to your `pubspec.yaml`:

\`\`\`yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
\`\`\`

---

## 🎨 Design System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| `background` | `#0A0A0F` | App background |
| `surface` | `#13131A` | Cards, tiles |
| `surfaceElevated` | `#1C1C27` | Bottom sheets, dialogs |
| `border` | `#2A2A3D` | Borders and dividers |
| `primary` | `#6C63FF` | Buttons, accents, highlights |
| `secondary` | `#FF6584` | Logo gradient end |
| `textPrimary` | `#F0F0FF` | Headlines, titles |
| `textSecondary` | `#8888AA` | Subtitles, labels |
| `textMuted` | `#55556A` | Dates, hints |

### Category Colors

| Category | Color | Emoji |
|---|---|---|
| Food | `#FFB347` 🟠 | 🍜 |
| Utilities | `#4FC3F7` 🔵 | ⚡ |
| Transport | `#81C784` 🟢 | 🚌 |
| Entertainment | `#FF80AB` 🩷 | 🎬 |
| Health | `#FF6E6E` 🔴 | ❤️ |
| Other | `#CE93D8` 🟣 | 📋 |

---

## 🧠 State Management

Uses **Provider** (`ChangeNotifier`) with a single `ExpensesProvider` injected at the root via `ChangeNotifierProvider`.

\`\`\`dart
// Reading state
context.watch<ExpensesProvider>().expenses

// Writing state
context.read<ExpensesProvider>().addExpense(...)
context.read<ExpensesProvider>().editExpense(...)
context.read<ExpensesProvider>().deleteExpense(id)
\`\`\`

---

## 📱 Screenshots

> _Run the app and take screenshots to add here._

| Home | Add Expense | Category Breakdown |
|---|---|---|
| _(home screenshot)_ | _(form screenshot)_ | _(chips screenshot)_ |

---

## 📄 License

MIT License — feel free to use, modify, and distribute.