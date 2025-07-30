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
    return SizedBox( // Wrap TextField in a SizedBox to enforce explicit height
      height: 48, // Set the desired height
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center, // Vertically center text`
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search), // Search icon as prefix
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners for the border
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // Example adjustment
        ),
      ),
    );
  }
}