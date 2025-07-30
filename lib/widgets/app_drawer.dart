import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final fullName = userProvider.fullName ?? 'Guest';
        final profilePicture = userProvider.profilePicture ?? '';

        return Drawer(
          child: Column(
            children: [
              // Custom Header (no divider line)
              Container(
                height: 200, // same as DrawerHeader
                width: double.infinity,
                color: const Color(0xFF2196F3).withOpacity(0.11),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.center, // center like DrawerHeader
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: profilePicture.isNotEmpty
                            ? NetworkImage(profilePicture)
                            : null,
                        child: profilePicture.isEmpty
                            ? const Icon(Icons.person)
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Get Ready for Adventure.!",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Menu Items
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("About"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text("Privacy Policy"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share with Friends"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text("Terms and Conditions"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text("Help & Support"),
                onTap: () {},
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.pink),
                    Icon(Icons.linked_camera, color: Colors.blue),
                    Icon(Icons.public, color: Colors.black),
                    Icon(Icons.play_circle_fill, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
