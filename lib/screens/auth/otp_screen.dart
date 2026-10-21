import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/nguoi_dung.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';
import '../admin/admin_main_screen.dart';
import '../quanly/quanly_dashboard_screen.dart';
import '../nhanvien/nhanvien_main_screen.dart';

class OtpScreen extends StatefulWidget {
  final NguoiDung pendingUser;

  const OtpScreen({super.key, required this.pendingUser});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _countdownTimer;
  int _secondsRemaining = 60;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Hiển thị SnackBar báo mã OTP giả lập là "123456" ngay sau khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMockOtpSnackBar();
    });
  }

  void _showMockOtpSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryDark,
        duration: const Duration(seconds: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: Color(0xFF60A5FA)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mã OTP giả lập gửi tới ${widget.pendingUser.Email} là: ${MockDataRepository.defaultMockOtp}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'ĐIỀN NHANH',
          textColor: const Color(0xFF60A5FA),
          onPressed: _fillMockOtp,
        ),
      ),
    );
  }

  void _fillMockOtp() {
    const otp = MockDataRepository.defaultMockOtp;
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = otp[i];
    }
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _enteredOtp => _controllers.map((c) => c.text.trim()).join();

  Future<void> _handleVerifyOtp() async {
    final otpCode = _enteredOtp;
    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ 6 chữ số mã xác thực OTP!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final isValid = await ApiService.instance.verifyOtp(
        widget.pendingUser.Email,
        otpCode,
      );

      if (!mounted) return;

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mã OTP không chính xác! (Gợi ý mã giả lập: 123456)',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isVerifying = false);
        return;
      }

      // Lưu phiên đăng nhập vào SessionManager
      await SessionManager.instance.saveSession(widget.pendingUser);

      if (!mounted) return;

      // Điều hướng dựa theo VaiTro: ADMIN, QUANLY, NHANVIEN
      final String vaiTro = widget.pendingUser.VaiTro.trim().toUpperCase();
      Widget destinationScreen;

      if (vaiTro == 'ADMIN') {
        destinationScreen = AdminMainScreen(currentUser: widget.pendingUser);
      } else if (vaiTro == 'QUANLY') {
        destinationScreen = QuanLyDashboardScreen(
          currentUser: widget.pendingUser,
        );
      } else {
        // Mặc định hoặc VaiTro == "NHANVIEN"
        destinationScreen = NhanVienMainScreen(currentUser: widget.pendingUser);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destinationScreen),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xác thực OTP: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Xác Thực Bảo Mật OTP'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          size: 38,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nhập Mã Xác Thực OTP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mã xác thực 6 chữ số đã được gửi tới Email:\n${widget.pendingUser.Email}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Tài khoản: ${widget.pendingUser.HoTen} (${widget.pendingUser.VaiTro})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6 ô nhập mã OTP tự động co giãn (Expanded) không bao giờ tràn
                      Row(
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: SizedBox(
                                height: 54,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: primaryDark,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                    if (_enteredOtp.length == 6) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Nút điền nhanh OTP giả lập 123456
                      TextButton.icon(
                        onPressed: _fillMockOtp,
                        icon: const Icon(Icons.bolt_rounded, size: 18),
                        label: const Text('Điền nhanh OTP mẫu (123456)'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Bộ đếm ngược 60 giây
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: Colors.black54,
                          ),
                          Text(
                            _secondsRemaining > 0
                                ? 'Mã hết hạn sau: ${_secondsRemaining}s'
                                : 'Mã OTP đã hết hạn!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _secondsRemaining > 10
                                  ? primaryDark
                                  : Colors.redAccent,
                            ),
                          ),
                          if (_secondsRemaining == 0)
                            TextButton(
                              onPressed: () {
                                _startCountdown();
                                _showMockOtpSnackBar();
                              },
                              child: const Text('Gửi lại mã'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Nút Xác nhận OTP
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isVerifying ? null : _handleVerifyOtp,
                          icon: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.verified_user_rounded),
                          label: Text(
                            _isVerifying
                                ? 'ĐANG XÁC THỰC...'
                                : 'XÁC NHẬN MÃ OTP',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
