import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmailValidateService {
  static const String baseUrl = "${ApiConfig.baseUrl}"; // replace with real URL

  static Future<Map<String, dynamic>> validateEmail(String email) async {
    final url = Uri.parse("$baseUrl/validate-email");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Something went wrong. Try again later."
      };
    }
  }
}
