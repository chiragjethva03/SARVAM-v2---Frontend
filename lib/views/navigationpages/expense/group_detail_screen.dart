import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/Expense_api.dart';
import '../../home_page.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _loading = true;
  String? _err;
  Map<String, dynamic>? _group;
  String? _meMobile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _meMobile = prefs.getString('mobile');
      final token = prefs.getString('token');
      final api = ExpenseApi();
      final g = await api.getGroupDetails(
        groupId: widget.groupId,
        bearerToken: token,
      );
      if (!mounted) return;
      setState(() => _group = g);
    } catch (e) {
      if (!mounted) return;
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final api = ExpenseApi();

      await api.deleteGroup(groupId: groupId, bearerToken: token);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomePage(initialIndex: 2),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete group: $e")));
    }
  }

  void _showDeleteSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Delete Group",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to delete this group? "
                "This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.delete),
                label: const Text("Delete Group"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteGroup(widget.groupId);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_err != null) {
      body = Center(
        child: Text(_err!, style: const TextStyle(color: Colors.red)),
      );
    } else if (_group == null) {
      body = const Center(child: Text('No data'));
    } else {
      // normalize expenses as a List<Map<String, dynamic>>
      final expenses = (((_group!['expenses'] as List<dynamic>?) ?? [])
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList())
          .cast<Map<String, dynamic>>();

      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _YourBalanceSummary(meMobile: _meMobile, expenses: expenses),
            const SizedBox(height: 20),

            const Text(
              'Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            for (final e in expenses)
              _ExpenseTile(e, meMobile: _meMobile),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _group?['groupId'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteSheet();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete Group"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigate to Add-Expense screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expenses'),
      ),
    );
  }
}

// ✅ Expense Tile
class _ExpenseTile extends StatelessWidget {
  final Map<String, dynamic> e;
  final String? meMobile;
  const _ExpenseTile(this.e, {required this.meMobile});

  @override
  Widget build(BuildContext context) {
    final title = e['title']?.toString() ?? 'Expense';
    final amt = (e['amount'] is num) ? (e['amount'] as num).toDouble() : 0.0;

    final paidByMap = ((e['paidBy'] as Map?) ?? {}).cast<String, dynamic>();
    final paidByMobile = paidByMap['mobile']?.toString();
    final paidByName =
        paidByMap['fullName']?.toString() ?? paidByMobile ?? "Unknown";

    final splitRaw = (e['splitBetween'] as List?) ?? [];
    final splits = splitRaw.map((x) {
      final m = (x as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final share =
          (m['shareAmount'] is num) ? (m['shareAmount'] as num).toDouble() : 0.0;
      return {
        'mobile': m['mobile']?.toString(),
        'fullName': m['fullName']?.toString(),
        'shareAmount': share,
      };
    }).toList();

    // find my share safely
    double yourShare = 0.0;
    final myEntry = splits.firstWhere(
      (x) => x['mobile'] == meMobile,
      orElse: () => {'shareAmount': 0.0},
    );
    final ms = myEntry['shareAmount'];
    if (ms is num) yourShare = ms.toDouble();

    // compute others owe if I paid
    double othersOwe = 0.0;
    if (paidByMobile == meMobile) {
      for (final s in splits) {
        final mob = s['mobile'];
        if (mob != meMobile) {
          final sh = s['shareAmount'];
          if (sh is num) othersOwe += sh.toDouble();
        }
      }
    }

    String rightText = '';
    Color rightColor = Colors.black;

    if (paidByMobile == meMobile) {
      if (othersOwe > 0) {
        rightText = 'You lent\n₹${othersOwe.toStringAsFixed(0)}';
        rightColor = Colors.green;
      }
    } else {
      if (yourShare > 0) {
        rightText = 'You owe\n₹${yourShare.toStringAsFixed(0)}';
        rightColor = Colors.red;
      }
    }

    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: Colors.blue, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$paidByName paid ₹${amt.toStringAsFixed(0)}'),
        trailing: Text(
          rightText,
          style: TextStyle(color: rightColor, fontWeight: FontWeight.w600),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

// ✅ Balance summary (Splitwise style)
class _YourBalanceSummary extends StatelessWidget {
  final String? meMobile;
  final List<Map<String, dynamic>> expenses;
  const _YourBalanceSummary({required this.meMobile, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final summary = _compute(expenses, meMobile);
    final double lent = summary['lent'] ?? 0.0;
    final double borrowed = summary['borrowed'] ?? 0.0;

    if (lent == 0.0 && borrowed == 0.0) {
      return const Text(
        "All settled",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lent > 0)
          Text(
            "Total Lent: ₹${lent.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (borrowed > 0)
          Text(
            "Total Borrowed: ₹${borrowed.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  static Map<String, double> _compute(
      List<Map<String, dynamic>> expenses, String? me) {
    double totalLent = 0.0;
    double totalBorrowed = 0.0;

    for (final e in expenses) {
      final paidBy = (e['paidBy'] as Map?)?.cast<String, dynamic>();
      final paidByMobile = paidBy?['mobile']?.toString();
      if (paidByMobile == null) continue;

      final splitsRaw = (e['splitBetween'] as List?) ?? [];
      for (final sRaw in splitsRaw) {
        final s = (sRaw as Map?)?.cast<String, dynamic>() ?? {};
        final smobile = s['mobile']?.toString();
        final share = (s['shareAmount'] is num)
            ? (s['shareAmount'] as num).toDouble()
            : 0.0;
        if (smobile == null) continue;

        if (paidByMobile == me && smobile != me) {
          totalLent += share;
        } else if (smobile == me && paidByMobile != me) {
          totalBorrowed += share;
        }
      }
    }

    return {
      'lent': totalLent,
      'borrowed': totalBorrowed,
    };
  }
}
