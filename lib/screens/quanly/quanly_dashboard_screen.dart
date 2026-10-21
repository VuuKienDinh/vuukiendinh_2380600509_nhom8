import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/nguoi_dung.dart';
import '../../models/ca_lam_viec.dart';
import '../../models/bang_cham_cong.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';
import '../auth/login_screen.dart';
import 'may_cham_cong_qr_screen.dart';

class QuanLyDashboardScreen extends StatefulWidget {
  final NguoiDung? currentUser;

  const QuanLyDashboardScreen({super.key, this.currentUser});

  @override
  State<QuanLyDashboardScreen> createState() => _QuanLyDashboardScreenState();
}

class _QuanLyDashboardScreenState extends State<QuanLyDashboardScreen> {
  final MockDataRepository _repo = MockDataRepository.instance;
  int _selectedIndex = 0;

  // Bộ lọc cho Bảng chấm công
  String _selectedTrangThaiFilter = 'TatCa';
  final TextEditingController _searchCcController = TextEditingController();
  String _searchCcQuery = '';

  // Bộ lọc cho Đơn nghỉ phép
  String _selectedDonFilter = 'TatCa';

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  NguoiDung get _managerUser =>
      widget.currentUser ??
      SessionManager.instance.currentUser ??
      _repo.danhSachNguoiDung.firstWhere(
        (u) => u.VaiTro == 'QUANLY',
        orElse: () => _repo.danhSachNguoiDung.first,
      );

  @override
  void dispose() {
    _searchCcController.dispose();
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

  // ==================== MODAL THÊM / SỬA BẢNG CHẤM CÔNG ====================

  void _showBangChamCongModal({BangChamCong? editingRecord}) {
    final isEditing = editingRecord != null;
    final formKey = GlobalKey<FormState>();

    final employees = _repo.danhSachNguoiDung
        .where((u) => u.VaiTro == 'NHANVIEN')
        .toList();
    final shifts = _repo.danhSachCaLamViec;

    NguoiDung selectedEmployee = isEditing
        ? (_repo.danhSachNguoiDung
                  .where((u) => u.MaNV == editingRecord.MaNV)
                  .firstOrNull ??
              employees.first)
        : employees.firstWhere(
            (u) => u.MaNV == '2380600509',
            orElse: () => employees.first,
          );

    CaLamViec selectedShift = isEditing
        ? (shifts.where((c) => c.MaCa == editingRecord.MaCa).firstOrNull ??
              shifts.first)
        : shifts.first;

    final ngayLamCtrl = TextEditingController(
      text: editingRecord?.NgayLam ?? _repo.formatDate(DateTime.now()),
    );
    final gioInCtrl = TextEditingController(
      text: editingRecord?.GioCheckIn ?? '07:55:00',
    );
    final gioOutCtrl = TextEditingController(
      text: editingRecord?.GioCheckOut ?? '12:00:00',
    );
    final soGioCtrl = TextEditingController(
      text: (editingRecord?.SoGioLam ?? 4.0).toString(),
    );

    String selectedTrangThai = editingRecord?.TrangThai ?? 'DungGio';

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
                                  ? 'Sửa Chấm Công (${editingRecord.HoTenNV})'
                                  : 'Thêm Chấm Công Bù Cho Nhân Viên',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
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

                      // Chọn nhân viên
                      DropdownButtonFormField<NguoiDung>(
                        initialValue: selectedEmployee,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Nhân viên chấm công',
                          Icons.person_pin_rounded,
                        ),
                        items: employees.map((nv) {
                          return DropdownMenuItem<NguoiDung>(
                            value: nv,
                            child: Text(
                              '${nv.HoTen} (${nv.MaNV})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: isEditing
                            ? null
                            : (val) {
                                if (val != null) {
                                  setModalState(() => selectedEmployee = val);
                                }
                              },
                      ),
                      const SizedBox(height: 12),

                      // Chọn ca làm việc
                      DropdownButtonFormField<CaLamViec>(
                        initialValue: selectedShift,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Ca làm việc',
                          Icons.schedule_rounded,
                        ),
                        items: shifts.map((ca) {
                          return DropdownMenuItem<CaLamViec>(
                            value: ca,
                            child: Text(
                              '${ca.TenCa} (${ca.GioBatDau} - ${ca.GioKetThuc})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedShift = val;
                              gioInCtrl.text = '${val.GioBatDau}:00';
                              gioOutCtrl.text = '${val.GioKetThuc}:00';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ngayLamCtrl,
                              decoration: _inputDecoration(
                                'Ngày làm (YYYY-MM-DD)',
                                Icons.calendar_today_rounded,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                  ? 'Nhập ngày'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedTrangThai,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                'Trạng thái công',
                                Icons.flag_outlined,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'DungGio',
                                  child: Text(
                                    'Đúng giờ (DungGio)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'DiTre',
                                  child: Text(
                                    'Đi trễ (DiTre)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'VeSom',
                                  child: Text(
                                    'Về sớm (VeSom)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'VangMat',
                                  child: Text(
                                    'Vắng mặt (VangMat)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedTrangThai = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (selectedTrangThai != 'VangMat') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: gioInCtrl,
                                decoration: _inputDecoration(
                                  'Giờ Check-in',
                                  Icons.login_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: gioOutCtrl,
                                decoration: _inputDecoration(
                                  'Giờ Check-out',
                                  Icons.logout_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: soGioCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            'Số giờ làm việc tính công',
                            Icons.timer_outlined,
                          ),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null
                              ? 'Nhập số giờ hợp lệ'
                              : null,
                        ),
                      ],
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

                          final double hours = selectedTrangThai == 'VangMat'
                              ? 0.0
                              : (double.tryParse(soGioCtrl.text.trim()) ?? 4.0);
                          final double tienCong = selectedTrangThai == 'VangMat'
                              ? 0.0
                              : hours *
                                    selectedEmployee.LuongTheoGio *
                                    selectedShift.HeSoLuong;

                          setState(() {
                            if (isEditing) {
                              final updated = editingRecord.copyWith(
                                MaCa: selectedShift.MaCa,
                                TenCa: selectedShift.TenCa,
                                NgayLam: ngayLamCtrl.text.trim(),
                                GioCheckIn: selectedTrangThai == 'VangMat'
                                    ? null
                                    : gioInCtrl.text.trim(),
                                GioCheckOut: selectedTrangThai == 'VangMat'
                                    ? null
                                    : gioOutCtrl.text.trim(),
                                SoGioLam: hours,
                                TrangThai: selectedTrangThai,
                                TienCongNgay: tienCong,
                              );
                              _repo.updateBangChamCong(
                                editingRecord.MaChamCong,
                                updated,
                              );
                            } else {
                              _repo.addBangChamCongBu(
                                nhanVien: selectedEmployee,
                                caLamViec: selectedShift,
                                ngayLam: ngayLamCtrl.text.trim(),
                                gioCheckIn: gioInCtrl.text.trim(),
                                gioCheckOut: gioOutCtrl.text.trim(),
                                trangThai: selectedTrangThai,
                                soGioLam: hours,
                              );
                            }
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Đã cập nhật bản ghi chấm công của ${selectedEmployee.HoTen}!'
                                    : 'Đã thêm chấm công bù cho ${selectedEmployee.HoTen}!',
                              ),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        },
                        icon: Icon(
                          isEditing
                              ? Icons.save_rounded
                              : Icons.playlist_add_check_rounded,
                        ),
                        label: Text(
                          isEditing
                              ? 'LƯU CẬP NHẬT CHẤM CÔNG'
                              : 'XÁC NHẬN CHẤM CÔNG BÙ',
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

  void _confirmDeleteBangChamCong(BangChamCong cc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(child: Text('Xóa Bản Ghi Chấm Công Lỗi')),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bản ghi chấm công ngày ${cc.NgayLam} (${cc.TenCa}) của nhân viên "${cc.HoTenNV}" không?',
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
                _repo.deleteBangChamCong(cc.MaChamCong);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã xóa bản ghi chấm công của ${cc.HoTenNV}!',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Xóa bản ghi'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
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
    final pendingCount = _repo.danhSachDonNghiPhep
        .where((d) => d.TrangThaiDuyet == 'ChoDuyet')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản Lý Nhân Sự & Chấm Công (HR)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_managerUser.HoTen} • SV: 2380600509 - Vưu Kiên Định',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mở Máy Chấm Công QR Động 15s',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MayChamCongQrScreen(embedded: false),
                ),
              );
            },
          ),
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
          _buildAttendanceCrudTab(),
          _buildLeaveApprovalTab(),
          _buildQrSessionTab(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              onPressed: () => _showBangChamCongModal(),
              icon: const Icon(Icons.post_add_rounded),
              label: const Text(
                'Chấm Công Bù',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'CRUD Chấm Công',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.approval_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.approval_rounded),
            ),
            label: 'Duyệt Đơn Từ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.qr_code_2_rounded),
            label: 'Phát QR Động',
          ),
        ],
      ),
    );
  }

  // ==================== TAB 0: CRUD BẢNG CHẤM CÔNG ====================

  Widget _buildAttendanceCrudTab() {
    final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final filteredList = _repo.danhSachBangChamCong.where((cc) {
      final matchesStatus =
          _selectedTrangThaiFilter == 'TatCa' ||
          cc.TrangThai == _selectedTrangThaiFilter;
      if (!matchesStatus) return false;

      if (_searchCcQuery.trim().isEmpty) return true;
      final q = _searchCcQuery.trim().toLowerCase();
      return cc.HoTenNV.toLowerCase().contains(q) ||
          cc.MaNV.toLowerCase().contains(q) ||
          cc.TenCa.toLowerCase().contains(q) ||
          cc.NgayLam.contains(q);
    }).toList();

    return Column(
      children: [
        // Thanh tìm kiếm & bộ lọc trạng thái ("DungGio", "DiTre", "VangMat", "VeSom")
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            children: [
              TextField(
                controller: _searchCcController,
                onChanged: (val) => setState(() => _searchCcQuery = val),
                decoration: InputDecoration(
                  hintText:
                      'Tìm nhân viên (Vưu Kiên Định, 2380600509), ca, ngày...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: primaryBlue,
                  ),
                  suffixIcon: _searchCcQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCcController.clear();
                            setState(() => _searchCcQuery = '');
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
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip('TatCa', 'Tất cả (${_repo.danhSachBangChamCong.length})'),
                    const SizedBox(width: 8),
                    _buildStatusChip('DungGio', 'Đúng giờ (DungGio)'),
                    const SizedBox(width: 8),
                    _buildStatusChip('DiTre', 'Đi trễ (DiTre)'),
                    const SizedBox(width: 8),
                    _buildStatusChip('VangMat', 'Vắng mặt (VangMat)'),
                    const SizedBox(width: 8),
                    _buildStatusChip('VeSom', 'Về sớm (VeSom)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredList.isEmpty
              ? const Center(
                  child: Text(
                    'Không có bản ghi chấm công nào khớp với bộ lọc!',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final cc = filteredList[index];
                    final statusColor = _getStatusColor(cc.TrangThai);

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
                                  backgroundColor: statusColor.withValues(
                                    alpha: 0.14,
                                  ),
                                  child: Icon(
                                    _getStatusIcon(cc.TrangThai),
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${cc.HoTenNV} (${cc.MaNV})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.5,
                                          color: primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${cc.TenCa} • Ngày: ${cc.NgayLam}',
                                        style: const TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    cc.TrangThai,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Check-in: ${cc.GioCheckIn ?? "--:--:--"}  |  Check-out: ${cc.GioCheckOut ?? "--:--:--"}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Số giờ: ${cc.SoGioLam}h • Tiền công: ${currencyFmt.format(cc.TienCongNgay)}',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Sửa giờ / trạng thái công',
                                  onPressed: () => _showBangChamCongModal(
                                    editingRecord: cc,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_calendar_rounded,
                                    color: primaryBlue,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Xóa bản ghi chấm công lỗi',
                                  onPressed: () =>
                                      _confirmDeleteBangChamCong(cc),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                  ),
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

  Widget _buildStatusChip(String value, String label) {
    final isSelected = _selectedTrangThaiFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryBlue.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: isSelected ? primaryBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedTrangThaiFilter = value),
    );
  }

  Color _getStatusColor(String trangThai) {
    switch (trangThai) {
      case 'DungGio':
        return Colors.green.shade700;
      case 'DiTre':
        return Colors.orange.shade800;
      case 'VeSom':
        return Colors.purple.shade700;
      case 'VangMat':
      default:
        return Colors.redAccent;
    }
  }

  IconData _getStatusIcon(String trangThai) {
    switch (trangThai) {
      case 'DungGio':
        return Icons.check_circle_rounded;
      case 'DiTre':
        return Icons.access_time_filled_rounded;
      case 'VeSom':
        return Icons.directions_run_rounded;
      case 'VangMat':
      default:
        return Icons.cancel_rounded;
    }
  }

  // ==================== TAB 1: DUYỆT ĐƠN NGHỈ PHÉP & TĂNG CA ====================

  Widget _buildLeaveApprovalTab() {
    final filteredLeaves = _repo.danhSachDonNghiPhep.where((d) {
      if (_selectedDonFilter == 'TatCa') return true;
      return d.TrangThaiDuyet == _selectedDonFilter;
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDonFilterChip('TatCa', 'Tất cả đơn (${_repo.danhSachDonNghiPhep.length})'),
                const SizedBox(width: 8),
                _buildDonFilterChip('ChoDuyet', 'Chờ duyệt (ChoDuyet)'),
                const SizedBox(width: 8),
                _buildDonFilterChip('DaDuyet', 'Đã duyệt (DaDuyet)'),
                const SizedBox(width: 8),
                _buildDonFilterChip('TuChoi', 'Từ chối (TuChoi)'),
              ],
            ),
          ),
        ),
        Expanded(
          child: filteredLeaves.isEmpty
              ? const Center(
                  child: Text(
                    'Không có đơn từ nào trong mục này!',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLeaves.length,
                  itemBuilder: (context, index) {
                    final don = filteredLeaves[index];
                    final isPending = don.TrangThaiDuyet == 'ChoDuyet';

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${don.HoTenNV} (${don.MaNV})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                      color: primaryDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: don.TrangThaiDuyet == 'DaDuyet'
                                        ? Colors.green
                                        : don.TrangThaiDuyet == 'TuChoi'
                                        ? Colors.redAccent
                                        : Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    don.TrangThaiDuyet,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mã đơn: ${don.MaDon} • Loại đơn: ${_formatLoaiDon(don.LoaiDon)} (${don.LoaiDon})',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ngày áp dụng: ${don.NgayApDung}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Lý do: ${don.LyDo}',
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  if (don.TrangThaiDuyet != 'TuChoi')
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _repo.updateTrangThaiDon(
                                            don.MaDon,
                                            'TuChoi',
                                          );
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã từ chối đơn ${don.MaDon} của ${don.HoTenNV}!',
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Từ chối (TuChoi)',
                                        style: TextStyle(color: Colors.redAccent),
                                      ),
                                    ),
                                  if (don.TrangThaiDuyet != 'DaDuyet')
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _repo.updateTrangThaiDon(
                                            don.MaDon,
                                            'DaDuyet',
                                          );
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã phê duyệt đơn ${don.MaDon} của ${don.HoTenNV}!',
                                            ),
                                            backgroundColor:
                                                Colors.green.shade700,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                      ),
                                      label: Text(
                                        isPending
                                            ? 'Phê duyệt (DaDuyet)'
                                            : 'Duyệt lại',
                                      ),
                                    ),
                                ],
                              ),
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

  String _formatLoaiDon(String loaiDon) {
    switch (loaiDon) {
      case 'NghiPhep':
        return 'Nghỉ phép';
      case 'DiMuon':
        return 'Xin đi muộn';
      case 'TangCa':
        return 'Đăng ký tăng ca';
      default:
        return loaiDon;
    }
  }

  Widget _buildDonFilterChip(String value, String label) {
    final isSelected = _selectedDonFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryBlue.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: isSelected ? primaryBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedDonFilter = value),
    );
  }

  // ==================== TAB 2: PHÁT MÃ QR ĐỘNG 15 GIÂY ====================

  Widget _buildQrSessionTab() {
    return const MayChamCongQrScreen(embedded: true);
  }
}
