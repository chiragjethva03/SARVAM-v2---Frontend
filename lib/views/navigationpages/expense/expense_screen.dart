import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/expense_api.dart';
import 'join_create_group_sheet.dart';
import '../../../main.dart';

// import the same instance from where you defined it

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with RouteAware {
  bool _loading = true;
  List<Map<String, dynamic>> _groups = [];
  String? _err;

  @override
  void initState() {
    super.initState();
    debugPrintPrefs();
    _load(); // initial load
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe after context is available
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when coming back to this page (e.g., from Create Group)
  @override
  void didPopNext() {
    _load(); // refresh every time screen becomes visible again
  }

  // Optional: also refresh when first pushed
  @override
  void didPush() {
    // _load(); // already done in initState; keep if you prefer double safety
  }

  static Future<void> debugPrintPrefs() async {
    final p = await SharedPreferences.getInstance();
    print('====== SharedPreferences ======');
    for (final k in p.getKeys()) {
      print('$k: ${p.get(k)}');
    }
    print('================================');
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final api = ExpenseApi();
      _groups = await api.getMyGroups(
        userId: prefs.getString('userId'),
        mobile: prefs.getString('mobile'),
        bearerToken: prefs.getString('token'),
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
          // implement join flow
        },
        onCreateNew: () async {
          Navigator.pop(context);
          // Navigate to create page. After it pops, didPopNext() will fire and refresh.
          await Navigator.pushNamed(context, '/expense/create');
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
      body = Center(
        child: Text(_err!, style: const TextStyle(color: Colors.red)),
      );
    } else if (_groups.isEmpty) {
      body = Column(
        children: [
          SizedBox(height: size.height * 0.05),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No expenses added yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Start tracking your trip costs now.",
                    style: TextStyle(fontSize: 14),
                  ),
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
          padding: const EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: 80,
          ),
          itemCount: _groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final g = _groups[i];
            return InkWell(
              onTap: () {
                // Navigator.pushNamed(context, '/expense/group', arguments: g);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xE6EAF3FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        g['groupName'] ?? 'Group',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
              child: Text(
                "Manage Group\nExpenses Effortlessly",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: body),
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
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
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
