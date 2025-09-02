import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'splitamountscreen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
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
  String? _selectedPayer;
  List<Map<String, dynamic>> _splits = [];
  Map<String, double>? _savedSplits;
  String _splitMethod = "Split equally";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('fullName') ?? 'You';
    setState(() {
      _participants = [
        {"name": currentUser, "isCurrent": true},
      ];
      _selectedPayer = currentUser;
    });
  }

  void _addParticipant(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _participants.add({"name": name.trim(), "isCurrent": false});
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      final removedName = _participants[index]["name"] as String;
      _participants.removeAt(index);
      if (_selectedPayer == removedName && _participants.isNotEmpty) {
        _selectedPayer = _participants.first["name"] as String;
      }
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
    _addParticipant(name);

    // Show a serious attention-grabbing dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text("Important"),
            ],
          ),
          content: Text(
            "$name has been added.\n\n"
            "Tell your friend to install the app and update their number in profile "
            "for the best experience when splitting expenses.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text("Got it"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _participantRow({
    required int index,
    required String name,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF263238),
            ),
          ),
        ),
        if (isCurrent)
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
            onPressed: () => _removeParticipant(index),
            icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
            splashRadius: 16,
            tooltip: 'Remove',
          ),
      ],
    );
  }

  Widget _participantsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Participants",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF212121), width: 1),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _participants.length; i++) ...[
                _participantRow(
                  index: i,
                  name: _participants[i]["name"] as String,
                  isCurrent: _participants[i]["isCurrent"] as bool,
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
      ],
    );
  }

  Widget _paidAndSplitRow() {
    final defaultColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              String? selected = await showModalBottomSheet<String>(
                context: context,
                builder: (context) {
                  return ListView(
                    shrinkWrap: true,
                    children: _participants.map((p) {
                      bool isSelected = p["name"] == _selectedPayer;
                      return ListTile(
                        title: Text(p["name"]),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => Navigator.pop(context, p["name"]),
                      );
                    }).toList(),
                  );
                },
              );
              if (selected != null) {
                setState(() => _selectedPayer = selected);
              }
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: defaultColor,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: "Paid by "),
                  TextSpan(
                    text: _selectedPayer ?? "",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text("·"),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SplitAmountScreen(
                    participants: _participants,
                    totalAmount: double.tryParse(_amountController.text) ?? 0,
                    currentUser: _selectedPayer ?? "",
                    initialSplits: _savedSplits,
                  ),
                ),
              );

              if (result != null && result is Map) {
                // result expected: {"method": "custom", "splits": Map<String,double>}
                final splits = result["splits"];
                if (splits is Map<String, double>) {
                  setState(() {
                    _savedSplits = Map<String, double>.from(splits);
                    _splitMethod = "Custom split";
                  });
                } else if (splits is Map) {
                  // sometimes dynamic typing: try to convert numeric values
                  final converted = <String, double>{};
                  splits.forEach((k, v) {
                    final numVal = v is num
                        ? v.toDouble()
                        : double.tryParse(v.toString()) ?? 0.0;
                    converted[k.toString()] = double.parse(
                      numVal.toStringAsFixed(2),
                    );
                  });
                  setState(() {
                    _savedSplits = converted;
                    _splitMethod = "Custom split";
                  });
                }
              }
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: defaultColor,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: _splitMethod,
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: "Group name",
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
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 4,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
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
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat["name"] as String,
                              child: Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Icon(
                                    cat["icon"] as IconData,
                                    color: _primaryBlue,
                                  ),
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
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _participantsBlock(),
              _paidAndSplitRow(),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
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
