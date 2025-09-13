import 'package:flutter/material.dart';
import '../../services/forgot_password.dart';

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
    setState(() {
      _loading = true;
      _message = null;
    });

    final result =
        await EmailValidateService.validateEmail(_emailController.text.trim());

    setState(() {
      _loading = false;
    });

    if (!result["success"]) {
      // Email not found → back to SignIn screen
      Navigator.pop(context); // closes dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Email not found")),
      );
      return;
    }

    if (result["action"] == "google") {
      // close dialog and show info message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ??
              "This account is Google login. Use Google to continue."),
        ),
      );
    } else if (result["action"] == "manual") {
      // ✅ show OTP dialog (next step later)
      setState(() {
        _message = "OTP sent. Please check your email.";
      });
      // TODO: open OTP dialog (you’ll design later)
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
              labelText: "Enter your email",
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
