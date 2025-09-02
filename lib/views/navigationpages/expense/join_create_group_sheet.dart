import 'package:flutter/material.dart';
import 'create_group_screen.dart';

class JoinCreateGroupSheet extends StatelessWidget {
  final VoidCallback onJoinGroup;
  final VoidCallback onCreateNew;

  const JoinCreateGroupSheet({
    super.key,
    required this.onJoinGroup,
    required this.onCreateNew,
  });

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.11), // 11% opacity
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
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
                "Manage Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Create New Group
          _buildActionTile(
            title: "Create New Group",
            subtitle: "Start a new expense tracking group",
            icon: Icons.group_add,
            onTap: () {
              Navigator.pop(context); // close bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateGroupScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),//

          // Join Existing Group
          _buildActionTile(
            title: "Join Existing Group",
            subtitle: "Enter a 6-digit code to join",
            icon: Icons.meeting_room,
            onTap: onJoinGroup,
          ),
        ],
      ),
    );
  }
}
