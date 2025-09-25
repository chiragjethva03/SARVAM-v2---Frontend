import 'package:flutter/material.dart';
import 'dart:async'; // for Future.delayed
import '../../services/forgot_password.dart';
import 'otp_dialog.dart'; // import OTP dialog

class EmailValidateDialog extends StatefulWidget {
  const EmailValidateDialog({super.key});

  @override
  State<EmailValidateDialog> createState() => _EmailValidateDialogState();
}

class _EmailValidateDialogState extends State<EmailValidateDialog> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  void _validateEmail() async {
    final email = _emailController.text.trim();

    // ✅ Step 1: Validate Gmail format
    if (!email.endsWith("@gmail.com")) {
      setState(() {
        _message = "Only Gmail addresses are allowed.";
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    final result = await EmailValidateService.validateEmail(email);

    setState(() {
      _loading = false;
    });

    if (!result["success"]) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Email not found")),
      );
      return;
    }

    if (result["action"] == "google") {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ??
              "This account is Google login. Use Google to continue."),
        ),
      );
    } else if (result["action"] == "manual") {
      setState(() {
        _message = "OTP sent. Please check your email.";
      });

      // ✅ Step 2: After 3 sec, close this sheet & open OTP sheet
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context); // close current sheet
          showDialog(
            context: context,
            builder: (_) => OtpDialog(email: email), // ✅ pass email here
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Center(
        child: Text(
          "Forgot Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Enter your Gmail",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading) const CircularProgressIndicator(),
          if (_message != null)
            Text(
              _message!,
              style: TextStyle(
                color: _message!.contains("OTP") ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _validateEmail,
          child: const Text("Verify"),
        ),
      ],
    );
  }
}
