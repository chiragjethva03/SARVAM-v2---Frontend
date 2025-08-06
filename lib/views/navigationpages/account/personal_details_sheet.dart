import 'package:flutter/material.dart';
import '../../../services/account_api.dart';

class PersonalDetailsSheet extends StatefulWidget {
  final String fullName;
  final String email;
  final String? mobileNumber; // still okay to call it mobileNumber in widget
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

    // ✅ Enable mobile field only if it's empty
    _mobileEditable =
        widget.mobileNumber == null || widget.mobileNumber!.isEmpty;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    setState(() {
      _loading = true;
    });

    final newFullName = _fullNameController.text.trim();
    final newMobile = _mobileEditable
        ? _mobileController.text.trim()
        : widget.mobileNumber;

    // ✅ Send the correct field name expected by the backend: "phoneNumber"
    final success = await AccountApi.updatePersonalDetails(
      fullName: newFullName,
      phoneNumber: newMobile, // <-- FIXED
    );

    setState(() {
      _loading = false;
    });

    if (success) {
      widget.onSave(newFullName, newMobile);

      // Disable mobile editing if user just added mobile
      if (_mobileEditable && (newMobile?.isNotEmpty ?? false)) {
        setState(() {
          _mobileEditable = false;
          _mobileController.text = newMobile!;
        });
      }

      Navigator.pop(context);
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            // Full Name
            TextField(
              controller: _fullNameController,
              decoration: _inputDecoration(
                hint: "Full Name",
                icon: Icons.verified_user_outlined,
              ),
            ),
            const SizedBox(height: 12),

            // Mobile Number
            TextField(
              controller: _mobileController,
              enabled: _mobileEditable,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: _mobileEditable ? Colors.black : Colors.grey,
              ),
              decoration: _inputDecoration(
                hint:
                    widget.mobileNumber == null || widget.mobileNumber!.isEmpty
                    ? "Mobile Number"
                    : widget.mobileNumber!, // ✅ show real number if exists
                icon: Icons.phone_outlined,
                prefixText: "+91 ",
              ),
            ),

            const SizedBox(height: 12),

            // Email (read-only)
            TextField(
              enabled: false,
              decoration: _inputDecoration(
                hint: widget.email,
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
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
