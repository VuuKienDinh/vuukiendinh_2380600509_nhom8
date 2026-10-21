import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/nguoi_dung.dart';
import '../../models/ca_lam_viec.dart';
import '../../models/bang_cham_cong.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';
import '../auth/face_auth_screen.dart';

class ChamCongQrScreen extends StatefulWidget {
  final NguoiDung? currentUser;
  final CaLamViec? initialShift;

  const ChamCongQrScreen({
    super.key,
    this.currentUser,
    this.initialShift,
  });

  @override
  State<ChamCongQrScreen> createState() => _ChamCongQrScreenState();
}

class _ChamCongQrScreenState extends State<ChamCongQrScreen> {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const double maxAllowedRadiusMeters = 50.0;

  final MockDataRepository _repo = MockDataRepository.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  late CaLamViec _selectedShift;

  // Bước 1: Trạng thái xác thực Vân tay / Sinh trắc học
  bool _isBiometricVerified = false;
  String _biometricStatus = 'Chưa xác thực vân tay / sinh trắc học';

  // Bước 2: Trạng thái vị trí GPS & Switch "Chế độ Test tại văn phòng"
  bool _testAtOfficeMode = true;
  bool _isCheckingGps = false;
  double? _employeeLat;
  double? _employeeLng;
  double? _distanceMeters;
  String _gpsMessage = '';

  // Bước 3: Thiết bị phần cứng (DeviceID) & Quét QR
  String _hardwareDeviceId = 'ANDROID-VKD-2380600509';
  bool _simulateFraudDeviceMode = false;
  bool _isCameraScannerOpen = false;
  String? _fraudAlertMessage;

  NguoiDung get _employee =>
      widget.currentUser ??
      SessionManager.instance.currentUser ??
      _repo.danhSachNguoiDung.firstWhere(
        (u) => u.MaNV == '2380600509',
        orElse: () => _repo.danhSachNguoiDung.first,
      );

  @override
  void initState() {
    super.initState();
    _selectedShift = widget.initialShift ?? _repo.danhSachCaLamViec.first;
    _initHardwareDeviceId();
    _applyGpsByMode();
  }

  // ==================== LẤY HARDWARE DEVICE ID (androidInfo.id) ====================

  Future<void> _initHardwareDeviceId() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        if (!mounted) return;
        setState(() {
          _hardwareDeviceId = androidInfo.id.isNotEmpty
              ? 'ANDROID_${androidInfo.id}'
              : _employee.MaThietBi;
        });
      } else {
        final id = await SessionManager.instance.getDeviceId();
        if (!mounted) return;
        setState(() {
          _hardwareDeviceId = id;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hardwareDeviceId = _employee.MaThietBi;
      });
    }
  }

  String get _effectiveDeviceId =>
      _simulateFraudDeviceMode ? 'ANDROID-NAM-002' : _hardwareDeviceId;

  // ==================== BƯỚC 1: XÁC THỰC VÂN TAY (LOCAL_AUTH) ====================

  Future<void> _verifyBiometricFingerprint() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (canCheck && isSupported) {
        final didAuth = await _localAuth.authenticate(
          localizedReason:
              'Vui lòng đặt vân tay để mở khóa bước chấm công QR cho ${_employee.HoTen}',
        );
        if (!mounted) return;
        setState(() {
          _isBiometricVerified = didAuth;
          _biometricStatus = didAuth
              ? 'Đã xác thực Vân tay phần cứng hợp lệ!'
              : 'Xác thực vân tay bị hủy hoặc không khớp.';
        });
      } else {
        // Fallback tự động nếu máy ảo chưa đăng ký vân tay trong Settings
        _fallbackVirtualFingerprint();
      }
    } catch (e) {
      _fallbackVirtualFingerprint();
    }
  }

  void _fallbackVirtualFingerprint() {
    setState(() {
      _isBiometricVerified = true;
      _biometricStatus =
          'Đã xác thực Vân tay thành công (Chế độ Fallback Máy ảo)!';
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text(
          'Bước 1 hoàn tất: Đã xác thực vân tay cho ${_employee.MaNV} - ${_employee.HoTen}!',
        ),
      ),
    );
  }

  // ==================== BƯỚC 2: CHIA SẺ VỊ TRÍ GPS & TÍNH KHOẢNG CÁNH 50M ====================

  void _applyGpsByMode() {
    final officeLat = _selectedShift.ViDoCongTy;
    final officeLng = _selectedShift.KinhDoCongTy;

    if (_testAtOfficeMode) {
      // Giả lập tọa độ tại văn phòng cách đúng ~10.5m
      const double simulatedLatOffset = 0.0000945; // ~10.5 mét theo vĩ độ
      final empLat = officeLat + simulatedLatOffset;
      final empLng = officeLng;
      final dist = Geolocator.distanceBetween(
        empLat,
        empLng,
        officeLat,
        officeLng,
      );

      setState(() {
        _employeeLat = empLat;
        _employeeLng = empLng;
        _distanceMeters = double.parse(dist.toStringAsFixed(1));
        if ((_distanceMeters! - 10.5).abs() < 1.0) {
          _distanceMeters = 10.5;
        }
        _gpsMessage =
            'Hợp lệ: Khoảng cách ${_distanceMeters}m <= 50m (Đang bật Chế độ Test tại văn phòng)';
      });
    } else {
      // Giả lập đang ở ngoài khu vực công ty (> 50m) nếu chưa lấy GPS thật
      final empLat = officeLat + 0.0022; // ~245 mét
      final empLng = officeLng + 0.0015;
      final dist = Geolocator.distanceBetween(
        empLat,
        empLng,
        officeLat,
        officeLng,
      );
      setState(() {
        _employeeLat = empLat;
        _employeeLng = empLng;
        _distanceMeters = double.parse(dist.toStringAsFixed(1));
        _gpsMessage = 'Bạn đang ở ngoài khu vực văn phòng công ty!';
      });
    }
  }

  Future<void> _fetchRealEmployeeGps() async {
    setState(() {
      _isCheckingGps = true;
      _gpsMessage = 'Đang lấy tọa độ GPS thực tế từ cảm biến điện thoại...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Định vị GPS đang tắt.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Chưa cấp quyền vị trí GPS.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền GPS bị từ chối vĩnh viễn.');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;

      final dist = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        _selectedShift.ViDoCongTy,
        _selectedShift.KinhDoCongTy,
      );

      final roundedDist = double.parse(dist.toStringAsFixed(1));
      final isInside = roundedDist <= maxAllowedRadiusMeters;

      setState(() {
        _isCheckingGps = false;
        _testAtOfficeMode = false;
        _employeeLat = pos.latitude;
        _employeeLng = pos.longitude;
        _distanceMeters = roundedDist;
        _gpsMessage = isInside
            ? 'Vị trí GPS hợp lệ ($roundedDist m <= 50m)!'
            : 'Bạn đang ở ngoài khu vực văn phòng công ty! ($roundedDist m > 50m)';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingGps = false;
        _gpsMessage =
            'Không lấy được GPS thật trên máy ảo ($e). Hãy bật Switch "Chế độ Test tại văn phòng"!';
      });
    }
  }

  bool get _isGpsValid =>
      _distanceMeters != null && _distanceMeters! <= maxAllowedRadiusMeters;

  // ==================== BƯỚC 3: QUÉT MÃ QR, KHÓA DEVICE ID & TÍNH LƯƠNG REALTIME ====================

  Future<void> _processQrAttendance(String qrToken) async {
    setState(() {
      _fraudAlertMessage = null;
      _isCameraScannerOpen = false;
    });

    // 1. Kiểm tra đã xác thực vân tay (Bước 1) chưa
    if (!_isBiometricVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Vui lòng hoàn thành Bước 1: Xác thực Vân tay trước khi quét QR!',
          ),
        ),
      );
      return;
    }

    // 2. Kiểm tra khoảng cách GPS <= 50m (Bước 2)
    if (!_isGpsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Bạn đang ở ngoài khu vực văn phòng công ty!'),
        ),
      );
      return;
    }

    // 3. Kiểm tra tính hợp lệ của mã QR Động 15s
    if (!_repo.validateDynamicQr(qrToken)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Mã QR không hợp lệ hoặc đã hết hạn 15 giây!'),
        ),
      );
      return;
    }

    // 4. TÍNH NĂNG MỚI 2: Kiểm tra Khóa cứng DeviceID chống chấm công hộ trong ngày
    final String deviceIdToUse = _effectiveDeviceId;
    final BangChamCong? fraudRecord = _repo.checkDeviceIdFraudToday(
      maThietBiChamCong: deviceIdToUse,
      currentMaNV: _employee.MaNV,
    );

    if (fraudRecord != null) {
      const String fraudWarning =
          'Phát hiện gian lận: Thiết bị này đã được dùng để chấm công hộ nhân viên khác!';
      setState(() {
        _fraudAlertMessage =
            '$fraudWarning\n(Mã thiết bị "$deviceIdToUse" đã chấm công cho ${fraudRecord.MaNV} - ${fraudRecord.HoTenNV} hôm nay)';
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          content: Text(
            fraudWarning,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      _showFraudDialog(fraudWarning, fraudRecord, deviceIdToUse);
      return;
    }

    // 5. Hợp lệ -> Ghi nhận GioCheckIn hoặc GioCheckOut & Tự động tính lương Realtime
    final myRecords = _repo.getBangChamCongByMaNV(_employee.MaNV);
    final openRecord = myRecords
        .where((r) => r.GioCheckOut == null && r.TrangThai != 'VangMat')
        .firstOrNull;

    final currencyFmt = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    if (openRecord == null) {
      // Thực hiện CHECK-IN mới
      final created = _repo.checkIn(
        nhanVien: _employee,
        caLamViec: _selectedShift,
        khoangCachMet: _distanceMeters ?? 10.5,
        maThietBi: deviceIdToUse,
      );

      if (!mounted) return;
      await _showSuccessResultDialog(
        title: 'CHECK-IN THÀNH CÔNG!',
        message:
            'Nhân viên: ${created.MaNV} - ${created.HoTenNV}\n'
            'Ca làm việc: ${created.TenCa}\n'
            'Giờ Check-in: ${created.GioCheckIn} (${created.TrangThai})\n'
            'Khoảng cách GPS: ${created.KhoangCachMet}m (<= 50m)\n'
            'Thiết bị khóa cứng: ${created.MaThietBiChamCong}\n\n'
            'Hãy bấm Quét QR lần nữa để Check-out và tự động tính lương Realtime!',
      );
      setState(() {});
    } else {
      // Thực hiện CHECK-OUT & Tự động tính lương Realtime
      final updated = _repo.checkOut(
        openRecord.MaChamCong,
        _employee.LuongTheoGio,
        _selectedShift.HeSoLuong,
        khoangCachMet: _distanceMeters ?? 10.5,
        maThietBiChamCong: deviceIdToUse,
      );

      if (!mounted || updated == null) return;
      final tongLuongMoi = _repo.getTongLuongTamTinhNhanVien(_employee.MaNV);

      await _showSuccessResultDialog(
        title: 'CHECK-OUT & TÍNH LƯƠNG REALTIME!',
        message:
            'Nhân viên: ${updated.MaNV} - ${updated.HoTenNV}\n'
            'Ca: ${updated.TenCa}\n'
            'Giờ vào: ${updated.GioCheckIn} ➔ Giờ ra: ${updated.GioCheckOut}\n'
            'Số giờ làm ghi nhận: ${updated.SoGioLam} giờ\n'
            'Tiền công ca cộng thêm: +${currencyFmt.format(updated.TienCongNgay)}\n'
            'Tổng lương tạm tính mới: ${currencyFmt.format(tongLuongMoi)}',
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  void _showFraudDialog(
    String warningTitle,
    BangChamCong conflictRecord,
    String deviceId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'CẢNH BÁO CHỐNG GIAN LẬN',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '$warningTitle\n\n'
          '• Thiết bị vi phạm: $deviceId\n'
          '• Đã chấm công trước đó cho: ${conflictRecord.HoTenNV} (${conflictRecord.MaNV})\n'
          '• Lúc: ${conflictRecord.GioCheckIn} ngày ${conflictRecord.NgayLam}',
          style: const TextStyle(color: Color(0xFF7F1D1D), height: 1.4),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessResultDialog({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(height: 1.45)),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myRecords = _repo.getBangChamCongByMaNV(_employee.MaNV);
    final openRecord = myRecords
        .where((r) => r.GioCheckOut == null && r.TrangThai != 'VangMat')
        .firstOrNull;
    final activeQrToken = _repo.danhSachPhienChamCong.isNotEmpty
        ? _repo.danhSachPhienChamCong.first.MaQRDong
        : 'VKD_QR15S_DEFAULT';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chấm Công Bảo Mật Đa Tầng',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            Text(
              'Vân tay + GPS 50m + QR Động 15s + Khóa DeviceID',
              style: TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cảnh báo đỏ nếu phát hiện gian lận chấm công hộ bằng cùng 1 thiết bị
                  if (_fraudAlertMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.gpp_bad_rounded,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fraudAlertMessage!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ==================== BƯỚC 1: XÁC THỰC VÂN TAY / SINH TRẮC HỌC ====================
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _isBiometricVerified
                            ? Colors.green
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _isBiometricVerified
                                    ? Colors.green
                                    : primaryBlue,
                                child: Icon(
                                  _isBiometricVerified
                                      ? Icons.check_rounded
                                      : Icons.fingerprint_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bước 1: Xác Thực Sinh Trắc Học (Vân Tay)',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: primaryDark,
                                      ),
                                    ),
                                    Text(
                                      _biometricStatus,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _isBiometricVerified
                                            ? Colors.green.shade700
                                            : Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _isBiometricVerified
                                        ? Colors.green.shade700
                                        : primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _verifyBiometricFingerprint,
                                  icon: const Icon(
                                    Icons.fingerprint_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Quét Vân Tay',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _fallbackVirtualFingerprint,
                                  icon: const Icon(
                                    Icons.verified_user_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Fallback Máy Ảo',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () async {
                                final verified = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => FaceAuthScreen(
                                          targetUser: _employee,
                                          forAttendanceVerification: true,
                                        ),
                                      ),
                                    );
                                if (verified == true && mounted) {
                                  setState(() {
                                    _isBiometricVerified = true;
                                    _biometricStatus =
                                        'Đã xác thực bằng Khuôn mặt AI (Liveness > 0.5)!';
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.face_retouching_natural_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Hoặc Xác thực Khuôn mặt AI (Chức năng a)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ==================== BƯỚC 2: CHIA SẺ VỊ TRÍ GPS (BÁN KÍNH 50M) ====================
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: _isGpsValid ? Colors.green : Colors.redAccent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _isGpsValid
                                    ? Colors.green
                                    : Colors.redAccent,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bước 2: Kiểm Tra Khoảng Cách GPS (<= 50m)',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: primaryDark,
                                      ),
                                    ),
                                    Text(
                                      'So sánh vị trí nhân viên với tọa độ văn phòng công ty',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Switch "Chế độ Test tại văn phòng" giả lập khoảng cách = 10.5m
                          Material(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            child: SwitchListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                'Chế độ Test tại văn phòng (Giả lập 10.5m)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: primaryDark,
                                ),
                              ),
                              subtitle: const Text(
                                'Tắt Switch để test trường hợp ở xa > 50m bị chặn chấm công',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              value: _testAtOfficeMode,
                              activeThumbColor: primaryBlue,
                              onChanged: (val) {
                                setState(() {
                                  _testAtOfficeMode = val;
                                  _applyGpsByMode();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Hiển thị rõ số mét và tọa độ lên màn hình
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isGpsValid
                                  ? Colors.green.withValues(alpha: 0.08)
                                  : Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isGpsValid
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Khoảng cách tới công ty:',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_distanceMeters?.toStringAsFixed(1) ?? "--"}m (<= 50m)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                        color: _isGpsValid
                                            ? Colors.green.shade800
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 14),
                                Text(
                                  '• GPS Nhân viên: ${_employeeLat?.toStringAsFixed(6)}, ${_employeeLng?.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                                Text(
                                  '• GPS Công ty: ${_selectedShift.ViDoCongTy.toStringAsFixed(6)}, ${_selectedShift.KinhDoCongTy.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _gpsMessage,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: _isGpsValid
                                        ? Colors.green.shade800
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isCheckingGps
                                  ? null
                                  : _fetchRealEmployeeGps,
                              icon: const Icon(
                                Icons.my_location_rounded,
                                size: 18,
                              ),
                              label: Text(
                                _isCheckingGps
                                    ? 'Đang định vị GPS...'
                                    : 'Cập nhật GPS thực tế (Geolocator)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ==================== BƯỚC 3: QUÉT QR ĐỘNG + KHÓA DEVICE ID + TÍNH LƯƠNG REALTIME ====================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: primaryDark,
                                child: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bước 3: Quét QR & Khóa Cứng DeviceID',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: primaryDark,
                                      ),
                                    ),
                                    Text(
                                      'MaThietBiChamCong: $_effectiveDeviceId',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Switch test tình huống gian lận chấm công hộ bằng thiết bị của NV khác
                          Material(
                            color: _simulateFraudDeviceMode
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF8FAFC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _simulateFraudDeviceMode
                                    ? Colors.redAccent
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: SwitchListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                'Test phát hiện gian lận chấm công hộ (DeviceID)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: const Text(
                                'Giả lập dùng máy của NV002 (Lê Hoàng Nam) quét hộ cho Vưu Kiên Định',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              value: _simulateFraudDeviceMode,
                              activeThumbColor: Colors.redAccent,
                              onChanged: (val) {
                                setState(() {
                                  _simulateFraudDeviceMode = val;
                                  _fraudAlertMessage = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Khung Camera MobileScanner khi bật
                          if (_isCameraScannerOpen) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                height: 220,
                                width: double.infinity,
                                child: MobileScanner(
                                  onDetect: (capture) {
                                    final barcodes = capture.barcodes;
                                    if (barcodes.isNotEmpty) {
                                      final raw = barcodes.first.rawValue;
                                      if (raw != null && raw.isNotEmpty) {
                                        _processQrAttendance(raw);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isCameraScannerOpen =
                                          !_isCameraScannerOpen;
                                    });
                                  },
                                  icon: Icon(
                                    _isCameraScannerOpen
                                        ? Icons.videocam_off_outlined
                                        : Icons.camera_alt_outlined,
                                  ),
                                  label: Text(
                                    _isCameraScannerOpen
                                        ? 'Đóng Camera QR'
                                        : 'Mở Camera Quét QR',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Nút "Giả lập quét mã QR hợp lệ" để demo mượt trên máy ảo
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: openRecord == null
                                    ? primaryBlue
                                    : const Color(0xFFEA580C),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  _processQrAttendance(activeQrToken),
                              icon: const Icon(Icons.qr_code_2_rounded),
                              label: Text(
                                openRecord == null
                                    ? 'GIẢ LẬP QUÉT QR HỢP LỆ (CHECK-IN)'
                                    : 'QUÉT QR CHECK-OUT & TÍNH LƯƠNG',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
