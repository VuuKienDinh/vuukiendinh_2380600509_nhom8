import 'package:flutter/material.dart';
import '../../models/nguoi_dung.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_repository.dart';
import 'face_auth_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  final _formKey = GlobalKey<FormState>();
  final _tenDangNhapController = TextEditingController(text: '2380600509');
  final _matKhauController = TextEditingController(text: '123');

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await ApiService.instance.login(
        _tenDangNhapController.text.trim(),
        _matKhauController.text,
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sai tên đăng nhập hoặc mật khẩu! Vui lòng kiểm tra lại.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Chuyển sang màn hình nhập mã OTP 6 số
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(pendingUser: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng nhập: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFaceLogin() async {
    final currentInput = _tenDangNhapController.text.trim();
    final NguoiDung targetUser =
        MockDataRepository.instance.findUserByUsernameOrId(
          currentInput.isEmpty ? '2380600509' : currentInput,
        ) ??
        MockDataRepository.instance.danhSachNguoiDung.firstWhere(
          (u) => u.MaNV == '2380600509',
        );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FaceAuthScreen(
          targetUser: targetUser,
          forAttendanceVerification: false,
        ),
      ),
    );
  }

  void _fillDemoAccount({
    required String username,
    required String password,
    required String label,
  }) {
    setState(() {
      _tenDangNhapController.text = username;
      _matKhauController.text = password;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: primaryDark,
        content: Text('Đã chọn nhanh tài khoản $label ($username / $password)'),
      ),
    );
  }

  @override
  void dispose() {
    _tenDangNhapController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  // Header thương hiệu doanh nghiệp
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryDark, primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.fact_check_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'HỆ THỐNG CHẤM CÔNG THÔNG MINH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Nhóm 8 - Đề số 2 • SV: 2380600509 - Vưu Kiên Định',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFBFDBFE),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Card Form Đăng nhập chính (Bo góc 16px)
                  Card(
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
                              'Đăng Nhập Tài Khoản',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Ô nhập Tên đăng nhập
                            TextFormField(
                              controller: _tenDangNhapController,
                              decoration: InputDecoration(
                                labelText: 'Tên đăng nhập / Mã NV',
                                hintText: 'Nhập mã nhân viên hoặc username',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: primaryBlue,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập tên đăng nhập';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Ô nhập Mật khẩu
                            TextFormField(
                              controller: _matKhauController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: primaryBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),

                            // Nút Đăng nhập chính
                            SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handleLogin,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  _isLoading ? 'ĐANG KIỂM TRA...' : 'ĐĂNG NHẬP',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Nút Đăng nhập bằng Khuôn mặt
                            SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryDark,
                                  side: const BorderSide(
                                    color: primaryBlue,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handleFaceLogin,
                                icon: const Icon(
                                  Icons.face_retouching_natural_rounded,
                                  color: primaryBlue,
                                ),
                                label: const Text(
                                  'Đăng nhập bằng Khuôn mặt',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card 3 nút chọn nhanh tài khoản Test để tiện Demo (Bo góc 16px)
                  Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.flash_on_rounded,
                                color: primaryBlue,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Chọn nhanh tài khoản Test (Demo 1 chạm):',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildQuickDemoButton(
                            title: 'Nhân viên Vưu Kiên Định',
                            subtitle: 'Tài khoản: 2380600509 / 123',
                            badge: 'NHANVIEN',
                            color: primaryBlue,
                            icon: Icons.badge_rounded,
                            onTap: () => _fillDemoAccount(
                              username: '2380600509',
                              password: '123',
                              label: 'Nhân viên Vưu Kiên Định',
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildQuickDemoButton(
                            title: 'Quản lý HR',
                            subtitle: 'Tài khoản: ql01 / 123',
                            badge: 'QUANLY',
                            color: const Color(0xFF0D9488),
                            icon: Icons.manage_accounts_rounded,
                            onTap: () => _fillDemoAccount(
                              username: 'ql01',
                              password: '123',
                              label: 'Quản lý HR',
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildQuickDemoButton(
                            title: 'Quản trị viên (Admin)',
                            subtitle: 'Tài khoản: admin / 123',
                            badge: 'ADMIN',
                            color: primaryDark,
                            icon: Icons.admin_panel_settings_rounded,
                            onTap: () => _fillDemoAccount(
                              username: 'admin',
                              password: '123',
                              label: 'Admin',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Liên kết chuyển sang màn hình Đăng ký tài khoản nhân viên
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản nhân viên?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Đăng ký qua Email ngay',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDemoButton({
    required String title,
    required String subtitle,
    required String badge,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: primaryDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
