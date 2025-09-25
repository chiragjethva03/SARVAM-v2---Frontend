import 'package:flutter/material.dart';
import '../../services/forgot_password.dart'; // import service
import 'reset_password_screen.dart'; // import reset password screen

class OtpDialog extends StatefulWidget {
  final String email; // ✅ pass email to verify against backend
  const OtpDialog({super.key, required this.email});

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  void _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 4-digit OTP")),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await EmailValidateService.verifyOtp(widget.email, otp);

    setState(() => _loading = false);

    if (!result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Invalid OTP")),
      );
      return;
    }

    // ✅ If OTP is correct
    Navigator.pop(context); // close OTP dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "OTP Verified!")),
    );

    // ✅ Navigate to Reset Password screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Center(
        child: Text(
          "Enter OTP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: "4-digit OTP",
              border: OutlineInputBorder(),
            ),
          ),
          if (_loading) const SizedBox(height: 12),
          if (_loading) const CircularProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _verifyOtp,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
