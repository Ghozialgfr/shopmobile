import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';

class AuthService {
  static const _headers = {'Content-Type': 'application/json'};

  static Map<String, dynamic> _decode(String body) {
    try {
      final d = jsonDecode(body);
      return d is Map<String, dynamic> ? d : {};
    } catch (_) {
      return {};
    }
  }

  /// POST /login {"code": "123456"}. Melempar Exception jika gagal.
  static Future<void> login(String code) async {
    final res = await http
        .post(
          Uri.parse('${ApiService.host}/login'),
          headers: _headers,
          body: jsonEncode({'code': code}),
        )
        .timeout(const Duration(seconds: 15));
    final data = _decode(res.body);
    if (res.statusCode == 200 && data['authenticated'] == true) return;
    throw Exception(
      (data['message'] ?? data['error'] ?? 'Login gagal (${res.statusCode})')
          .toString(),
    );
  }

  /// GET /login -> issuer, account, secret, otp_auth_url, qr_code
  static Future<Map<String, dynamic>> fetchSetup() async {
    final res = await http
        .get(Uri.parse('${ApiService.host}/login'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat setup (${res.statusCode})');
    }
    return _decode(res.body);
  }
}
