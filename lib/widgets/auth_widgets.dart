// File: lib/widgets/auth_widgets.dart
import 'package:flutter/material.dart';

// ========================
// Email + Password Fields
// ========================
class EmailPasswordFields extends StatefulWidget {
  const EmailPasswordFields({super.key});

  @override
  State<EmailPasswordFields> createState() => _EmailPasswordFieldsState();
}

class _EmailPasswordFieldsState extends State<EmailPasswordFields> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Email Field
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            hintText: 'Email Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Field
        TextFormField(
          obscureText: _obscureText,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            hintText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ========================
// Google Auth Button
// ========================
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Image.asset(
          "assets/auth/google.png",
          height: 20,
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class FullNameField extends StatelessWidget {
  const FullNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.verified_user_outlined),
        hintText: 'Full name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}