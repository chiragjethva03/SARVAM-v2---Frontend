import 'package:flutter/material.dart';

class SplitAmountScreen extends StatefulWidget {
  final List<Map<String, dynamic>> participants;
  const SplitAmountScreen({super.key, required this.participants});

  @override
  State<SplitAmountScreen> createState() => _SplitAmountScreenState();
}

class _SplitAmountScreenState extends State<SplitAmountScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var p in widget.participants) {
      _controllers[p["name"]] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Amount"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, "Custom split");
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: widget.participants.map((p) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _controllers[p["name"]],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: p["name"],
                border: const OutlineInputBorder(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
