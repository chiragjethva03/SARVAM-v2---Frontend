import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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
}
