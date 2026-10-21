import 'package:flutter/material.dart';
import '../../models/nguoi_dung.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  final _formKey = GlobalKey<FormState>();

  final _maNvController = TextEditingController();
  final _hoTenController = TextEditingController();
  final _tenDangNhapController = TextEditingController();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  String _selectedPhongBan = 'Phòng Phát Triển Phần Mềm';
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  final List<Map<String, String>> _danhSachPhongBan = const [
    {'ma': 'PB03', 'ten': 'Phòng Phát Triển Phần Mềm'},
    {'ma': 'PB02', 'ten': 'Phòng Hành Chính - Nhân Sự'},
    {'ma': 'PB04', 'ten': 'Phòng Kinh Doanh & Marketing'},
    {'ma': 'PB05', 'ten': 'Phòng Kế Toán - Tài Chính'},
  ];

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final deviceId = await SessionManager.instance.getDeviceId();
      final pbMap = _danhSachPhongBan.firstWhere(
        (pb) => pb['ten'] == _selectedPhongBan,
        orElse: () => _danhSachPhongBan.first,
      );

      final newUser = NguoiDung(
        MaNV: _maNvController.text.trim(),
        TenDangNhap: _tenDangNhapController.text.trim(),
        MatKhau: _matKhauController.text,
        HoTen: _hoTenController.text.trim(),
        Email: _emailController.text.trim(),
        VaiTro: 'NHANVIEN',
        MaPhongBan: pbMap['ma']!,
        TenPhongBan: pbMap['ten']!,
        LuongTheoGio: 65000.0,
        MaThietBi: deviceId,
      );

      final createdUser = await ApiService.instance.register(newUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký thành công cho ${createdUser.HoTen}! Vui lòng xác thực OTP.',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpScreen(pendingUser: createdUser),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _maNvController.dispose();
    _hoTenController.dispose();
    _tenDangNhapController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Đăng Ký Tài Khoản Nhân Viên'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Tạo Tài Khoản Nhân Viên Mới',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hệ thống Chấm công Doanh nghiệp • Nhóm 8 - Đề số 2',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 22),

                        // Mã nhân viên
                        TextFormField(
                          controller: _maNvController,
                          decoration: _inputDecoration(
                            label: 'Mã nhân viên (VD: NV005)',
                            icon: Icons.badge_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập mã nhân viên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Họ và tên
                        TextFormField(
                          controller: _hoTenController,
                          decoration: _inputDecoration(
                            label: 'Họ và tên đầy đủ',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 3) {
                              return 'Vui lòng nhập họ và tên hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Tên đăng nhập
                        TextFormField(
                          controller: _tenDangNhapController,
                          decoration: _inputDecoration(
                            label: 'Tên đăng nhập',
                            icon: Icons.account_circle_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 3) {
                              return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Email công ty / cá nhân
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            label: 'Địa chỉ Email nhận OTP',
                            icon: Icons.email_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập địa chỉ Email';
                            }
                            if (!_isValidEmail(val)) {
                              return 'Định dạng Email không hợp lệ (VD: ten@domain.com)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Phòng ban
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPhongBan,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            label: 'Phòng ban công tác',
                            icon: Icons.business_outlined,
                          ),
                          items: _danhSachPhongBan.map((pb) {
                            return DropdownMenuItem<String>(
                              value: pb['ten'],
                              child: Text(
                                pb['ten']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPhongBan = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Mật khẩu
                        TextFormField(
                          controller: _matKhauController,
                          obscureText: _obscurePass,
                          decoration: _inputDecoration(
                            label: 'Mật khẩu',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscurePass = !_obscurePass);
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 3) {
                              return 'Mật khẩu phải từ 3 ký tự trở lên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Xác nhận mật khẩu
                        TextFormField(
                          controller: _xacNhanMatKhauController,
                          obscureText: _obscureConfirm,
                          decoration: _inputDecoration(
                            label: 'Xác nhận mật khẩu',
                            icon: Icons.verified_user_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                );
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val != _matKhauController.text) {
                              return 'Mật khẩu xác nhận không khớp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Nút Đăng ký
                        SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _handleRegister,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(
                              _isSubmitting
                                  ? 'ĐANG XỬ LÝ...'
                                  : 'ĐĂNG KÝ TÀI KHOẢN',
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }
}
