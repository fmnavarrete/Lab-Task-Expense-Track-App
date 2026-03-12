import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class AppColors {
  // Base palette
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF13131A);
  static const surfaceElevated = Color(0xFF1C1C27);
  static const border = Color(0xFF2A2A3D);

  // Accent
  static const primary = Color(0xFF6C63FF);
  static const primaryGlow = Color(0x336C63FF);
  static const secondary = Color(0xFFFF6584);

  // Text
  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF8888AA);
  static const textMuted = Color(0xFF55556A);

  // Category palette
  static const food = Color(0xFFFFB347);
  static const utilities = Color(0xFF4FC3F7);
  static const transport = Color(0xFF81C784);
  static const entertainment = Color(0xFFFF80AB);
  static const health = Color(0xFFFF6E6E);
  static const other = Color(0xFFCE93D8);
}

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
// PROVIDER
// ─────────────────────────────────────────────
class ExpensesProvider extends ChangeNotifier {
  final List<Expense> _expenses = [
    Expense(
        id: '1',
        title: 'Grocery Shopping',
        amount: 1000,
        category: 'Food',
        date: DateTime(2026, 3, 1)),
    Expense(
        id: '2',
        title: 'Electric Bill',
        amount: 1500,
        category: 'Utilities',
        date: DateTime(2026, 3, 5)),
    Expense(
        id: '3',
        title: 'Netflix Subscription',
        amount: 299,
        category: 'Entertainment',
        date: DateTime(2026, 3, 7)),
    Expense(
        id: '4',
        title: 'Jeepney',
        amount: 30.00,
        category: 'Transport',
        date: DateTime(2026, 3, 10)),
  ];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  double get totalAmount => _expenses.fold(0.0, (s, e) => s + e.amount);
  Expense? getById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void addExpense(
      {required String title,
      required double amount,
      required String category,
      DateTime? date}) {
    _expenses.add(Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
    ));
    notifyListeners();
  }

  void editExpense(
      {required String id,
      String? title,
      double? amount,
      String? category,
      DateTime? date}) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final e = _expenses[index];
    if (title != null) e.title = title;
    if (amount != null) e.amount = amount;
    if (category != null) e.category = category;
    if (date != null) e.date = date;
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
        create: (_) => ExpensesProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folo · Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      home: const ExpenseHomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY CONFIG
// ─────────────────────────────────────────────
const _categories = [
  'Food',
  'Utilities',
  'Transport',
  'Entertainment',
  'Health',
  'Other'
];

const _categoryColors = {
  'Food': AppColors.food,
  'Utilities': AppColors.utilities,
  'Transport': AppColors.transport,
  'Entertainment': AppColors.entertainment,
  'Health': AppColors.health,
  'Other': AppColors.other,
};

const _categoryIcons = {
  'Food': Icons.local_dining_rounded,
  'Utilities': Icons.bolt_rounded,
  'Transport': Icons.directions_transit_filled_rounded,
  'Entertainment': Icons.movie_filter_rounded,
  'Health': Icons.favorite_rounded,
  'Other': Icons.receipt_long_rounded,
};

const _categoryEmoji = {
  'Food': '🍜',
  'Utilities': '⚡',
  'Transport': '🚌',
  'Entertainment': '🎬',
  'Health': '❤️',
  'Other': '📋',
};

Color _catColor(String cat) => _categoryColors[cat] ?? AppColors.other;
IconData _catIcon(String cat) =>
    _categoryIcons[cat] ?? Icons.receipt_long_rounded;

// ─────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────
class ExpenseHomePage extends StatelessWidget {
  const ExpenseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ExpensesProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(child: _Header(provider: provider)),

              // ── Mini Category Breakdown ──
              SliverToBoxAdapter(child: _CategoryBreakdown(provider: provider)),

              // ── Section label ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Recent',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGlow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${provider.expenses.length} items',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Expense list ──
              provider.expenses.isEmpty
                  ? SliverToBoxAdapter(child: _EmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _ExpenseTile(expense: provider.expenses[index]),
                        childCount: provider.expenses.length,
                      ),
                    ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),

      // ── FAB ──
      floatingActionButton: _AddFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final ExpensesProvider provider;
  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo mark
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Expense Tracker',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const Spacer(),
              // Notification dot
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Greeting
          const Text(
            'Good morning 👋',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'March 2026',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 24),

          // Big total card
          _TotalCard(provider: provider),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOTAL CARD
// ─────────────────────────────────────────────
class _TotalCard extends StatelessWidget {
  final ExpensesProvider provider;
  const _TotalCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● TOTAL SPENT',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '\$${provider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'across ${provider.expenses.length} transactions this month',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY BREAKDOWN CHIPS
// ─────────────────────────────────────────────
class _CategoryBreakdown extends StatelessWidget {
  final ExpensesProvider provider;
  const _CategoryBreakdown({required this.provider});

  @override
  Widget build(BuildContext context) {
    // Group by category
    final Map<String, double> totals = {};
    for (final e in provider.expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    if (totals.isEmpty) return const SizedBox.shrink();

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final entry = sorted[index];
            final color = _catColor(entry.key);
            final pct = provider.totalAmount > 0
                ? (entry.value / provider.totalAmount * 100).toStringAsFixed(0)
                : '0';

            return Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_catIcon(entry.key), color: color, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)} · $pct%',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EXPENSE TILE
// ─────────────────────────────────────────────
class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor(expense.category);
    final icon = _catIcon(expense.category);
    final emoji = _categoryEmoji[expense.category] ?? '📋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Dismissible(
        key: Key(expense.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.health.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.health.withOpacity(0.3)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline_rounded,
                  color: AppColors.health, size: 22),
              SizedBox(height: 2),
              Text('Delete',
                  style: TextStyle(
                      color: AppColors.health,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (_) => _ConfirmDeleteDialog(title: expense.title),
              ) ??
              false;
        },
        onDismissed: (_) =>
            context.read<ExpensesProvider>().deleteExpense(expense.id),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showEditDialog(context),
              splashColor: color.withOpacity(0.08),
              highlightColor: color.withOpacity(0.04),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title + meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  expense.category,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(expense.date),
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Amount + menu
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          iconColor: AppColors.textMuted,
                          color: AppColors.surfaceElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onSelected: (v) {
                            if (v == 'edit') _showEditDialog(context);
                            if (v == 'delete') {
                              context
                                  .read<ExpensesProvider>()
                                  .deleteExpense(expense.id);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: const [
                                  Icon(Icons.edit_rounded,
                                      size: 16, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Edit',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: const [
                                  Icon(Icons.delete_outline_rounded,
                                      size: 16, color: AppColors.health),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(
                                          color: AppColors.health,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExpenseForm(
        title: 'Edit Expense',
        initialTitle: expense.title,
        initialAmount: expense.amount.toStringAsFixed(2),
        initialCategory: expense.category,
        onSave: (t, a, c) {
          context.read<ExpensesProvider>().editExpense(
                id: expense.id,
                title: t,
                amount: a,
                category: c,
              );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD FAB
// ─────────────────────────────────────────────
class _AddFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF9C3AED)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Expense',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.3),
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _ExpenseForm(
                title: 'New Expense',
                onSave: (t, a, c) =>
                    context.read<ExpensesProvider>().addExpense(
                          title: t,
                          amount: a,
                          category: c,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EXPENSE FORM BOTTOM SHEET
// ─────────────────────────────────────────────
class _ExpenseForm extends StatefulWidget {
  final String title;
  final String? initialTitle;
  final String? initialAmount;
  final String? initialCategory;
  final void Function(String title, double amount, String category) onSave;

  const _ExpenseForm({
    required this.title,
    required this.onSave,
    this.initialTitle,
    this.initialAmount,
    this.initialCategory,
  });

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');
    _amountCtrl = TextEditingController(text: widget.initialAmount ?? '');
    _selectedCategory = widget.initialCategory ?? _categories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _titleCtrl.text.trim();
    final a = double.tryParse(_amountCtrl.text.trim());
    if (t.isEmpty || a == null) return;
    widget.onSave(t, a, _selectedCategory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 28, 24, 28 + bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 24),

          // Title field
          _Field(
            controller: _titleCtrl,
            label: 'What did you spend on?',
            hint: 'e.g. Lunch at cafe',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 14),

          // Amount field
          _Field(
            controller: _amountCtrl,
            label: 'Amount',
            hint: '0.00',
            icon: Icons.attach_money_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$ ',
          ),
          const SizedBox(height: 14),

          // Category picker
          const Text(
            'Category',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = cat == _selectedCategory;
              final color = _catColor(cat);
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        selected ? color.withOpacity(0.18) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          selected ? color.withOpacity(0.5) : AppColors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_categoryEmoji[cat] ?? '📋',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: TextStyle(
                          color: selected ? color : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF9C3AED)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submit,
                child: Text(
                  widget.initialTitle != null ? 'Save Changes' : 'Add Expense',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STYLED TEXT FIELD
// ─────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? prefix;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixText: prefix,
            prefixStyle:
                const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CONFIRM DELETE DIALOG
// ─────────────────────────────────────────────
class _ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  const _ConfirmDeleteDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text('Delete Expense?',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      content: Text(
        '"$title" will be permanently removed.',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.health.withOpacity(0.15),
            foregroundColor: AppColors.health,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: AppColors.health, width: 0.5),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('💸', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses yet',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the button below to add your first one.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
