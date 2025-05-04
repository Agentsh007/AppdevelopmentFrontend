import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionService {
  static const String _tokenKey = 'shanto';

  Future<void> saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return false;
    try {
      final decoded = JwtDecoder.decode(token);
      final expiry = decoded['exp'] as int?;
      if (expiry == null) return false;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || !await isSessionValid()) return null;
    return token;
  }

  Future<String?> getSessionEmail() async {
    final token = await getSessionToken();
    if (token == null) return null;
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['email'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}