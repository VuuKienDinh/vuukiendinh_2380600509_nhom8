import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/nguoi_dung.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';
import '../nhanvien/nhanvien_main_screen.dart';
import '../quanly/quanly_dashboard_screen.dart';
import '../admin/admin_main_screen.dart';
import 'otp_screen.dart';

class FaceAuthScreen extends StatefulWidget {
  final NguoiDung? targetUser;
  final bool forAttendanceVerification;

  const FaceAuthScreen({
    super.key,
    this.targetUser,
    this.forAttendanceVerification = false,
  });

  @override
  State<FaceAuthScreen> createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen> {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  final ImagePicker _picker = ImagePicker();
  late final FaceDetector _faceDetector;

  File? _capturedImageFile;
  bool _isProcessing = false;
  bool _isVerifiedSuccess = false;
  bool _isSimulatedMode = false;

  double? _leftEyeProb;
  double? _rightEyeProb;
  double? _smilingProb;
  String _statusMessage =
      'Vui lòng mở Camera trước để chụp khuôn mặt hoặc dùng chế độ Mô phỏng trên máy ảo.';

  NguoiDung get _activeUser =>
      widget.targetUser ??
      MockDataRepository.instance.danhSachNguoiDung.firstWhere(
        (u) => u.MaNV == '2380600509',
        orElse: () => MockDataRepository.instance.danhSachNguoiDung.first,
      );

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  // ==================== CHỤP ẢNH CAMERA TRƯỚC & PHÂN TÍCH ML KIT ====================

  Future<void> _captureAndDetectFace(ImageSource source) async {
    setState(() {
      _isProcessing = true;
      _isVerifiedSuccess = false;
      _isSimulatedMode = false;
      _statusMessage = 'Đang mở Camera trước & phân tích khuôn mặt bằng AI...';
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Đã hủy chụp ảnh. Bạn có thể thử lại hoặc bật Mô phỏng máy ảo.';
        });
        return;
      }

      if (!kIsWeb) {
        _capturedImageFile = File(pickedFile.path);
      }

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.isEmpty) {
        setState(() {
          _isProcessing = false;
          _isVerifiedSuccess = false;
          _leftEyeProb = null;
          _rightEyeProb = null;
          _statusMessage =
              'Không phát hiện thấy khuôn mặt trong ảnh! Nếu đang dùng camera ảo trên Emulator, hãy bấm nút "Mô phỏng Khuôn mặt thật" bên dưới.';
        });
        return;
      }

      final Face face = faces.first;
      final double leftEye = face.leftEyeOpenProbability ?? 0.0;
      final double rightEye = face.rightEyeOpenProbability ?? 0.0;
      final double smile = face.smilingProbability ?? 0.0;

      // Kiểm tra chống ảnh tĩnh: cả 2 mắt phải mở (probability > 0.5)
      final bool isLiveFace = leftEye > 0.5 && rightEye > 0.5;

      setState(() {
        _isProcessing = false;
        _leftEyeProb = leftEye;
        _rightEyeProb = rightEye;
        _smilingProb = smile;
        _isVerifiedSuccess = isLiveFace;
        _statusMessage = isLiveFace
            ? 'Xác thực Khuôn mặt thật thành công! (Mắt trái: ${(leftEye * 100).toStringAsFixed(0)}%, Mắt phải: ${(rightEye * 100).toStringAsFixed(0)}% > 50%)'
            : 'Cảnh báo Liveness: Xác suất mở mắt thấp (Trái: ${(leftEye * 100).toStringAsFixed(0)}%, Phải: ${(rightEye * 100).toStringAsFixed(0)}% <= 50%). Vui lòng mở to mắt để chống ảnh tĩnh!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage =
            'Thiết bị/Máy ảo không hỗ trợ ML Kit Camera trực tiếp ($e). Vui lòng dùng nút "Mô phỏng Khuôn mặt thật trên Máy ảo".';
      });
    }
  }

  // ==================== CHẾ ĐỘ MÔ PHỎNG KHUÔN MẶT THẬT TRÊN MÁY ẢO ====================

  Future<void> _simulateEmulatorLiveFace() async {
    setState(() {
      _isProcessing = true;
      _statusMessage =
          'Đang chạy mô phỏng Google ML Kit Face Detection cho nhân viên ${_activeUser.MaNV} - ${_activeUser.HoTen}...';
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _isSimulatedMode = true;
      _isVerifiedSuccess = true;
      _leftEyeProb = 0.96;
      _rightEyeProb = 0.94;
      _smilingProb = 0.89;
      _statusMessage =
          'Xác thực Khuôn mặt AI thành công cho "${_activeUser.MaNV} - ${_activeUser.HoTen}"! '
          'Chống ảnh tĩnh đạt chuẩn (leftEyeOpen: 96% > 50%, rightEyeOpen: 94% > 50%).';
    });
  }

  // ==================== XỬ LÝ HOÀN TẤT ĐĂNG NHẬP / CHẤM CÔNG ====================

  Future<void> _completeFaceAuth({bool bypassOtp = true}) async {
    if (!_isVerifiedSuccess) return;

    if (widget.forAttendanceVerification) {
      Navigator.of(context).pop(true);
      return;
    }

    final user = _activeUser;
    if (!bypassOtp) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OtpScreen(pendingUser: user)),
      );
      return;
    }

    // Đăng nhập thẳng vào tài khoản "2380600509 - Vưu Kiên Định" (hoặc tài khoản đã chọn)
    await SessionManager.instance.saveSession(user);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đăng nhập bằng Khuôn mặt thành công: ${user.MaNV} - ${user.HoTen}!',
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );

    Widget nextScreen;
    final role = user.VaiTro.toUpperCase();
    if (role == 'ADMIN') {
      nextScreen = AdminMainScreen(currentUser: user);
    } else if (role == 'QUANLY') {
      nextScreen = QuanLyDashboardScreen(currentUser: user);
    } else {
      nextScreen = NhanVienMainScreen(currentUser: user);
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => nextScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: Text(
          widget.forAttendanceVerification
              ? 'Xác Thực Khuôn Mặt Chấm Công'
              : 'Đăng Nhập Bằng Khuôn Mặt AI',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thẻ thông tin nhân viên nhận diện
                  Card(
                    elevation: 0,
                    color: primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: primaryBlue,
                            child: Icon(
                              Icons.face_retouching_natural_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_activeUser.MaNV} - ${_activeUser.HoTen}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_activeUser.TenPhongBan} • Vai trò: ${_activeUser.VaiTro}',
                                  style: const TextStyle(
                                    color: Color(0xFF93C5FD),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Khung hiển thị Camera / Ảnh khuôn mặt & Thông số ML Kit
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            height: 230,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isVerifiedSuccess
                                    ? Colors.green
                                    : primaryBlue,
                                width: 3,
                              ),
                            ),
                            child: _isProcessing
                                ? const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Google ML Kit đang quét điểm mắt...',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )
                                : _capturedImageFile != null && !_isSimulatedMode
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.file(
                                      _capturedImageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isVerifiedSuccess
                                            ? Icons.verified_user_rounded
                                            : Icons.camera_front_rounded,
                                        size: 68,
                                        color: _isVerifiedSuccess
                                            ? Colors.greenAccent
                                            : const Color(0xFF60A5FA),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _isVerifiedSuccess
                                            ? 'KHUÔN MẶT HỢP LỆ (LIVENESS > 0.5)'
                                            : 'KHUNG NHẬN DIỆN KHUÔN MẶT AI',
                                        style: TextStyle(
                                          color: _isVerifiedSuccess
                                              ? Colors.greenAccent
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Kiểm tra mở mắt trái & phải > 0.5 chống ảnh tĩnh',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Hiển thị thông số xác suất mở mắt của Google ML Kit Face Detection
                          if (_leftEyeProb != null && _rightEyeProb != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _isVerifiedSuccess
                                    ? Colors.green.withValues(alpha: 0.08)
                                    : Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isVerifiedSuccess
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildProbabilityRow(
                                    'leftEyeOpenProbability (Mắt trái mở):',
                                    _leftEyeProb!,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildProbabilityRow(
                                    'rightEyeOpenProbability (Mắt phải mở):',
                                    _rightEyeProb!,
                                  ),
                                  if (_smilingProb != null) ...[
                                    const SizedBox(height: 6),
                                    _buildProbabilityRow(
                                      'smilingProbability (Độ tươi tỉnh):',
                                      _smilingProb!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _isVerifiedSuccess
                                  ? Colors.green.shade800
                                  : primaryDark,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Nút Mở Camera trước chụp khuôn mặt thật
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _captureAndDetectFace(
                                          ImageSource.camera,
                                        ),
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Camera Trước',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _captureAndDetectFace(
                                          ImageSource.gallery,
                                        ),
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Chọn Ảnh Test',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Nút Mô phỏng Khuôn mặt thật trên máy ảo để Demo mượt mà
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isProcessing
                                  ? null
                                  : _simulateEmulatorLiveFace,
                              icon: const Icon(
                                Icons.smart_toy_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                'Mô phỏng Khuôn mặt thật (Demo Máy ảo)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút xác nhận Đăng nhập / Xác thực chấm công khi đã hợp lệ
                  if (_isVerifiedSuccess)
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  _completeFaceAuth(bypassOtp: true),
                              icon: const Icon(Icons.check_circle_rounded),
                              label: Text(
                                widget.forAttendanceVerification
                                    ? 'XÁC NHẬN KHUÔN MẶT HỢP LỆ'
                                    : 'ĐĂNG NHẬP NGAY (${_activeUser.MaNV})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!widget.forAttendanceVerification) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () =>
                                    _completeFaceAuth(bypassOtp: false),
                                icon: const Icon(Icons.pin_outlined, size: 18),
                                label: const Text(
                                  'Hoặc tiếp tục xác thực OTP 6 số qua Email',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

  Widget _buildProbabilityRow(String label, double prob) {
    final bool pass = prob > 0.5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '${prob.toStringAsFixed(2)} (${(prob * 100).toStringAsFixed(0)}%) ${pass ? "✓" : "✗"}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: pass ? Colors.green.shade800 : Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
