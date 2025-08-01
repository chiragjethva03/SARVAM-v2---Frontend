import 'package:flutter/material.dart';

class AccountSettingsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDelete;

  const AccountSettingsSheet({
    super.key,
    required this.onLogout,
    required this.onDelete,
  });

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
                "Account Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Logout Button
          ListTile(
            tileColor: const Color(0xFF2196F3).withOpacity(0.11), // 11% opacity
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            onTap: onLogout,
          ),
          const SizedBox(height: 12),

          // Delete Account Button
          ListTile(
            tileColor: const Color(0xFFFF0000).withOpacity(0.30), // 30% opacity
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
