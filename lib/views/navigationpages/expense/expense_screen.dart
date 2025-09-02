import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/expense_api.dart';
import 'join_create_group_sheet.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  bool _loading = true;
  bool _loadedOnce = false;
  List<Map<String, dynamic>> _groups = [];
  String? _err;

  @override
  bool get wantKeepAlive => true; // <- keeps state when switching tabs

  @override
  void initState() {
    super.initState();
    dumpSharedPrefs();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    if (_loadedOnce) return;
    await _load();
    _loadedOnce = true;
  }

Future<void> dumpSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  print("---- SharedPreferences Dump ----");
  for (final key in prefs.getKeys()) {
    print("$key = ${prefs.get(key)}");
  }
  print("---- End Dump ----");
}

  Future<void> _load() async {
    setState(() { _loading = true; _err = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final api = ExpenseApi();
      _groups = await api.getMyGroups(
        userId: prefs.getString('userId'),
        mobile: prefs.getString('mobile'),
        bearerToken: prefs.getString('authToken'),
      );
    } catch (e) {
      _err = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => JoinCreateGroupSheet(
        onJoinGroup: () {
          Navigator.pop(context);
          // TODO: implement join flow
        },
        onCreateNew: () async {
          Navigator.pop(context);
          final created = await Navigator.pushNamed(context, '/expense/create');
          if (created == true) _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_err != null) {
      body = Center(child: Text(_err!, style: const TextStyle(color: Colors.red)));
    } else if (_groups.isEmpty) {
      body = Column(
        children: [
          SizedBox(height: size.height * 0.05),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No expenses added yet!",
                      style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  const SizedBox(height: 4),
                  Text("Start tracking your trip costs now.",
                      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 80),
          itemCount: _groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final g = _groups[i];
            return InkWell(
              onTap: () {
                // TODO: navigate to group detail: Navigator.pushNamed(context, '/expense/group', arguments: g);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xE6EAF3FA), // light blue like your design
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(g['groupName'] ?? 'Group',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.chevron_right, size: 28),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Manage Group\nExpenses Effortlessly",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: body),
            // Add Group button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _openBottomSheet,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0x1C2196F3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Icon(Icons.add, size: 30, color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Add Group", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
