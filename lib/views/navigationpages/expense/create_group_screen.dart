import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('username') ?? 'You';
    setState(() {
      _participants = [
        {"name": currentUser, "paid": true}
      ];
    });
  }

  void _addParticipant(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _participants.add({"name": name.trim(), "paid": false});
    });
  }

  void _togglePaid(int index) {
    setState(() {
      for (var i = 0; i < _participants.length; i++) {
        _participants[i]["paid"] = false;
      }
      _participants[index]["paid"] = true;
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  Future<void> _pickContact() async {
    // Ask for permission via flutter_contacts
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contacts permission denied")),
      );
      return;
    }

    // Open native picker
    final picked = await FlutterContacts.openExternalPick();

    if (picked == null) return;

    // Get full contact by id to ensure displayName is complete
    final full = await FlutterContacts.getContact(picked.id);
    final String name = full?.displayName ?? picked.displayName;

    _addParticipant(name);
  }

  @override
  Widget build(BuildContext context) {
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
              // Group Name
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: "Group name",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Amount + Categories in one row
              Row(
                children: [
                  Expanded(
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat["name"] as String,
                              child: Row(
                                children: [
                                  Icon(cat["icon"] as IconData,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 10),
                                  Text(cat["name"] as String),
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
              const SizedBox(height: 16),

              // Participants
              const Text("Participants", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._participants.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(participant["name"] as String),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _togglePaid(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: (participant["paid"] as bool)
                                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                                    : Theme.of(context).dividerColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Paid",
                                style: TextStyle(
                                  color: (participant["paid"] as bool)
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (index != 0) // do not remove current user
                            GestureDetector(
                              onTap: () => _removeParticipant(index),
                              child: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              GestureDetector(
                onTap: _pickContact,
                child: Text(
                  "Add Participants",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Backend logic here
                    // Access values:
                    // _groupNameController.text, _amountController.text, _selectedCategory, _participants
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Create",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
