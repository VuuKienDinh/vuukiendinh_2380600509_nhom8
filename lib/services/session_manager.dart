import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/nguoi_dung.dart';

class SessionManager {
  // Singleton Pattern
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  static SessionManager get instance => _instance;

  SessionManager._internal();

  static const String _keyCurrentUser = 'CURRENT_USER_SESSION';
  static const String _keyLastUsername = 'LAST_LOGGED_USERNAME';

  NguoiDung? _currentUser;
  NguoiDung? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Lưu phiên người dùng sau khi xác thực OTP thành công
  Future<void> saveSession(NguoiDung user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
    await prefs.setString(_keyLastUsername, user.TenDangNhap);
  }

  /// Tải lại phiên đăng nhập từ bộ nhớ thiết bị
  Future<NguoiDung?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCurrentUser);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> map =
            jsonDecode(jsonStr) as Map<String, dynamic>;
        _currentUser = NguoiDung.fromJson(map);
        return _currentUser;
      } catch (e) {
        debugPrint('Lỗi đọc session: $e');
      }
    }
    return null;
  }

  /// Lấy tên đăng nhập gần nhất (phục vụ đăng nhập nhanh bằng Khuôn mặt/Sinh trắc học)
  Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUsername);
  }

  /// Đăng xuất và xóa phiên hiện tại (giữ lại LastUsername để hỗ trợ Face ID lần sau)
  Future<void> clearSession() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
  }

  /// Lấy mã định danh thiết bị thực tế bằng device_info_plus
  Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return 'WEB_${webInfo.browserName.name}_${webInfo.vendor ?? "DEVICE"}';
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final androidInfo = await deviceInfo.androidInfo;
          return 'ANDROID_${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
        case TargetPlatform.iOS:
          final iosInfo = await deviceInfo.iosInfo;
          return 'IOS_${iosInfo.name}_${iosInfo.identifierForVendor ?? "UNKNOWN"}';
        case TargetPlatform.windows:
          final winInfo = await deviceInfo.windowsInfo;
          return 'WIN_${winInfo.computerName}';
        default:
          return 'FLUTTER_MOBILE_DEVICE_2380600509';
      }
    } catch (_) {
      return 'DEVICE_VKD_2380600509';
    }
  }
}
