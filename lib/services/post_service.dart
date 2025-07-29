import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../config/api_config.dart';

class PostService {
  /// Create a new post with image upload
  static Future<Map<String, dynamic>> createPost({
    required String userId,
    required String description,
    required String location,
    required String imagePath,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/create-post');
      final request = http.MultipartRequest("POST", uri);

      // Add text fields
      request.fields['userId'] = userId;
      request.fields['description'] = description;
      request.fields['location'] = location;

      // Detect file type for Cloudinary upload
      final mimeTypeData = lookupMimeType(
        imagePath,
        headerBytes: [0xFF, 0xD8],
      )?.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return {"status": response.statusCode, "body": jsonDecode(response.body)};
    } catch (e) {
      return {
        "status": 500,
        "body": {"message": "Error creating post: $e"},
      };
    }
  }

  /// Fetch all posts (with populated user info)
  static Future<List<dynamic>> fetchPosts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['posts']; // Adjust this if your JSON key is different
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  
}
