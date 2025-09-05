import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/Expense_api.dart';

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

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_err != null) {
      body = Center(child: Text(_err!, style: const TextStyle(color: Colors.red)));
    } else if (_group == null) {
      body = const Center(child: Text('No data'));
    } else {
      final members = (_group!['members'] as List<dynamic>? ?? []).cast<Map>();
      final expenses = (_group!['expenses'] as List<dynamic>? ?? []).cast<Map>();

      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _MembersStrip(members: members),
            const SizedBox(height: 12),
            _YourBalanceCard(meMobile: _meMobile, expenses: expenses),
            const SizedBox(height: 16),
            const Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final e in expenses) _ExpenseTile(e as Map<String, dynamic>, meMobile: _meMobile),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigate to Add-Expense screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }
}

class _MembersStrip extends StatelessWidget {
  final List<Map> members;
  const _MembersStrip({required this.members});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          children: [
            for (final m in members)
              Chip(
                avatar: CircleAvatar(child: Text(_initials((m['name'] ?? 'U') as String))),
                label: Text((m['name'] as String?) ?? (m['mobile'] as String? ?? '')),
              ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _ExpenseTile extends StatelessWidget {
  final Map<String, dynamic> e;
  final String? meMobile;
  const _ExpenseTile(this.e, {required this.meMobile});

  @override
  Widget build(BuildContext context) {
    final title = e['title']?.toString() ?? 'Expense';
    final amt = (e['amount'] as num?)?.toDouble() ?? 0;
    final paidBy = (e['paidBy'] as Map?)?['mobile']?.toString() ?? '—';
    final splits = ((e['splitBetween'] as List?) ?? [])
        .cast<Map>()
        .map((x) => {
              'mobile': x['mobile']?.toString(),
              'shareAmount': (x['shareAmount'] as num?)?.toDouble() ?? 0.0
            })
        .toList();

    final yourShare = splits
        .firstWhere(
          (x) => x['mobile'] == meMobile,
          orElse: () => {'shareAmount': 0.0},
        )['shareAmount'] as double;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text(title),
        subtitle: Text('Paid by $paidBy'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₹${amt.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (yourShare > 0)
              Text('You owe ₹${yourShare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
            if (paidBy == meMobile)
              Text('You paid', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _YourBalanceCard extends StatelessWidget {
  final String? meMobile;
  final List<Map> expenses;
  const _YourBalanceCard({required this.meMobile, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final totals = _compute(expenses, meMobile);
    final text = totals.net > 0
        ? 'You are owed ₹${totals.net.toStringAsFixed(0)}'
        : totals.net < 0
            ? 'You owe ₹${(-totals.net).toStringAsFixed(0)}'
            : 'All settled';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet),
        title: const Text('Your balance'),
        subtitle: Text(text),
      ),
    );
  }

  static _Totals _compute(List<Map> expenses, String? me) {
    double paidByMe = 0, myShare = 0;
    for (final e in expenses) {
      final amount = (e['amount'] as num?)?.toDouble() ?? 0;
      final payer = (e['paidBy'] as Map?)?['mobile']?.toString();
      if (payer == me) paidByMe += amount;
      final splits = ((e['splitBetween'] as List?) ?? []).cast<Map>();
      for (final s in splits) {
        if (s['mobile']?.toString() == me) {
          myShare += (s['shareAmount'] as num?)?.toDouble() ?? 0;
        }
      }
    }
    return _Totals(net: paidByMe - myShare);
  }
}

class _Totals {
  final double net;
  const _Totals({required this.net});
}
