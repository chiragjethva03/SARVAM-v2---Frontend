import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45, // slightly smaller height for a search bar
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),

          // Background style (same as before)
          filled: true,
          fillColor: const Color(0xFF2196F3).withOpacity(0.11),

          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),

          // Rounded border with no visible outline (only on focus)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),

          // Adjusted padding
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }
}
