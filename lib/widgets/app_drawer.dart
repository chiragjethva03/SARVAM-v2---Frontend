import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final fullName = userProvider.fullName?.isNotEmpty == true
            ? userProvider.fullName!
            : 'Guest';
        final profilePicture = userProvider.profilePicture ?? '';

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(45),
            bottomRight: Radius.circular(45),
          ),
          child: Drawer(
            child: Column(
              children: [
                // Drawer Header
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.11),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : null,
                            child: profilePicture.isEmpty
                                ? const Icon(Icons.person, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Get Ready for Adventure.!",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Drawer Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: const [
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("About"),
                      ),
                      ListTile(
                        leading: Icon(Icons.privacy_tip_outlined),
                        title: Text("Privacy Policy"),
                      ),
                      ListTile(
                        leading: Icon(Icons.share),
                        title: Text("Share with Friends"),
                      ),
                      ListTile(
                        leading: Icon(Icons.description_outlined),
                        title: Text("Terms and Conditions"),
                      ),
                      ListTile(
                        leading: Icon(Icons.support_agent),
                        title: Text("Help & Support"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
