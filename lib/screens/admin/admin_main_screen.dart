import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/nguoi_dung.dart';
import '../../models/ca_lam_viec.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';
import '../auth/login_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final NguoiDung? currentUser;

  const AdminMainScreen({super.key, this.currentUser});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final MockDataRepository _repo = MockDataRepository.instance;
  int _selectedIndex = 0;

  // Bộ lọc tìm kiếm cho Ca làm việc & Nhân viên
  final TextEditingController _searchCaController = TextEditingController();
  final TextEditingController _searchUserController = TextEditingController();
  String _searchCaQuery = '';
  String _searchUserQuery = '';
  String _selectedRoleFilter = 'TATCA';

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  final List<Map<String, String>> _danhSachPhongBan = const [
    {'ma': 'PB01', 'ten': 'Ban Quản Trị & CNTT'},
    {'ma': 'PB02', 'ten': 'Phòng Hành Chính - Nhân Sự'},
    {'ma': 'PB03', 'ten': 'Phòng Phát Triển Phần Mềm'},
    {'ma': 'PB04', 'ten': 'Phòng Kinh Doanh & Marketing'},
    {'ma': 'PB05', 'ten': 'Phòng Kế Toán - Tài Chính'},
  ];

  NguoiDung get _adminUser =>
      widget.currentUser ??
      SessionManager.instance.currentUser ??
      _repo.danhSachNguoiDung.first;

  @override
  void dispose() {
    _searchCaController.dispose();
    _searchUserController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await SessionManager.instance.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ==================== DIALOG / BOTTOM SHEET CRUD CA LÀM VIỆC ====================

  void _showCaLamViecFormModal({CaLamViec? editingCa}) {
    final isEditing = editingCa != null;
    final formKey = GlobalKey<FormState>();

    final maCaCtrl = TextEditingController(
      text: editingCa?.MaCa ?? 'CA0${_repo.danhSachCaLamViec.length + 1}',
    );
    final tenCaCtrl = TextEditingController(text: editingCa?.TenCa ?? '');
    final gioBatDauCtrl = TextEditingController(
      text: editingCa?.GioBatDau ?? '08:00',
    );
    final gioKetThucCtrl = TextEditingController(
      text: editingCa?.GioKetThuc ?? '17:00',
    );
    final heSoLuongCtrl = TextEditingController(
      text: (editingCa?.HeSoLuong ?? 1.0).toString(),
    );
    final viDoCtrl = TextEditingController(
      text: (editingCa?.ViDoCongTy ?? 10.801618).toString(),
    );
    final kinhDoCtrl = TextEditingController(
      text: (editingCa?.KinhDoCongTy ?? 106.714546).toString(),
    );
    final banKinhCtrl = TextEditingController(
      text: (editingCa?.BanKinhChoPhep ?? 150.0).toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'Cập Nhật Ca Làm Việc (${editingCa.MaCa})'
                              : 'Thêm Mới Ca Làm Việc',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: maCaCtrl,
                          enabled: !isEditing,
                          decoration: _buildInputDecoration(
                            'Mã Ca',
                            Icons.tag_rounded,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nhập mã ca'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: tenCaCtrl,
                          decoration: _buildInputDecoration(
                            'Tên Ca (VD: Ca Sáng)',
                            Icons.work_history_outlined,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nhập tên ca'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: gioBatDauCtrl,
                          decoration: _buildInputDecoration(
                            'Giờ bắt đầu (HH:mm)',
                            Icons.login_rounded,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nhập giờ vào'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: gioKetThucCtrl,
                          decoration: _buildInputDecoration(
                            'Giờ kết thúc (HH:mm)',
                            Icons.logout_rounded,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nhập giờ tan'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: heSoLuongCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration(
                            'Hệ số lương',
                            Icons.trending_up_rounded,
                          ),
                          validator: (v) {
                            final numVal = double.tryParse(v ?? '');
                            if (numVal == null || numVal <= 0) {
                              return 'Hệ số > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: banKinhCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration(
                            'Bán kính GPS (m)',
                            Icons.radar_rounded,
                          ),
                          validator: (v) {
                            final numVal = double.tryParse(v ?? '');
                            if (numVal == null || numVal <= 0) {
                              return 'Bán kính > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: viDoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration(
                            'Vĩ độ Công ty (Lat)',
                            Icons.location_on_outlined,
                          ),
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? 'Tọa độ sai'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: kinhDoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _buildInputDecoration(
                            'Kinh độ Công ty (Lng)',
                            Icons.explore_outlined,
                          ),
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? 'Tọa độ sai'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final newShift = CaLamViec(
                        MaCa: maCaCtrl.text.trim().toUpperCase(),
                        TenCa: tenCaCtrl.text.trim(),
                        GioBatDau: gioBatDauCtrl.text.trim(),
                        GioKetThuc: gioKetThucCtrl.text.trim(),
                        HeSoLuong:
                            double.tryParse(heSoLuongCtrl.text.trim()) ?? 1.0,
                        ViDoCongTy:
                            double.tryParse(viDoCtrl.text.trim()) ?? 10.801618,
                        KinhDoCongTy:
                            double.tryParse(kinhDoCtrl.text.trim()) ??
                            106.714546,
                        BanKinhChoPhep:
                            double.tryParse(banKinhCtrl.text.trim()) ?? 150.0,
                      );

                      setState(() {
                        if (isEditing) {
                          _repo.updateCaLamViec(editingCa.MaCa, newShift);
                        } else {
                          _repo.addCaLamViec(newShift);
                        }
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Đã cập nhật ca "${newShift.TenCa}" thành công!'
                                : 'Đã thêm mới ca "${newShift.TenCa}" thành công!',
                          ),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    },
                    icon: Icon(
                      isEditing ? Icons.save_rounded : Icons.add_circle_outline,
                    ),
                    label: Text(
                      isEditing ? 'LƯU CẬP NHẬT CA' : 'THÊM CA LÀM VIỆC',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteCaLamViec(CaLamViec ca) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(child: Text('Xác nhận xóa Ca làm việc')),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${ca.TenCa}" (Mã: ${ca.MaCa}) khỏi hệ thống không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _repo.deleteCaLamViec(ca.MaCa);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa ca làm việc "${ca.TenCa}"!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Xóa ngay'),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOG / BOTTOM SHEET CRUD NHÂN VIÊN ====================

  void _showNguoiDungFormModal({NguoiDung? editingUser}) {
    final isEditing = editingUser != null;
    final formKey = GlobalKey<FormState>();

    final maNvCtrl = TextEditingController(
      text: editingUser?.MaNV ?? 'NV00${_repo.danhSachNguoiDung.length + 1}',
    );
    final hoTenCtrl = TextEditingController(text: editingUser?.HoTen ?? '');
    final tenDangNhapCtrl = TextEditingController(
      text: editingUser?.TenDangNhap ?? '',
    );
    final matKhauCtrl = TextEditingController(
      text: editingUser?.MatKhau ?? '123',
    );
    final emailCtrl = TextEditingController(text: editingUser?.Email ?? '');
    final luongCtrl = TextEditingController(
      text: (editingUser?.LuongTheoGio ?? 65000.0).toInt().toString(),
    );
    final thietBiCtrl = TextEditingController(
      text: editingUser?.MaThietBi ?? 'ANDROID-DEVICE-NEW',
    );

    String selectedVaiTro = editingUser?.VaiTro ?? 'NHANVIEN';
    String selectedTenPhongBan =
        editingUser?.TenPhongBan ?? 'Phòng Phát Triển Phần Mềm';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Cập Nhật Nhân Sự (${editingUser.MaNV})'
                                  : 'Thêm Tài Khoản Nhân Viên Mới',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: maNvCtrl,
                              enabled: !isEditing,
                              decoration: _buildInputDecoration(
                                'Mã NV',
                                Icons.badge_outlined,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Nhập mã NV'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: hoTenCtrl,
                              decoration: _buildInputDecoration(
                                'Họ và tên nhân viên',
                                Icons.person_outline,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Nhập họ tên'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: tenDangNhapCtrl,
                              decoration: _buildInputDecoration(
                                'Tên đăng nhập',
                                Icons.account_circle_outlined,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Nhập username'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: matKhauCtrl,
                              decoration: _buildInputDecoration(
                                'Mật khẩu',
                                Icons.lock_outline,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Nhập mật khẩu'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          'Email nhận OTP',
                          Icons.email_outlined,
                        ),
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Email sai' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedVaiTro,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                'Phân quyền (Vai trò)',
                                Icons.security_rounded,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'NHANVIEN',
                                  child: Text(
                                    'NHANVIEN',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'QUANLY',
                                  child: Text(
                                    'QUANLY (HR)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'ADMIN',
                                  child: Text(
                                    'ADMIN',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedVaiTro = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: luongCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                'Lương/giờ (VNĐ)',
                                Icons.payments_outlined,
                              ),
                              validator: (v) =>
                                  double.tryParse(v ?? '') == null
                                  ? 'Nhập số'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _danhSachPhongBan.any(
                          (p) => p['ten'] == selectedTenPhongBan,
                        )
                            ? selectedTenPhongBan
                            : _danhSachPhongBan.first['ten'],
                        isExpanded: true,
                        decoration: _buildInputDecoration(
                          'Phòng ban trực thuộc',
                          Icons.business_outlined,
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
                            setModalState(() => selectedTenPhongBan = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: thietBiCtrl,
                        decoration: _buildInputDecoration(
                          'Mã thiết bị định danh (MaThietBi)',
                          Icons.phone_android_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final pbInfo = _danhSachPhongBan.firstWhere(
                            (p) => p['ten'] == selectedTenPhongBan,
                            orElse: () => _danhSachPhongBan[2],
                          );

                          final userObj = NguoiDung(
                            MaNV: maNvCtrl.text.trim(),
                            TenDangNhap: tenDangNhapCtrl.text.trim(),
                            MatKhau: matKhauCtrl.text.trim(),
                            HoTen: hoTenCtrl.text.trim(),
                            Email: emailCtrl.text.trim(),
                            VaiTro: selectedVaiTro,
                            MaPhongBan: pbInfo['ma']!,
                            TenPhongBan: pbInfo['ten']!,
                            LuongTheoGio:
                                double.tryParse(luongCtrl.text.trim()) ??
                                65000.0,
                            MaThietBi: thietBiCtrl.text.trim().isEmpty
                                ? 'ANDROID-DEVICE'
                                : thietBiCtrl.text.trim(),
                          );

                          setState(() {
                            if (isEditing) {
                              _repo.updateNguoiDung(editingUser.MaNV, userObj);
                            } else {
                              _repo.addNguoiDung(userObj);
                            }
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Đã cập nhật nhân viên "${userObj.HoTen}"!'
                                    : 'Đã thêm mới nhân viên "${userObj.HoTen}"!',
                              ),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        },
                        icon: Icon(
                          isEditing
                              ? Icons.save_rounded
                              : Icons.person_add_alt_1_rounded,
                        ),
                        label: Text(
                          isEditing
                              ? 'LƯU THÔNG TIN NHÂN VIÊN'
                              : 'THÊM TÀI KHOẢN NHÂN VIÊN',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteNguoiDung(NguoiDung user) {
    if (user.MaNV == '2380600509' || user.MaNV == 'AD001') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể xóa tài khoản cốt lõi của hệ thống (Admin / SV thực hiện 2380600509)!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_remove_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(child: Text('Xác nhận xóa Nhân viên')),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản "${user.HoTen}" (Mã NV: ${user.MaNV}) không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _repo.deleteNguoiDung(user.MaNV);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa nhân viên "${user.HoTen}"!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản Trị Hệ Thống (ADMIN)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'SV: 2380600509 - Vưu Kiên Định • Nhóm 8',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOverviewAndShiftsTab(),
          _buildShiftCrudTab(),
          _buildEmployeeCrudTab(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              onPressed: () => _showCaLamViecFormModal(),
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text(
                'Thêm Ca Làm Việc',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : _selectedIndex == 2
          ? FloatingActionButton.extended(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              onPressed: () => _showNguoiDungFormModal(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text(
                'Thêm Nhân Viên',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule_rounded),
            label: 'CRUD Ca Làm',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded),
            label: 'CRUD Nhân Sự',
          ),
        ],
      ),
    );
  }

  // ==================== TAB 0: TỔNG QUAN & THỐNG KÊ ====================

  Widget _buildOverviewAndShiftsTab() {
    final totalUsers = _repo.danhSachNguoiDung.length;
    final totalShifts = _repo.danhSachCaLamViec.length;
    final onTimeRate = _repo.getTyLeDungGioHomNay();
    final todayStr = _repo.formatDate(DateTime.now());
    final todayRecords = _repo.danhSachBangChamCong
        .where((c) => c.NgayLam == todayStr)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Admin
          Card(
            elevation: 0,
            color: primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryBlue,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
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
                          _adminUser.HoTen,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã NV: ${_adminUser.MaNV} • Quyền: ${_adminUser.VaiTro}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _adminUser.TenPhongBan,
                          style: const TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Chỉ Số Thống Kê Hệ Thống Hôm Nay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 12),

          // 3 Thẻ thống kê chính theo đúng yêu cầu
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Tổng Nhân Viên',
                  value: '$totalUsers',
                  subtitle: '${_danhSachPhongBan.length} phòng ban',
                  icon: Icons.groups_rounded,
                  color: primaryBlue,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Số Ca Làm Việc',
                  value: '$totalShifts',
                  subtitle: 'Đang kích hoạt',
                  icon: Icons.access_time_filled_rounded,
                  color: const Color(0xFF0D9488),
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thẻ tỷ lệ đi làm đúng giờ hôm nay
          Card(
            elevation: 1,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.green,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tỷ Lệ Đi Làm Đúng Giờ Hôm Nay',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            Text(
                              'Ngày $todayStr • Tổng ${todayRecords.length} lượt ghi nhận',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${onTimeRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (onTimeRate / 100.0).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Danh sách Phòng Ban & phím tắt quản lý
          const Text(
            'Cơ Cấu Phòng Ban Doanh Nghiệp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          ..._danhSachPhongBan.map((pb) {
            final countNV = _repo.danhSachNguoiDung
                .where((u) => u.MaPhongBan == pb['ma'] || u.TenPhongBan == pb['ten'])
                .length;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    pb['ma']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
                title: Text(
                  pb['ten']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Mã phòng ban: ${pb['ma']}'),
                trailing: Chip(
                  label: Text(
                    '$countNV nhân sự',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 1: CRUD CA LÀM VIỆC ====================

  Widget _buildShiftCrudTab() {
    final filteredShifts = _repo.danhSachCaLamViec.where((ca) {
      if (_searchCaQuery.trim().isEmpty) return true;
      final q = _searchCaQuery.trim().toLowerCase();
      return ca.TenCa.toLowerCase().contains(q) ||
          ca.MaCa.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Thanh tìm kiếm lọc theo TenCa
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _searchCaController,
            onChanged: (val) => setState(() => _searchCaQuery = val),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo Tên ca (Ca Sáng, Ca Chiều, Ca Hành Chính...)',
              prefixIcon: const Icon(Icons.search_rounded, color: primaryBlue),
              suffixIcon: _searchCaQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchCaController.clear();
                        setState(() => _searchCaQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredShifts.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy Ca làm việc nào phù hợp!',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: filteredShifts.length,
                  itemBuilder: (context, index) {
                    final ca = filteredShifts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: primaryDark,
                                  child: Text(
                                    ca.MaCa,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ca.TenCa,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Khung giờ: ${ca.GioBatDau} - ${ca.GioKetThuc} • Hệ số lương: x${ca.HeSoLuong}',
                                        style: const TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Sửa ca làm việc',
                                  onPressed: () =>
                                      _showCaLamViecFormModal(editingCa: ca),
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: primaryBlue,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Xóa ca làm việc',
                                  onPressed: () => _confirmDeleteCaLamViec(ca),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                _buildInfoBadge(
                                  Icons.location_on_outlined,
                                  'GPS: ${ca.ViDoCongTy.toStringAsFixed(4)}, ${ca.KinhDoCongTy.toStringAsFixed(4)}',
                                ),
                                _buildInfoBadge(
                                  Icons.radar_rounded,
                                  'Bán kính cho phép: ${ca.BanKinhChoPhep.toInt()}m',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.black54),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: CRUD TÀI KHOẢN NHÂN VIÊN ====================

  Widget _buildEmployeeCrudTab() {
    final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final filteredUsers = _repo.danhSachNguoiDung.where((u) {
      final matchesRole =
          _selectedRoleFilter == 'TATCA' || u.VaiTro == _selectedRoleFilter;
      if (!matchesRole) return false;

      if (_searchUserQuery.trim().isEmpty) return true;
      final q = _searchUserQuery.trim().toLowerCase();
      return u.HoTen.toLowerCase().contains(q) ||
          u.MaNV.toLowerCase().contains(q) ||
          u.TenPhongBan.toLowerCase().contains(q) ||
          u.TenDangNhap.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _searchUserController,
                onChanged: (val) => setState(() => _searchUserQuery = val),
                decoration: InputDecoration(
                  hintText: 'Tìm theo Họ tên, Mã NV (2380600509), Phòng ban...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: primaryBlue,
                  ),
                  suffixIcon: _searchUserQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchUserController.clear();
                            setState(() => _searchUserQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRoleFilterChip('TATCA', 'Tất cả'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip('NHANVIEN', 'Nhân viên'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip('QUANLY', 'Quản lý (HR)'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip('ADMIN', 'Admin'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final isMainStudent = user.MaNV == '2380600509';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isMainStudent
                      ? const BorderSide(color: primaryBlue, width: 1.5)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: user.VaiTro == 'ADMIN'
                                ? primaryDark
                                : user.VaiTro == 'QUANLY'
                                ? const Color(0xFF0D9488)
                                : primaryBlue,
                            child: Text(
                              user.VaiTro.substring(0, 2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.HoTen} (${user.MaNV})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.5,
                                    color: primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user.TenPhongBan} • Quyền: ${user.VaiTro}',
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sửa nhân viên',
                            onPressed: () =>
                                _showNguoiDungFormModal(editingUser: user),
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: primaryBlue,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Xóa nhân viên',
                            onPressed: () => _confirmDeleteNguoiDung(user),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _buildInfoBadge(
                            Icons.person_pin_outlined,
                            'User: ${user.TenDangNhap}',
                          ),
                          _buildInfoBadge(
                            Icons.payments_outlined,
                            'Lương: ${currencyFmt.format(user.LuongTheoGio)}/h',
                          ),
                          _buildInfoBadge(
                            Icons.email_outlined,
                            user.Email,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleFilterChip(String roleValue, String label) {
    final isSelected = _selectedRoleFilter == roleValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryBlue.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: isSelected ? primaryBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedRoleFilter = roleValue),
    );
  }
}
