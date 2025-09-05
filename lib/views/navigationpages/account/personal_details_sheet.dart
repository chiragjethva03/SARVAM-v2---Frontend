import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/user_provider.dart';
import '../../../services/account_api.dart'; // must expose updatePersonalDetails(context:, fullName:, phoneNumber:)

class PersonalDetailsSheet extends StatefulWidget {
  final String fullName;
  final String email;
  final String? mobileNumber;
  final Function(String fullName, String? mobileNumber) onSave;

  const PersonalDetailsSheet({
    super.key,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.onSave,
  });

  @override
  State<PersonalDetailsSheet> createState() => _PersonalDetailsSheetState();
}

class _PersonalDetailsSheetState extends State<PersonalDetailsSheet> {
  late TextEditingController _fullNameController;
  late TextEditingController _mobileController;
  bool _mobileEditable = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _mobileController = TextEditingController(text: widget.mobileNumber ?? "");
    _mobileEditable = (widget.mobileNumber == null || widget.mobileNumber!.isEmpty);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    setState(() => _loading = true);

    final newFullName = _fullNameController.text.trim();

    // Only allow sending a phone when field is editable and non-empty
    final String? newMobile = _mobileEditable
        ? (_mobileController.text.trim().isEmpty ? null : _mobileController.text.trim())
        : null; // keep existing on server

    final ok = await AccountApi.updatePersonalDetails(
      context: context,
      fullName: newFullName,
      phoneNumber: newMobile, // null means "do not change" on backend
    );

    setState(() => _loading = false);

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update details')));
      return;
    }

    // Update provider name
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(newFullName, userProvider.profilePicture ?? "");

    // Callback to parent
    widget.onSave(newFullName, newMobile ?? widget.mobileNumber);

    // Lock mobile after first successful save
    if (_mobileEditable && (newMobile != null && newMobile.isNotEmpty)) {
      setState(() {
        _mobileEditable = false;
        _mobileController.text = newMobile;
      });
    }

    // Debug verify
    final prefs = await SharedPreferences.getInstance();
    // ignore: avoid_print
    print('Mobile in prefs: ${prefs.getString('mobile')}');

    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      prefixText: prefixText,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Personal details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: _inputDecoration(
                hint: "Full Name",
                icon: Icons.verified_user_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mobileController,
              enabled: _mobileEditable,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: _mobileEditable ? Colors.black : Colors.grey,
              ),
              decoration: _inputDecoration(
                hint: (widget.mobileNumber == null || widget.mobileNumber!.isEmpty)
                    ? "Mobile Number"
                    : widget.mobileNumber!,
                icon: Icons.phone_outlined,
                prefixText: "+91 ",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: false,
              decoration: _inputDecoration(
                hint: widget.email,
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveDetails,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save changes"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
