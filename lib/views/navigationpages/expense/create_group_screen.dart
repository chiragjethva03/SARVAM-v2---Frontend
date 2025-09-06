import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splitamountscreen.dart';
import '../../../services/Expense_api.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // 👈 new title field
  final TextEditingController _amountController = TextEditingController();

  static const Color _primaryBlue = Color(0xFF2196F3);
  static const Color _dividerGray = Color(0xFFBDBDBD);

  final List<Map<String, dynamic>> _categories = const [
    {"name": "Travel", "icon": Icons.flight_takeoff},
    {"name": "Food", "icon": Icons.restaurant},
    {"name": "Entertainment", "icon": Icons.movie},
    {"name": "Shopping", "icon": Icons.shopping_bag},
    {"name": "Bills", "icon": Icons.receipt_long},
    {"name": "Other", "icon": Icons.category},
  ];
  String _selectedCategory = "Travel";

  List<Map<String, dynamic>> _participants = [];
  String? _selectedPayerName;
  Map<String, double>? _savedSplits; // name -> amount
  String _splitMethod = "equal";

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId');
    final currentMobile = _normalizeMobile(prefs.getString('mobile'));
    final currentUserName = prefs.getString('fullName') ?? 'You';

    setState(() {
      _participants = [
        {
          "name": currentUserName,
          "isCurrent": true,
          "userId": currentUserId,
          "mobile": currentMobile,
        },
      ];
      _selectedPayerName = currentUserName;
    });
  }

  String? _normalizeMobile(String? s) {
    if (s == null) return null;
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 12) return digits.substring(digits.length - 12);
    return digits;
  }

  void _addParticipant(String name, {String? mobile}) {
    if (name.trim().isEmpty) return;
    setState(() {
      _participants.add({
        "name": name.trim(),
        "isCurrent": false,
        "mobile": _normalizeMobile(mobile),
      });
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      final removedName = _participants[index]["name"] as String;
      _participants.removeAt(index);
      if (_selectedPayerName == removedName && _participants.isNotEmpty) {
        _selectedPayerName = _participants.first["name"] as String;
      }
      _savedSplits = null;
      _splitMethod = "equal";
    });
  }

  Future<void> _pickContact() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contacts permission denied")),
      );
      return;
    }

    final picked = await FlutterContacts.openExternalPick();
    if (picked == null) return;

    final full = await FlutterContacts.getContact(picked.id);
    final String name = full?.displayName ?? picked.displayName;
    final String? mobile =
        (full?.phones.isNotEmpty ?? false) ? full?.phones.first.number : null;

    _addParticipant(name, mobile: mobile);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text("Important"),
          ],
        ),
        content: Text(
          "$name added.\n\nAsk them to install the app and set profile mobile to auto-link.",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  String _mapCategory(String ui) {
    switch (ui.toLowerCase()) {
      case 'travel':
        return 'travel';
      case 'food':
        return 'food';
      case 'entertainment':
        return 'entertainment';
      case 'shopping':
        return 'shopping';
      case 'bills':
        return 'others';
      default:
        return 'others';
    }
  }

  Future<void> _openSplitScreen() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter amount first")),
      );
      return;
    }

    final res = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SplitAmountScreen(
          participants: _participants,
          totalAmount: amount,
          currentUser:
              _participants.firstWhere((e) => e["isCurrent"] == true)["name"],
          initialSplits: _savedSplits,
        ),
      ),
    );

    if (res != null &&
        res["method"] == "custom" &&
        res["splits"] is Map<String, double>) {
      setState(() {
        _splitMethod = "unequal";
        _savedSplits = Map<String, double>.from(res["splits"] as Map);
      });
    }
  }

  Future<void> _onCreate() async {
    final groupName = _groupNameController.text.trim();
    final title = _titleController.text.trim(); // 👈 use title
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter group name")),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter title")),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one participant")),
      );
      return;
    }
    if (_selectedPayerName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a payer")),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final createdBy = prefs.getString('userId');
      final bearer = prefs.getString('authToken');

      if (createdBy == null) throw Exception('Not authenticated');

      final members = _participants.map((p) {
        return {
          if (p["userId"] != null) "userId": p["userId"],
          if (p["mobile"] != null) "mobile": p["mobile"],
          "name": p["name"],
        };
      }).toList();

      final payer = _participants.firstWhere(
        (p) => p["name"] == _selectedPayerName,
        orElse: () => {},
      );
      final payerId = payer["userId"];
      final payerMobile = payer["mobile"];

      final splitType = (_splitMethod == "unequal") ? "unequal" : "equal";
      final splitBetween = (splitType == 'equal')
          ? _participants.map((p) {
              final perHead = amount / max(_participants.length, 1);
              return {
                if (p["userId"] != null) "userId": p["userId"],
                if (p["mobile"] != null) "mobile": p["mobile"],
                "shareAmount": double.parse(perHead.toStringAsFixed(2)),
              };
            }).toList()
          : _savedSplits!.entries.map((e) {
              final part = _participants.firstWhere(
                (p) => p["name"] == e.key,
                orElse: () => {},
              );
              return {
                if (part["userId"] != null) "userId": part["userId"],
                if (part["mobile"] != null) "mobile": part["mobile"],
                "shareAmount": double.parse(e.value.toStringAsFixed(2)),
              };
            }).toList();

      final category = _mapCategory(_selectedCategory);

      final api = ExpenseApi();
      await api.createGroupWithExpense(
        groupName: groupName,
        createdBy: createdBy,
        members: members,
        title: title, // 👈 store user entered title here
        amount: amount,
        category: category,
        paidBy: payerId != null ? {"userId": payerId} : {"mobile": payerMobile},
        splitType: splitType,
        splitBetween: splitBetween,
        bearerToken: bearer,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group created")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Group",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group name
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: "Group name",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Expense title",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // amount + category
              Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: "INR ",
                        hintText: "Amount",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 6,
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: dividerColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories
                              .map((cat) => DropdownMenuItem<String>(
                                    value: cat["name"] as String,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 2),
                                        Icon(cat["icon"] as IconData,
                                            color: _primaryBlue),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            cat["name"] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // payer dropdown
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPayerName,
                    isExpanded: true,
                    items: _participants
                        .map((p) => DropdownMenuItem<String>(
                              value: p["name"] as String,
                              child: Text(
                                p["name"] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPayerName = v),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // participants
              const Text(
                "Participants",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF212121), width: 1),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _participants.length; i++) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _participants[i]["name"] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF263238),
                              ),
                            ),
                          ),
                          if (_participants[i]["isCurrent"] == true)
                            IconButton(
                              onPressed: _pickContact,
                              icon: const Icon(
                                Icons.person_add_alt_1,
                                color: _primaryBlue,
                                size: 20,
                              ),
                              splashRadius: 16,
                              tooltip: 'Add participant',
                            )
                          else
                            IconButton(
                              onPressed: () => _removeParticipant(i),
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              splashRadius: 16,
                              tooltip: 'Remove',
                            ),
                        ],
                      ),
                      if (i != _participants.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Divider(
                            color: _dividerGray,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // split row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _splitMethod = "equal";
                          _savedSplits = null;
                        });
                      },
                      icon: Icon(_splitMethod == "equal"
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off),
                      label: const Text("Split equally"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openSplitScreen,
                      icon: Icon(_splitMethod == "unequal"
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off),
                      label: const Text("Split unequally"),
                    ),
                  ),
                ],
              ),
              if (_splitMethod == "unequal" && _savedSplits != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Custom splits set",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Create",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
