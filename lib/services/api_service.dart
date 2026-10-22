import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nguoi_dung.dart';
import '../models/ca_lam_viec.dart';
import '../models/phien_cham_cong.dart';
import '../models/bang_cham_cong.dart';
import '../models/don_nghi_phep.dart';
import 'mock_data_repository.dart';

class ApiService {
  // Singleton Pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  static ApiService get instance => _instance;

  ApiService._internal();

  // Địa chỉ Web API của nhóm (khớp cổng 5085 trong launchSettings.json của VuuKienDinh_Nhom8_Backend)
  static String baseUrl = 'http://10.0.2.2:5085/api';

  final MockDataRepository _mockRepo = MockDataRepository.instance;

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  // ==================== GENERIC HTTP HELPERS ====================

  Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .get(url, headers: _defaultHeaders)
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .post(
          url,
          headers: _defaultHeaders,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .put(
          url,
          headers: _defaultHeaders,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .delete(url, headers: _defaultHeaders)
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
        'Lỗi kết nối API (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ==================== AUTHENTICATION API ====================

  /// Đăng nhập bằng TenDangNhap & MatKhau
  Future<NguoiDung?> login(String tenDangNhap, String matKhau) async {
    if (MockDataRepository.useMockData) {
      await Future.delayed(const Duration(milliseconds: 350));
      return _mockRepo.authenticate(tenDangNhap, matKhau);
    }

    final data = await postRequest('/Auth/Login', {
      'TenDangNhap': tenDangNhap,
      'MatKhau': matKhau,
    });
    if (data != null && data is Map<String, dynamic>) {
      return NguoiDung.fromJson(data);
    }
    return null;
  }

  /// Xác thực mã OTP 6 số gửi qua Email
  Future<bool> verifyOtp(String email, String otpCode) async {
    if (MockDataRepository.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockRepo.verifyOtp(otpCode);
    }

    final data = await postRequest('/Auth/VerifyOtp', {
      'Email': email,
      'MaOTP': otpCode,
    });
    return data != null && (data['Success'] == true || data == true);
  }

  /// Đăng ký tài khoản nhân viên mới
  Future<NguoiDung> register(NguoiDung user) async {
    if (MockDataRepository.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_mockRepo.isUserExists(user.TenDangNhap, user.Email)) {
        throw Exception('Tên đăng nhập hoặc Email đã tồn tại trong hệ thống!');
      }
      return _mockRepo.registerUser(
        maNV: user.MaNV,
        tenDangNhap: user.TenDangNhap,
        matKhau: user.MatKhau,
        hoTen: user.HoTen,
        email: user.Email,
        maPhongBan: user.MaPhongBan,
        tenPhongBan: user.TenPhongBan,
        maThietBi: user.MaThietBi,
      );
    }

    final data = await postRequest('/Auth/Register', user.toJson());
    return NguoiDung.fromJson(data as Map<String, dynamic>);
  }

  // ==================== BUSINESS API METHODS ====================

  Future<List<NguoiDung>> getDanhSachNguoiDung() async {
    if (MockDataRepository.useMockData) {
      return List<NguoiDung>.from(_mockRepo.danhSachNguoiDung);
    }
    final list = await getRequest('/NguoiDung') as List<dynamic>;
    return list
        .map((item) => NguoiDung.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CaLamViec>> getDanhSachCaLamViec() async {
    if (MockDataRepository.useMockData) {
      return List<CaLamViec>.from(_mockRepo.danhSachCaLamViec);
    }
    final list = await getRequest('/CaLamViec') as List<dynamic>;
    return list
        .map((item) => CaLamViec.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PhienChamCong>> getDanhSachPhienChamCong() async {
    if (MockDataRepository.useMockData) {
      return List<PhienChamCong>.from(_mockRepo.danhSachPhienChamCong);
    }
    final list = await getRequest('/PhienChamCong') as List<dynamic>;
    return list
        .map((item) => PhienChamCong.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BangChamCong>> getBangChamCong({String? maNV}) async {
    if (MockDataRepository.useMockData) {
      if (maNV != null && maNV.isNotEmpty) {
        return _mockRepo.getBangChamCongByMaNV(maNV);
      }
      return List<BangChamCong>.from(_mockRepo.danhSachBangChamCong);
    }
    final endpoint = (maNV != null && maNV.isNotEmpty)
        ? '/BangChamCong/NhanVien/$maNV'
        : '/BangChamCong';
    final list = await getRequest(endpoint) as List<dynamic>;
    return list
        .map((item) => BangChamCong.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<DonNghiPhep>> getDanhSachDonNghiPhep({String? maNV}) async {
    if (MockDataRepository.useMockData) {
      if (maNV != null && maNV.isNotEmpty) {
        return _mockRepo.getDonNghiPhepByMaNV(maNV);
      }
      return List<DonNghiPhep>.from(_mockRepo.danhSachDonNghiPhep);
    }
    final endpoint = (maNV != null && maNV.isNotEmpty)
        ? '/DonNghiPhep/NhanVien/$maNV'
        : '/DonNghiPhep';
    final list = await getRequest(endpoint) as List<dynamic>;
    return list
        .map((item) => DonNghiPhep.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
