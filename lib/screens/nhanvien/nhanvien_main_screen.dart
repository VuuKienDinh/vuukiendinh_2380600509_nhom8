import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/nguoi_dung.dart';
import '../../models/ca_lam_viec.dart';
import '../../services/mock_data_repository.dart';
import '../../services/session_manager.dart';
import '../auth/face_auth_screen.dart';
import '../auth/login_screen.dart';
import 'cham_cong_qr_screen.dart';
import 'don_nghi_phep_screen.dart';

class NhanVienMainScreen extends StatefulWidget {
  final NguoiDung? currentUser;

  const NhanVienMainScreen({super.key, this.currentUser});

  @override
  State<NhanVienMainScreen> createState() => _NhanVienMainScreenState();
}

class _NhanVienMainScreenState extends State<NhanVienMainScreen> {
  final MockDataRepository _repo = MockDataRepository.instance;
  int _selectedIndex = 0;
  late CaLamViec _selectedShift;
  String _historyStatusFilter = 'TatCa';

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _selectedShift = _repo.danhSachCaLamViec.first;
  }

  NguoiDung get _employee =>
      widget.currentUser ??
      SessionManager.instance.currentUser ??
      _repo.danhSachNguoiDung.firstWhere(
        (u) => u.MaNV == '2380600509',
        orElse: () => _repo.danhSachNguoiDung.last,
      );

  Future<void> _handleLogout() async {
    await SessionManager.instance.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _performQuickCheckIn() {
    final record = _repo.checkIn(
      nhanVien: _employee,
      caLamViec: _selectedShift,
      khoangCachMet: 16.8,
      maThietBi: _employee.MaThietBi,
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Check-in thành công ca ${record.TenCa} lúc ${record.GioCheckIn} (${record.TrangThai})!',
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _performQuickCheckOut(String maChamCong) {
    final updated = _repo.checkOut(
      maChamCong,
      _employee.LuongTheoGio,
      _selectedShift.HeSoLuong,
    );
    if (updated != null) {
      setState(() {});
      final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Check-out thành công lúc ${updated.GioCheckOut}! Tiền công cộng thêm: ${currencyFmt.format(updated.TienCongNgay)}',
          ),
          backgroundColor: primaryBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shifts = _repo.danhSachCaLamViec;
    if (!shifts.contains(_selectedShift) && shifts.isNotEmpty) {
      _selectedShift = shifts.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_employee.MaNV} - ${_employee.HoTen}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_employee.TenPhongBan} • ${_employee.VaiTro}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đơn nghỉ phép & Tăng ca',
            icon: const Icon(Icons.edit_document),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DonNghiPhepScreen(
                    currentUser: _employee,
                    onDataChanged: () => setState(() {}),
                  ),
                ),
              );
              setState(() {});
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
          _buildEmployeeOverviewAndCheckInTab(),
          _buildMyAttendanceHistoryTab(),
          DonNghiPhepScreen(
            currentUser: _employee,
            embedded: true,
            onDataChanged: () => setState(() {}),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 3,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint_rounded),
            label: 'Chấm Công & Lương',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Lịch Sử Công',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Đơn Nghỉ Phép',
          ),
        ],
      ),
    );
  }

  // ==================== TAB 0: THẺ NHÂN VIÊN & LƯƠNG + CHẤM CÔNG ====================

  Widget _buildEmployeeOverviewAndCheckInTab() {
    final myRecords = _repo.getBangChamCongByMaNV(_employee.MaNV);
    final openRecord = myRecords
        .where((r) => r.GioCheckOut == null && r.TrangThai != 'VangMat')
        .firstOrNull;
    final tongSoNgayCong = _repo.getTongSoCongNhanVien(_employee.MaNV);
    final tongLuongTamTinh = _repo.getTongLuongTamTinhNhanVien(_employee.MaNV);
    final myLeaves = _repo.getDonNghiPhepByMaNV(_employee.MaNV);
    final pendingLeavesCount = myLeaves
        .where((d) => d.TrangThaiDuyet == 'ChoDuyet')
        .length;

    final currencyFmt = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ thông tin nhân viên "2380600509 - Vưu Kiên Định" với Gradient sang trọng
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF60A5FA),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 26,
                        backgroundColor: primaryBlue,
                        child: Icon(
                          Icons.person_pin_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_employee.MaNV} - ${_employee.HoTen}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_employee.TenPhongBan} (${_employee.MaPhongBan})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 13,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _employee.Email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white24, height: 1),
                ),

                // Tổng số ngày công trong tháng & Tổng lương tạm tính (VNĐ)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Color(0xFF93C5FD),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Ngày công tháng',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$tongSoNgayCong công',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF60A5FA).withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 14,
                                  color: Color(0xFFBFDBFE),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Tổng lương tạm tính',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFFBFDBFE),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currencyFmt.format(tongLuongTamTinh),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Khu vực Chấm công theo Ca làm việc (Card bo góc 16px, đã fix triệt để lỗi tràn Dropdown)
          Card(
            elevation: 1.5,
            shadowColor: Colors.black12,
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chấm Công Theo Ca Làm Việc',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            Text(
                              'Chọn ca làm việc để thực hiện Check-in / Check-out',
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
                  const SizedBox(height: 16),

                  // DropdownButtonFormField có isExpanded: true chống tràn 100%
                  DropdownButtonFormField<CaLamViec>(
                    initialValue: _selectedShift,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Chọn Ca làm việc',
                      prefixIcon: const Icon(
                        Icons.access_time_filled_rounded,
                        color: primaryBlue,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                    ),
                    items: _repo.danhSachCaLamViec.map((ca) {
                      return DropdownMenuItem<CaLamViec>(
                        value: ca,
                        child: Text(
                          '${ca.TenCa} (${ca.GioBatDau} - ${ca.GioKetThuc} • x${ca.HeSoLuong})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryDark,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedShift = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nút chính: Mở màn hình Chấm Công Bảo Mật Đa Tầng
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChamCongQrScreen(
                              currentUser: _employee,
                              initialShift: _selectedShift,
                            ),
                          ),
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      icon: const Icon(
                        Icons.verified_user_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'CHẤM CÔNG ĐA TẦNG (VÂN TAY • GPS • QR 15S)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nút Check-in / Check-out nhanh 1 chạm
                  if (openRecord == null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _performQuickCheckIn,
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: const Text(
                          'CHECK-IN NHANH 1 CHẠM',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _performQuickCheckOut(openRecord.MaChamCong),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          'CHECK-OUT NHANH (${openRecord.TenCa})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Nút mở màn hình Xác thực Khuôn mặt AI
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        side: const BorderSide(color: primaryBlue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final verified = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => FaceAuthScreen(
                              targetUser: _employee,
                              forAttendanceVerification: true,
                            ),
                          ),
                        );
                        if (verified == true && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'Đã xác thực Khuôn mặt thật (Liveness > 0.5) thành công!',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.face_retouching_natural_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                      label: const Text(
                        'Xác Thực Khuôn Mặt AI (ML Kit Face)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Thẻ truy cập nhanh Quản lý Đơn Xin Nghỉ Phép & Tăng Ca
          Card(
            elevation: 1.5,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedIndex = 2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.edit_document,
                        color: primaryBlue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đơn Nghỉ Phép, Đi Muộn & Tăng Ca',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tổng ${myLeaves.length} đơn • $pendingLeavesCount đơn đang chờ duyệt',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: LỊCH SỬ BẢNG CHẤM CÔNG CÁ NHÂN ====================

  Widget _buildMyAttendanceHistoryTab() {
    final allRecords = _repo.getBangChamCongByMaNV(_employee.MaNV);
    final filtered = allRecords.where((c) {
      if (_historyStatusFilter == 'TatCa') return true;
      return c.TrangThai == _historyStatusFilter;
    }).toList();

    final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHistoryChip('TatCa', 'Tất cả (${allRecords.length})'),
                const SizedBox(width: 8),
                _buildHistoryChip('DungGio', 'Đúng giờ'),
                const SizedBox(width: 8),
                _buildHistoryChip('DiTre', 'Đi trễ'),
                const SizedBox(width: 8),
                _buildHistoryChip('VangMat', 'Vắng mặt'),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final cc = filtered[index];
              final isDungGio = cc.TrangThai == 'DungGio';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isDungGio
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    child: Icon(
                      isDungGio
                          ? Icons.verified_rounded
                          : Icons.schedule_rounded,
                      color: isDungGio ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    '${cc.TenCa} • Ngày: ${cc.NgayLam}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Giờ vào: ${cc.GioCheckIn ?? "--:--"} | Giờ ra: ${cc.GioCheckOut ?? "Chưa ra"}\n'
                    'Số giờ: ${cc.SoGioLam}h • Tiền công: ${currencyFmt.format(cc.TienCongNgay)}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDungGio
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cc.TrangThai,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDungGio
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChip(String value, String label) {
    final isSelected = _historyStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryBlue.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: isSelected ? primaryBlue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _historyStatusFilter = value),
    );
  }
}
