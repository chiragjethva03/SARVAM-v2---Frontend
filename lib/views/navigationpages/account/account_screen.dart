import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../../../services/account_api.dart';
import '../../auth/signin_screen.dart';
import '../../../providers/user_provider.dart';
import '../../debug_utils.dart';
import 'account_settings_sheet.dart';
import 'help_sheet.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final emailFromPrefs = prefs.getString('email');

    // Optionally fetch latest details from API (already built)
    final userDetails = await AccountApi.fetchUserDetails();

    setState(() {
      _email = userDetails?['email'] ?? emailFromPrefs;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.clearToken(context);
    await debugPrintSharedPrefs();
    debugPrintProvider(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // TODO: Upload image to backend
    }
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final fullName = userProvider.fullName ?? "";
    final profilePic = userProvider.profilePicture ?? "";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            // Header with background and centered profile picture
            // Header with background and centered profile picture
            SizedBox(
              height: 260, // total height for header section
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background image
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Accountbg/bg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Centered profile image, overlapping the background
                  Positioned(
                    top: 130,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (profilePic.isNotEmpty)
                                  ? NetworkImage(profilePic)
                                  : const AssetImage(
                                          'assets/images/default_avatar.png',
                                        )
                                        as ImageProvider,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_email ?? "", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Menu List
            _buildListTile(
              icon: Icons.badge,
              title: "Personal Details",
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.security,
              title: "Password and Security",
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.article,
              title: "My Activity",
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.settings,
              title: "Account Settings",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return AccountSettingsSheet(
                      onLogout: () {
                        Navigator.pop(context);
                        _logout(context); // your existing logout method
                      },
                      onDelete: () async {
                        final success = await AccountApi.deleteAccount();
                        if (success) {
                          Navigator.pop(context); // close sheet
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete account'),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
            _buildListTile(
              icon: Icons.help_outline,
              title: "Help",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return const HelpSheet();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
