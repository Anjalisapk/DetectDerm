import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ── Change this to your PC's IP address ──
  static const String baseUrl = 'http://192.168.1.76:5000';

  // ── Register new user ────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server connect हुन सकेन!'};
    }
  }

  // ── Login existing user ──────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server connect हुन सकेन!'};
    }
  }

  // ── Online predict (Flask API) ───────────
  static Future<Map<String, dynamic>> predictOnline(
      String imagePath, {int? userId}) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/predict'),
      );
      if (userId != null) {
        request.fields['user_id'] = userId.toString();
      }
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      return {'error': 'offline'};  // ← Offline mode trigger
    }
  }

  // ── Save feedback ────────────────────────
  static Future<Map<String, dynamic>> saveFeedback(
      int scanId, int rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'scan_id': scanId,
          'rating': rating,
          'comment': comment,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server connect हुन सकेन!'};
    }
  }

  // ── Get scan history ─────────────────────
  static Future<List<dynamic>> getHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$userId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }
}