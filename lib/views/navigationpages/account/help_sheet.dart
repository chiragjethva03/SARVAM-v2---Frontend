import 'package:flutter/material.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Help",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Static Help Contacts
          ListTile(
            tileColor: const Color(0xFF2196F3).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("+91 6354809704"),
            trailing: Wrap(
              spacing: 12,
              children: const [
                Icon(Icons.call, color: Colors.black),
                Icon(Icons.message, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: const Color(0xFF2196F3).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("+91 6354809704"),
            trailing: Wrap(
              spacing: 12,
              children: const [
                Icon(Icons.call, color: Colors.black),
                Icon(Icons.message, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
