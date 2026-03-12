import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────
class Expense {
  final String id;
  String title;
  double amount;
  String category;
  DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}

// ─────────────────────────────────────────────
// PROVIDER  (ChangeNotifier)
// ─────────────────────────────────────────────
class ExpensesProvider extends ChangeNotifier {
  // Simple list with seed data
  final List<Expense> _expenses = [
    Expense(
      id: '1',
      title: 'Grocery Shopping',
      amount: 52.75,
      category: 'Food',
      date: DateTime(2026, 3, 1),
    ),
    Expense(
      id: '2',
      title: 'Electric Bill',
      amount: 120.00,
      category: 'Utilities',
      date: DateTime(2026, 3, 5),
    ),
    Expense(
      id: '3',
      title: 'Netflix Subscription',
      amount: 15.99,
      category: 'Entertainment',
      date: DateTime(2026, 3, 7),
    ),
    Expense(
      id: '4',
      title: 'Bus Pass',
      amount: 30.00,
      category: 'Transport',
      date: DateTime(2026, 3, 10),
    ),
  ];

  // ── READ ──────────────────────────────────
  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalAmount =>
      _expenses.fold(0.0, (double sum, e) => sum + e.amount);

  Expense? getById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── WRITE (Add) ───────────────────────────
  void addExpense({
    required String title,
    required double amount,
    required String category,
    DateTime? date,
  }) {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
    );
    _expenses.add(newExpense);
    notifyListeners();
  }

  // ── EDIT (Update) ─────────────────────────
  void editExpense({
    required String id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
  }) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final expense = _expenses[index];
    if (title != null) expense.title = title;
    if (amount != null) expense.amount = amount;
    if (category != null) expense.category = category;
    if (date != null) expense.date = date;

    notifyListeners();
  }

  // ── DELETE ────────────────────────────────
  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// ANOTHER PROVIDER (ThemeProvider) – shows MultiProvider usage
// ─────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// MAIN  –  MultiProvider setup
// ─────────────────────────────────────────────
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: themeProvider.isDark
                  ? Brightness.dark
                  : Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const ExpenseHomePage(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────
class ExpenseHomePage extends StatelessWidget {
  const ExpenseHomePage({super.key});

  static const _categories = [
    'Food',
    'Utilities',
    'Transport',
    'Entertainment',
    'Health',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Theme toggle uses Consumer<ThemeProvider>
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: themeProvider.toggleTheme,
            ),
          ),
        ],
      ),

      // ── Summary card + list via Consumer<ExpensesProvider> ──
      body: Consumer<ExpensesProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Total card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${provider.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.expenses.length} transactions',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),

              // List header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.expenses.length} items',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Expense list
              Expanded(
                child: provider.expenses.isEmpty
                    ? const Center(child: Text('No expenses yet. Add one!'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = provider.expenses[index];
                          return _ExpenseTile(
                            expense: expense,
                            categories: _categories,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      // FAB → Add Expense
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, _categories),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  // ── Add dialog ──────────────────────────────
  void _showAddExpenseDialog(BuildContext context, List<String> categories) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(
                      () => selectedCategory = val ?? categories.first,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim());
                  if (title.isEmpty || amount == null) return;

                  // WRITE
                  context.read<ExpensesProvider>().addExpense(
                    title: title,
                    amount: amount,
                    category: selectedCategory,
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// EXPENSE TILE  (Edit + Delete)
// ─────────────────────────────────────────────
class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final List<String> categories;

  const _ExpenseTile({required this.expense, required this.categories});

  static const _categoryIcons = {
    'Food': Icons.fastfood,
    'Utilities': Icons.bolt,
    'Transport': Icons.directions_bus,
    'Entertainment': Icons.movie,
    'Health': Icons.health_and_safety,
    'Other': Icons.receipt_long,
  };

  static const _categoryColors = {
    'Food': Color(0xFFF59E0B),
    'Utilities': Color(0xFF3B82F6),
    'Transport': Color(0xFF10B981),
    'Entertainment': Color(0xFFEC4899),
    'Health': Color(0xFFEF4444),
    'Other': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[expense.category] ?? const Color(0xFF8B5CF6);
    final icon = _categoryIcons[expense.category] ?? Icons.receipt_long;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${expense.category} · ${expense.date.day}/${expense.date.month}/${expense.date.year}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(context);
                } else if (value == 'delete') {
                  // DELETE
                  context.read<ExpensesProvider>().deleteExpense(expense.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit dialog ─────────────────────────────
  void _showEditDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: expense.title);
    final amountCtrl = TextEditingController(
      text: expense.amount.toStringAsFixed(2),
    );
    String selectedCategory = expense.category;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(
                      () => selectedCategory = val ?? categories.first,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim());
                  if (title.isEmpty || amount == null) return;

                  // EDIT
                  context.read<ExpensesProvider>().editExpense(
                    id: expense.id,
                    title: title,
                    amount: amount,
                    category: selectedCategory,
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
