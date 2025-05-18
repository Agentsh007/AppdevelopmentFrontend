import 'dart:io';

class Constants {
   static final baseUrl = _getBaseUrl();
  static String _getBaseUrl() {
    if (Platform.isAndroid) {
      // Emulator
      return 'http://10.0.2.2:8000/api';
    } else {
      // iOS simulator or real device (both Android and iOS)
      return 'http://192.168.0.182:8000/api'; // Replace with your actual PC IP
    }
  }
}