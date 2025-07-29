import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String userId;

  const CreatePostScreen({super.key, required this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedImage == null ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields and image are required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await PostService.createPost(
      userId: widget.userId,
      description: _descriptionController.text,
      location: _locationController.text,
      imagePath: _selectedImage!.path,
    );

    setState(() => _isLoading = false);

    if (response["status"] == 201) {
      // Clear form
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedImage = null;
      });

      // Show success and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully")),
      );
      Navigator.pop(context, true); // true to refresh home screen
    } else {
      final message = response["body"]?["message"] ?? "Something went wrong";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Light grey background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent, // Transparent to show Scaffold background
          elevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close (X) Icon
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context); // Go back
                  },
                ),
                // Location Field with black border and no fill color
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _locationController,
                        readOnly: false,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Enter here your location',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                          filled: false, // Set to false for transparent background
                          // Removed fillColor as it's not needed when filled is false

                          // Define the border for all states
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.0), // Black border
                          ),
                          // Ensure enabled and focused borders also have the black color
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.0), // Black border when enabled
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.0), // Black border when focused
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Share your Experience...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          // Bottom Bar for Image Picker and Post Button
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + screenHeight * 0.02,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              top: screenHeight * 0.01,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7), // Match Scaffold background color
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align children to the right
              crossAxisAlignment: CrossAxisAlignment.center, // Vertically center them
              children: [
                // Image Gallery Icon
                IconButton(
                  icon: Icon(
                    Icons.photo_library,
                    size: 28,
                    color: _selectedImage != null ? Colors.blue : Colors.grey[700],
                  ),
                  onPressed: _pickImage,
                ),
                const SizedBox(width: 8), // Small space between icon and button
                // Post Button
                SizedBox(
                  height: 40,
                  width: screenWidth * 0.25,
                  child: ElevatedButton(
                    onPressed: _isLoading || _selectedImage == null || _descriptionController.text.isEmpty || _locationController.text.isEmpty
                        ? null
                        : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3), // Post button color: 2196F3
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Post',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}