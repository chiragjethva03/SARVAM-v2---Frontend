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
        textAlignVertical: TextAlignVertical.center, // Vertically center text
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search), // Search icon as prefix
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners for the border
          ),
          // Adjust content padding to fine-tune the height.
          // The total height of the TextField will be contentPadding + intrinsic height of text/icon + border thickness.
          // By setting the SizedBox to 48, we let Flutter calculate the contentPadding if not specified,
          // or we can explicitly define it for more control.
          // For a fixed height of 48, the default contentPadding usually works well,
          // but if it's slightly off, you can fine-tune with specific values.
          // For this case, directly setting SizedBox height is the most straightforward.
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // Example adjustment
        ),
      ),
    );
  }
}