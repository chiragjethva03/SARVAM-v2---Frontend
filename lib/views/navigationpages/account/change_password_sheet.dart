import 'package:flutter/material.dart';
import '../../../services/account_api.dart';
import '../../../services/auth_service.dart'; // for logout after password change if needed

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _loading = false;

  Future<void> _savePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final retype = _retypePasswordController.text.trim();

    // 1. Validation
    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your current password")),
      );
      return;
    }

    if (newPass.isEmpty || retype.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter and confirm new password")),
      );
      return;
    }

    if (newPass != retype) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    print("Before calling API");
    final result = await AccountApi.changePasswordDetailed(
      currentPassword: current,
      newPassword: newPass,
    );
    print("After calling API");

    setState(() {
      _loading = false;
    });

    if (result["success"] == true) {
      Navigator.pop(context);

      Future.delayed(const Duration(milliseconds: 300), () async {
        // Show message first
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              "Password updated successfully. Please login again with your new password.",
            ),
          ),
        );

        // Give time for the user to read the message
        await Future.delayed(const Duration(seconds: 2));

        // Then log out
        await AuthService.clearToken(context);
      });
    }
  }

  InputDecoration _decoration(
    String hint, {
    bool withToggle = false,
    VoidCallback? onToggle,
    bool obscure = true,
  }) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: withToggle
          ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                "Change password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current password
          TextField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            decoration: _decoration(
              "Current password",
              withToggle: true,
              obscure: _obscureCurrent,
              onToggle: () {
                setState(() {
                  _obscureCurrent = !_obscureCurrent;
                });
              },
            ),
          ),
          const SizedBox(height: 12),

          // New password
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            decoration: _decoration(
              "New password",
              withToggle: true,
              obscure: _obscureNew,
              onToggle: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
            ),
          ),
          const SizedBox(height: 12),

          // Retype new password
          TextField(
            controller: _retypePasswordController,
            obscureText: true,
            decoration: _decoration("Retype new password"),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _savePassword,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save changes"),
            ),
          ),
        ],
      ),
    );
  }
}
