import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal API wrapper for Expense service.
/// Set BASE_URL to your server origin. Example: https://api.example.com
class ExpenseApi {
  static const String BASE_URL = String.fromEnvironment(
    'EXPENSE_API_BASE',
    defaultValue: '${ApiConfig.baseUrl}', // change for prod
  );

  Uri _u(String path) => Uri.parse('$BASE_URL$path');

  Map<String, String> _headers(String? bearer) => {
    'Content-Type': 'application/json',
    if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
  };

  /// Creates a group and the first expense in one call.
  ///
  /// Backend route expected: POST /api/expenses/group-with-expense
  Future<Map<String, dynamic>> createGroupWithExpense({
    required String groupName,
    required String createdBy,
    required List<Map<String, dynamic>> members,
    required String title,
    required double amount,
    required String category,
    required Map<String, dynamic> paidBy,
    required String splitType,
    required List<Map<String, dynamic>> splitBetween,
    String? bearerToken,
  }) async {
    final body = {
      "groupName": groupName,
      "createdBy": createdBy,
      "members": members,
      "expense": {
        "title": title,
        "amount": amount,
        "category": category,
        "paidBy": paidBy,
        "splitType": splitType,
        "splitBetween": splitBetween,
      },
    };

    final res = await http.post(
      Uri.parse('$BASE_URL/api/expenses/group-with-expense'),
      headers: _headers(bearerToken),
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body.isEmpty ? '{}' : res.body)
          as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Fetch groups for current user by userId or mobile
  Future<List<Map<String, dynamic>>> getMyGroups({
    String? userId,
    String? mobile,
    String? bearerToken,
  }) async {
    if ((userId == null || userId.isEmpty) &&
        (mobile == null || mobile.isEmpty)) {
      throw Exception('userId or mobile required');
    }

    String normalize(String? m) {
      if (m == null) return '';
      final d = m.replaceAll(RegExp(r'\D'), '');
      return d.length > 12 ? d.substring(d.length - 12) : d;
    }

    final q = <String, String>{};
    if (userId != null && userId.isNotEmpty) q['userId'] = userId;
    if (mobile != null && mobile.isNotEmpty) q['mobile'] = normalize(mobile);

    final uri = Uri.parse(
      '${ExpenseApi.BASE_URL}/api/expenses/my-groups',
    ).replace(queryParameters: q);

    final res = await http.get(uri, headers: _headers(bearerToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Unexpected response');
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Fetch details for a single group by groupId
  Future<Map<String, dynamic>> getGroupDetails({
    required String groupId,
    String? bearerToken,
  }) async {
    final uri = Uri.parse(
      '${ExpenseApi.BASE_URL}/api/expenses/groups/$groupId',
    );

    final res = await http.get(uri, headers: _headers(bearerToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      throw Exception('Unexpected response');
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Delete group by groupId
  Future<void> deleteGroup({
    required String groupId,
    String? bearerToken,
  }) async {
    final uri = Uri.parse(
      '${ExpenseApi.BASE_URL}/api/expenses/delete/$groupId',
    );

    final res = await http.delete(uri, headers: _headers(bearerToken));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return; // success, nothing else to parse
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Join an existing group using groupId (e.g. SarvamEx1234)
  Future<Map<String, dynamic>> joinGroup({
    required String groupId,
    String? bearerToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('fullName') ?? '';
    final mobile = prefs.getString('mobile') ?? '';
    final userId = prefs.getString('userId');

    final uri = Uri.parse('$BASE_URL/api/expenses/joingroup');

    // ✅ Only include userId if it’s not null
    final body = {
      "groupId": groupId,
      if (userId != null) "userId": userId,
      "name": name,
      "mobile": mobile,
    };

    final res = await http.post(
      uri,
      headers: _headers(bearerToken),
      body: jsonEncode(body),
    );

    try {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // ✅ Safely decode JSON, fallback to empty map
        final decoded = res.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(res.body) as Map<String, dynamic>;
        return decoded;
      } else {
        // ✅ Try decoding error response safely
        final decoded = res.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(res.body) as Map<String, dynamic>;
        final message = decoded['error'] ?? 'Something went wrong';
        throw message; // 👈 Will only throw the message string
      }
    } catch (e) {
      // ✅ Catch JSON parsing issues or other errors
      throw 'Unexpected error: ${e.toString()}';
    }
  }
}
