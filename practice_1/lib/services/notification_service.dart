import 'package:practice_1/models/notification.dart';
import 'package:practice_1/services/api_service.dart';
import 'package:practice_1/services/session_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  Future<List<AppNotification>> getUserNotifications() async {
    final token = await _sessionService.getSessionToken();
    final userEmail = await _sessionService.getSessionEmail();
    if (token == null || userEmail == null) {
      throw Exception('User not authenticated');
    }
    return await _apiService.getNotifications(userEmail, token);
  }

  Future<void> sendNotification(AppNotification notification) async {
    final token = await _sessionService.getSessionToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    await _apiService.addNotification(notification, token);
  }
}