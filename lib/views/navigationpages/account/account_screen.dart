import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../../../services/account_api.dart';
import '../../auth/signin_screen.dart';
import '../../debug_utils.dart';
import 'account_settings_sheet.dart';
import 'my_activity_screen.dart';
import 'help_sheet.dart';
import 'personal_details_sheet.dart';
import 'change_password_sheet.dart';
import 'GoogleSignInInfoSheet.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? _email;
  String? _fullName;
  String? _mobileNumber;
  String? _profilePic;
  String? _authProvider;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final emailFromPrefs = prefs.getString('email');

    final userDetails = await AccountApi.fetchUserDetails();

    setState(() {
      _email = userDetails?['email'] ?? emailFromPrefs;
      _fullName = userDetails?['fullName'] ?? "";
      _mobileNumber = userDetails?['phoneNumber'];
      _profilePic = userDetails?['profilePicture'] ?? "";
      _authProvider = userDetails?['authProvider'] ?? "manual";
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

      final newUrl = await AccountApi.uploadProfilePicture(_selectedImage!);

      if (newUrl != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setProfilePicture(newUrl); // ✅ Now this works

        await _loadUserData(); // Optional, based on your app

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile picture")),
        );
      }
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
    final fullName = _fullName ?? "";
    final profilePic = _profilePic ?? "";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            SizedBox(
              height: 260,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
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
                                          'assets/Accountbg/default_avatar.png',
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
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) {
                    return PersonalDetailsSheet(
                      fullName: _fullName ?? "",
                      email: _email ?? "",
                      mobileNumber: _mobileNumber,
                      onSave: (newFullName, newMobile) {
                        // Update state after saving
                        setState(() {
                          _fullName = newFullName;
                          if (_mobileNumber == null || _mobileNumber!.isEmpty) {
                            _mobileNumber = newMobile;
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
            _buildListTile(
              icon: Icons.security,
              title: "Password and Security",
              onTap: () {
                final authProvider = _authProvider ?? "manual";

                if (authProvider == "google") {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => const GoogleSignInInfoSheet(),
                  );
                } else {
                  // Open Change Password sheet for manual accounts
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) {
                      return const ChangePasswordSheet();
                    },
                  );
                }
              },
            ),

            _buildListTile(
              icon: Icons.article,
              title: "My Activity",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyActivityScreen(),
                  ),
                );
              },
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
                        _logout(context);
                      },
                      onDelete: () async {
                        final success = await AccountApi.deleteAccount();
                        if (success) {
                          Navigator.pop(context);
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
