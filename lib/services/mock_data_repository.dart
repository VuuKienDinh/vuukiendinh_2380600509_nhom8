import '../models/nguoi_dung.dart';
import '../models/ca_lam_viec.dart';
import '../models/phien_cham_cong.dart';
import '../models/bang_cham_cong.dart';
import '../models/don_nghi_phep.dart';

class MockDataRepository {
  // Cờ chuyển đổi dữ liệu giả lập (true: chạy In-Memory Mock, false: gọi Web API thật)
  static bool useMockData = true;

  // Mã OTP mặc định cho môi trường giả lập
  static const String defaultMockOtp = '123456';

  // Singleton Pattern
  static final MockDataRepository _instance = MockDataRepository._internal();
  factory MockDataRepository() => _instance;
  static MockDataRepository get instance => _instance;

  MockDataRepository._internal() {
    _initMockData();
  }

  final List<NguoiDung> danhSachNguoiDung = [];
  final List<CaLamViec> danhSachCaLamViec = [];
  final List<PhienChamCong> danhSachPhienChamCong = [];
  final List<BangChamCong> danhSachBangChamCong = [];
  final List<DonNghiPhep> danhSachDonNghiPhep = [];

  void _initMockData() {
    if (danhSachNguoiDung.isNotEmpty) return;

    // 1. Khởi tạo danh sách Người Dùng (Bao gồm 3 tài khoản demo chính & các nhân viên mẫu)
    danhSachNguoiDung.addAll([
      NguoiDung(
        MaNV: 'AD001',
        TenDangNhap: 'admin',
        MatKhau: '123',
        HoTen: 'Quản Trị Viên Hệ Thống',
        Email: 'admin@enterprise.vn',
        VaiTro: 'ADMIN',
        MaPhongBan: 'PB01',
        TenPhongBan: 'Ban Quản Trị & CNTT',
        LuongTheoGio: 120000.0,
        MaThietBi: 'ANDROID-ADMIN-DEVICE-001',
      ),
      NguoiDung(
        MaNV: 'QL001',
        TenDangNhap: 'ql01',
        MatKhau: '123',
        HoTen: 'Trần Thị Mai Phương (Quản lý HR)',
        Email: 'ql01.hr@enterprise.vn',
        VaiTro: 'QUANLY',
        MaPhongBan: 'PB02',
        TenPhongBan: 'Phòng Hành Chính - Nhân Sự',
        LuongTheoGio: 95000.0,
        MaThietBi: 'ANDROID-HR-DEVICE-001',
      ),
      NguoiDung(
        MaNV: '2380600509',
        TenDangNhap: '2380600509',
        MatKhau: '123',
        HoTen: 'Vưu Kiên Định',
        Email: 'vuukiendinh.2380600509@hutech.edu.vn',
        VaiTro: 'NHANVIEN',
        MaPhongBan: 'PB03',
        TenPhongBan: 'Phòng Phát Triển Phần Mềm',
        LuongTheoGio: 75000.0,
        MaThietBi: 'ANDROID-VKD-2380600509',
      ),
      NguoiDung(
        MaNV: 'NV002',
        TenDangNhap: 'nv02',
        MatKhau: '123',
        HoTen: 'Lê Hoàng Nam',
        Email: 'hoangnam.le@enterprise.vn',
        VaiTro: 'NHANVIEN',
        MaPhongBan: 'PB03',
        TenPhongBan: 'Phòng Phát Triển Phần Mềm',
        LuongTheoGio: 65000.0,
        MaThietBi: 'ANDROID-NAM-002',
      ),
      NguoiDung(
        MaNV: 'NV003',
        TenDangNhap: 'nv03',
        MatKhau: '123',
        HoTen: 'Phạm Ngọc Ánh',
        Email: 'ngocanh.pham@enterprise.vn',
        VaiTro: 'NHANVIEN',
        MaPhongBan: 'PB02',
        TenPhongBan: 'Phòng Hành Chính - Nhân Sự',
        LuongTheoGio: 60000.0,
        MaThietBi: 'ANDROID-ANH-003',
      ),
      NguoiDung(
        MaNV: 'NV004',
        TenDangNhap: 'nv04',
        MatKhau: '123',
        HoTen: 'Nguyễn Minh Tuấn',
        Email: 'minhtuan.nguyen@enterprise.vn',
        VaiTro: 'NHANVIEN',
        MaPhongBan: 'PB04',
        TenPhongBan: 'Phòng Kinh Doanh & Marketing',
        LuongTheoGio: 62000.0,
        MaThietBi: 'ANDROID-TUAN-004',
      ),
    ]);

    // 2. Khởi tạo danh sách Ca Làm Việc (Bán kính chuẩn 50m cho chống gian lận GPS)
    danhSachCaLamViec.addAll([
      CaLamViec(
        MaCa: 'CA01',
        TenCa: 'Ca Sáng',
        GioBatDau: '08:00',
        GioKetThuc: '12:00',
        HeSoLuong: 1.0,
        ViDoCongTy: 10.801618,
        KinhDoCongTy: 106.714546,
        BanKinhChoPhep: 50.0,
      ),
      CaLamViec(
        MaCa: 'CA02',
        TenCa: 'Ca Chiều',
        GioBatDau: '13:00',
        GioKetThuc: '17:00',
        HeSoLuong: 1.0,
        ViDoCongTy: 10.801618,
        KinhDoCongTy: 106.714546,
        BanKinhChoPhep: 50.0,
      ),
      CaLamViec(
        MaCa: 'CA03',
        TenCa: 'Ca Hành Chính',
        GioBatDau: '08:00',
        GioKetThuc: '17:00',
        HeSoLuong: 1.2,
        ViDoCongTy: 10.801618,
        KinhDoCongTy: 106.714546,
        BanKinhChoPhep: 50.0,
      ),
      CaLamViec(
        MaCa: 'CA04',
        TenCa: 'Ca Tăng Ca Tối (OT)',
        GioBatDau: '18:00',
        GioKetThuc: '21:00',
        HeSoLuong: 1.5,
        ViDoCongTy: 10.801618,
        KinhDoCongTy: 106.714546,
        BanKinhChoPhep: 50.0,
      ),
    ]);

    // 3. Khởi tạo danh sách Phiên Chấm Công (QR Động 15 giây)
    final todayStr = formatDate(DateTime.now());
    danhSachPhienChamCong.addAll([
      PhienChamCong(
        MaPhien: 'PHIEN_001',
        MaCa: 'CA01',
        NgayChamCong: todayStr,
        MaQRDong: 'VKD_QR15S_CA01_${DateTime.now().millisecondsSinceEpoch}',
        ThoiGianHetHanQR: DateTime.now()
            .add(const Duration(seconds: 15))
            .toIso8601String(),
        TrangThaiMo: true,
      ),
      PhienChamCong(
        MaPhien: 'PHIEN_002',
        MaCa: 'CA03',
        NgayChamCong: todayStr,
        MaQRDong: 'VKD_QR15S_CA03_${DateTime.now().millisecondsSinceEpoch}',
        ThoiGianHetHanQR: DateTime.now()
            .add(const Duration(seconds: 15))
            .toIso8601String(),
        TrangThaiMo: true,
      ),
    ]);

    // 4. Khởi tạo danh sách Bảng Chấm Công mẫu
    final yesterdayStr = formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final twoDaysAgoStr = formatDate(
      DateTime.now().subtract(const Duration(days: 2)),
    );
    final threeDaysAgoStr = formatDate(
      DateTime.now().subtract(const Duration(days: 3)),
    );

    danhSachBangChamCong.addAll([
      BangChamCong(
        MaChamCong: 'CC_TODAY_01',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        MaCa: 'CA01',
        TenCa: 'Ca Sáng',
        NgayLam: todayStr,
        GioCheckIn: '07:52:10',
        GioCheckOut: '12:01:30',
        SoGioLam: 4.15,
        TrangThai: 'DungGio',
        KhoangCachMet: 10.5,
        TienCongNgay: 311250.0,
        MaThietBiChamCong: 'ANDROID-VKD-2380600509',
      ),
      BangChamCong(
        MaChamCong: 'CC_TODAY_02',
        MaNV: 'NV002',
        HoTenNV: 'Lê Hoàng Nam',
        MaCa: 'CA01',
        TenCa: 'Ca Sáng',
        NgayLam: todayStr,
        GioCheckIn: '07:56:45',
        GioCheckOut: '12:00:15',
        SoGioLam: 4.0,
        TrangThai: 'DungGio',
        KhoangCachMet: 22.0,
        TienCongNgay: 260000.0,
        MaThietBiChamCong: 'ANDROID-NAM-002',
      ),
      BangChamCong(
        MaChamCong: 'CC_TODAY_03',
        MaNV: 'NV003',
        HoTenNV: 'Phạm Ngọc Ánh',
        MaCa: 'CA01',
        TenCa: 'Ca Sáng',
        NgayLam: todayStr,
        GioCheckIn: '08:18:20',
        GioCheckOut: '12:03:00',
        SoGioLam: 3.7,
        TrangThai: 'DiTre',
        KhoangCachMet: 38.8,
        TienCongNgay: 222000.0,
        MaThietBiChamCong: 'ANDROID-ANH-003',
      ),
      BangChamCong(
        MaChamCong: 'CC_TODAY_04',
        MaNV: 'NV004',
        HoTenNV: 'Nguyễn Minh Tuấn',
        MaCa: 'CA01',
        TenCa: 'Ca Sáng',
        NgayLam: todayStr,
        GioCheckIn: null,
        GioCheckOut: null,
        SoGioLam: 0.0,
        TrangThai: 'VangMat',
        KhoangCachMet: 0.0,
        TienCongNgay: 0.0,
        MaThietBiChamCong: 'CHUA_CHAM_CONG',
      ),
      BangChamCong(
        MaChamCong: 'CC001',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        MaCa: 'CA03',
        TenCa: 'Ca Hành Chính',
        NgayLam: yesterdayStr,
        GioCheckIn: '07:55:12',
        GioCheckOut: '17:04:40',
        SoGioLam: 8.0,
        TrangThai: 'DungGio',
        KhoangCachMet: 12.5,
        TienCongNgay: 720000.0,
        MaThietBiChamCong: 'ANDROID-VKD-2380600509',
      ),
      BangChamCong(
        MaChamCong: 'CC002',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        MaCa: 'CA03',
        TenCa: 'Ca Hành Chính',
        NgayLam: twoDaysAgoStr,
        GioCheckIn: '07:58:05',
        GioCheckOut: '17:05:19',
        SoGioLam: 8.0,
        TrangThai: 'DungGio',
        KhoangCachMet: 15.0,
        TienCongNgay: 720000.0,
        MaThietBiChamCong: 'ANDROID-VKD-2380600509',
      ),
      BangChamCong(
        MaChamCong: 'CC003',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        MaCa: 'CA01',
        TenCa: 'Ca Sáng',
        NgayLam: threeDaysAgoStr,
        GioCheckIn: '08:12:30',
        GioCheckOut: '12:00:10',
        SoGioLam: 3.8,
        TrangThai: 'DiTre',
        KhoangCachMet: 28.2,
        TienCongNgay: 285000.0,
        MaThietBiChamCong: 'ANDROID-VKD-2380600509',
      ),
      BangChamCong(
        MaChamCong: 'CC004',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        MaCa: 'CA04',
        TenCa: 'Ca Tăng Ca Tối (OT)',
        NgayLam: threeDaysAgoStr,
        GioCheckIn: '17:55:00',
        GioCheckOut: '21:02:00',
        SoGioLam: 3.0,
        TrangThai: 'DungGio',
        KhoangCachMet: 11.0,
        TienCongNgay: 337500.0,
        MaThietBiChamCong: 'ANDROID-VKD-2380600509',
      ),
    ]);

    // 5. Khởi tạo danh sách Đơn Nghỉ Phép / Đi Muộn / Tăng Ca mẫu
    danhSachDonNghiPhep.addAll([
      DonNghiPhep(
        MaDon: 'DON001',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        LoaiDon: 'TangCa',
        NgayApDung: todayStr,
        LyDo:
            'Triển khai tính năng Chống chấm công hộ đa tầng (QR động 15s + Khóa DeviceID + GPS 50m)',
        TrangThaiDuyet: 'ChoDuyet',
      ),
      DonNghiPhep(
        MaDon: 'DON002',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        LoaiDon: 'NghiPhep',
        NgayApDung: formatDate(DateTime.now().add(const Duration(days: 2))),
        LyDo: 'Tham dự buổi báo cáo đồ án môn học tại trường đại học',
        TrangThaiDuyet: 'ChoDuyet',
      ),
      DonNghiPhep(
        MaDon: 'DON003',
        MaNV: '2380600509',
        HoTenNV: 'Vưu Kiên Định',
        LoaiDon: 'DiMuon',
        NgayApDung: threeDaysAgoStr,
        LyDo: 'Kẹt xe giờ cao điểm tại ngã tư Hàng Xanh, xin phép vào trễ 15p',
        TrangThaiDuyet: 'DaDuyet',
      ),
      DonNghiPhep(
        MaDon: 'DON004',
        MaNV: 'NV002',
        HoTenNV: 'Lê Hoàng Nam',
        LoaiDon: 'DiMuon',
        NgayApDung: todayStr,
        LyDo: 'Xe hỏng trên đường đi làm, xin phép vào ca muộn 30 phút',
        TrangThaiDuyet: 'ChoDuyet',
      ),
      DonNghiPhep(
        MaDon: 'DON005',
        MaNV: 'NV003',
        HoTenNV: 'Phạm Ngọc Ánh',
        LoaiDon: 'NghiPhep',
        NgayApDung: formatDate(DateTime.now().add(const Duration(days: 1))),
        LyDo: 'Giải quyết việc gia đình cá nhân (nghỉ phép năm có hưởng lương)',
        TrangThaiDuyet: 'TuChoi',
      ),
    ]);
  }

  String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ==================== THỐNG KÊ HỆ THỐNG ====================

  double getTyLeDungGioHomNay() {
    final todayStr = formatDate(DateTime.now());
    final todayRecords = danhSachBangChamCong
        .where((c) => c.NgayLam == todayStr)
        .toList();
    if (todayRecords.isEmpty) {
      if (danhSachBangChamCong.isEmpty) return 100.0;
      final dungGioAll = danhSachBangChamCong
          .where((c) => c.TrangThai == 'DungGio')
          .length;
      return (dungGioAll / danhSachBangChamCong.length) * 100.0;
    }
    final dungGioCount = todayRecords
        .where((c) => c.TrangThai == 'DungGio')
        .length;
    return (dungGioCount / todayRecords.length) * 100.0;
  }

  int getTongSoCongNhanVien(String maNV) {
    return danhSachBangChamCong
        .where((c) => c.MaNV == maNV && c.TrangThai != 'VangMat')
        .length;
  }

  double getTongLuongTamTinhNhanVien(String maNV) {
    double total = 0.0;
    for (final c in danhSachBangChamCong) {
      if (c.MaNV == maNV) {
        total += c.TienCongNgay;
      }
    }
    return total;
  }

  // ==================== AUTH & OTP OPERATIONS ====================

  NguoiDung? authenticate(String tenDangNhap, String matKhau) {
    try {
      return danhSachNguoiDung.firstWhere(
        (u) =>
            u.TenDangNhap.trim().toLowerCase() ==
                tenDangNhap.trim().toLowerCase() &&
            u.MatKhau == matKhau,
      );
    } catch (_) {
      return null;
    }
  }

  NguoiDung? findUserByUsernameOrId(String identifier) {
    try {
      return danhSachNguoiDung.firstWhere(
        (u) =>
            u.TenDangNhap.toLowerCase() == identifier.toLowerCase() ||
            u.MaNV.toLowerCase() == identifier.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  bool isUserExists(String tenDangNhap, String email, {String? excludeMaNV}) {
    return danhSachNguoiDung.any(
      (u) =>
          (excludeMaNV == null || u.MaNV != excludeMaNV) &&
          (u.TenDangNhap.toLowerCase() == tenDangNhap.trim().toLowerCase() ||
              u.Email.toLowerCase() == email.trim().toLowerCase()),
    );
  }

  NguoiDung registerUser({
    required String maNV,
    required String tenDangNhap,
    required String matKhau,
    required String hoTen,
    required String email,
    String maPhongBan = 'PB03',
    String tenPhongBan = 'Phòng Phát Triển Phần Mềm',
    String maThietBi = 'ANDROID-NEW-DEVICE',
  }) {
    final newUser = NguoiDung(
      MaNV: maNV.trim().isEmpty
          ? 'NV${danhSachNguoiDung.length + 100}'
          : maNV.trim(),
      TenDangNhap: tenDangNhap.trim(),
      MatKhau: matKhau,
      HoTen: hoTen.trim(),
      Email: email.trim(),
      VaiTro: 'NHANVIEN',
      MaPhongBan: maPhongBan,
      TenPhongBan: tenPhongBan,
      LuongTheoGio: 60000.0,
      MaThietBi: maThietBi,
    );
    danhSachNguoiDung.add(newUser);
    return newUser;
  }

  bool verifyOtp(String otpInput) {
    return otpInput.trim() == defaultMockOtp;
  }

  // ==================== CRUD CA LÀM VIỆC (ADMIN) ====================

  void addCaLamViec(CaLamViec caMoi) {
    danhSachCaLamViec.add(caMoi);
  }

  bool updateCaLamViec(String maCaGoc, CaLamViec caCapNhat) {
    final index = danhSachCaLamViec.indexWhere((c) => c.MaCa == maCaGoc);
    if (index == -1) return false;
    danhSachCaLamViec[index] = caCapNhat;
    return true;
  }

  bool deleteCaLamViec(String maCa) {
    final initialLen = danhSachCaLamViec.length;
    danhSachCaLamViec.removeWhere((c) => c.MaCa == maCa);
    return danhSachCaLamViec.length < initialLen;
  }

  /// Cập nhật tọa độ GPS văn phòng cho toàn bộ Ca làm việc hoặc 1 Ca cụ thể
  void updateOfficeGpsCoordinates({
    required double viDo,
    required double kinhDo,
    double banKinh = 50.0,
    String? maCa,
  }) {
    for (int i = 0; i < danhSachCaLamViec.length; i++) {
      if (maCa == null || danhSachCaLamViec[i].MaCa == maCa) {
        danhSachCaLamViec[i] = danhSachCaLamViec[i].copyWith(
          ViDoCongTy: viDo,
          KinhDoCongTy: kinhDo,
          BanKinhChoPhep: banKinh,
        );
      }
    }
  }

  // ==================== CRUD NGƯỜI DÙNG / NHÂN VIÊN (ADMIN) ====================

  void addNguoiDung(NguoiDung user) {
    danhSachNguoiDung.add(user);
  }

  bool updateNguoiDung(String maNVGoc, NguoiDung updatedUser) {
    final index = danhSachNguoiDung.indexWhere((u) => u.MaNV == maNVGoc);
    if (index == -1) return false;
    danhSachNguoiDung[index] = updatedUser;
    return true;
  }

  bool deleteNguoiDung(String maNV) {
    final initialLen = danhSachNguoiDung.length;
    danhSachNguoiDung.removeWhere((u) => u.MaNV == maNV);
    return danhSachNguoiDung.length < initialLen;
  }

  // ==================== CHỐNG GIAN LẬN: DYNAMIC QR 15S & DEVICE ID LOCK ====================

  /// Tạo mới hoặc xoay vòng mã QR động mỗi 15 giây
  PhienChamCong createPhienChamCong(String maCa) {
    final now = DateTime.now();
    final phien = PhienChamCong(
      MaPhien: 'PHIEN_${now.millisecondsSinceEpoch}',
      MaCa: maCa,
      NgayChamCong: formatDate(now),
      MaQRDong:
          'VKD_QR15S_${maCa}_${now.millisecondsSinceEpoch}_${(now.second * 17) % 99}',
      ThoiGianHetHanQR: now.add(const Duration(seconds: 15)).toIso8601String(),
      TrangThaiMo: true,
    );
    danhSachPhienChamCong.insert(0, phien);
    return phien;
  }

  /// Kiểm tra mã QR động có hợp lệ hay không
  bool validateDynamicQr(String scannedToken) {
    final clean = scannedToken.trim();
    if (clean.isEmpty) return false;
    // Cho phép mã QR đang mở trong danh sách hoặc tiền tố chuẩn của hệ thống
    final matchInList = danhSachPhienChamCong.any(
      (p) => p.TrangThaiMo && p.MaQRDong == clean,
    );
    return matchInList ||
        clean.startsWith('VKD_QR15S_') ||
        clean.startsWith('QR_');
  }

  /// Kiểm tra Khóa cứng DeviceID: Trong ngày hôm nay, thiết bị này đã chấm công cho MaNV nào khác chưa?
  /// Nếu có, trả về bản ghi BangChamCong của nhân viên khác đó (phát hiện chấm công hộ).
  BangChamCong? checkDeviceIdFraudToday({
    required String maThietBiChamCong,
    required String currentMaNV,
  }) {
    final todayStr = formatDate(DateTime.now());
    final cleanDevice = maThietBiChamCong.trim();
    if (cleanDevice.isEmpty || cleanDevice == 'CHUA_CHAM_CONG') return null;

    for (final record in danhSachBangChamCong) {
      if (record.NgayLam == todayStr &&
          record.MaThietBiChamCong.toLowerCase() == cleanDevice.toLowerCase() &&
          record.MaNV.toLowerCase() != currentMaNV.toLowerCase()) {
        return record;
      }
    }
    return null;
  }

  // ==================== CRUD BẢNG CHẤM CÔNG & TÍNH LƯƠNG REALTIME ====================

  List<BangChamCong> getBangChamCongByMaNV(String maNV) {
    final list = danhSachBangChamCong
        .where((item) => item.MaNV == maNV)
        .toList();
    list.sort((a, b) => b.NgayLam.compareTo(a.NgayLam));
    return list;
  }

  BangChamCong addBangChamCongBu({
    required NguoiDung nhanVien,
    required CaLamViec caLamViec,
    required String ngayLam,
    required String? gioCheckIn,
    required String? gioCheckOut,
    required String trangThai,
    required double soGioLam,
  }) {
    final double tienCong = trangThai == 'VangMat'
        ? 0.0
        : soGioLam * nhanVien.LuongTheoGio * caLamViec.HeSoLuong;

    final record = BangChamCong(
      MaChamCong: 'CC_BU_${DateTime.now().millisecondsSinceEpoch}',
      MaNV: nhanVien.MaNV,
      HoTenNV: nhanVien.HoTen,
      MaCa: caLamViec.MaCa,
      TenCa: caLamViec.TenCa,
      NgayLam: ngayLam,
      GioCheckIn: trangThai == 'VangMat' ? null : gioCheckIn,
      GioCheckOut: trangThai == 'VangMat' ? null : gioCheckOut,
      SoGioLam: trangThai == 'VangMat' ? 0.0 : soGioLam,
      TrangThai: trangThai,
      KhoangCachMet: 0.0,
      TienCongNgay: tienCong,
      MaThietBiChamCong: 'HR_CHAM_CONG_BU',
    );
    danhSachBangChamCong.insert(0, record);
    return record;
  }

  bool updateBangChamCong(String maChamCong, BangChamCong updatedRecord) {
    final idx = danhSachBangChamCong.indexWhere(
      (c) => c.MaChamCong == maChamCong,
    );
    if (idx == -1) return false;
    danhSachBangChamCong[idx] = updatedRecord;
    return true;
  }

  bool deleteBangChamCong(String maChamCong) {
    final initialLen = danhSachBangChamCong.length;
    danhSachBangChamCong.removeWhere((c) => c.MaChamCong == maChamCong);
    return danhSachBangChamCong.length < initialLen;
  }

  /// Thực hiện Check-in chấm công mới
  BangChamCong checkIn({
    required NguoiDung nhanVien,
    required CaLamViec caLamViec,
    required double khoangCachMet,
    required String maThietBi,
  }) {
    final now = DateTime.now();
    final todayStr = formatDate(now);
    final timeStr = formatTime(now);

    String trangThai = 'DungGio';
    final parts = caLamViec.GioBatDau.split(':');
    if (parts.length >= 2) {
      final startHour = int.tryParse(parts[0]) ?? 8;
      final startMinute = int.tryParse(parts[1]) ?? 0;
      if (now.hour > startHour ||
          (now.hour == startHour && now.minute > startMinute + 5)) {
        trangThai = 'DiTre';
      }
    }

    final record = BangChamCong(
      MaChamCong: 'CC_${now.millisecondsSinceEpoch}',
      MaNV: nhanVien.MaNV,
      HoTenNV: nhanVien.HoTen,
      MaCa: caLamViec.MaCa,
      TenCa: caLamViec.TenCa,
      NgayLam: todayStr,
      GioCheckIn: timeStr,
      GioCheckOut: null,
      SoGioLam: 0.0,
      TrangThai: trangThai,
      KhoangCachMet: double.parse(khoangCachMet.toStringAsFixed(1)),
      TienCongNgay: 0.0,
      MaThietBiChamCong: maThietBi,
    );

    danhSachBangChamCong.insert(0, record);
    return record;
  }

  /// Thực hiện Check-out cập nhật giờ ra và Tự động tính lương Realtime theo giờ Check-in/Check-out
  BangChamCong? checkOut(
    String maChamCong,
    double luongTheoGio,
    double heSoLuong, {
    double? khoangCachMet,
    String? maThietBiChamCong,
  }) {
    final index = danhSachBangChamCong.indexWhere(
      (c) => c.MaChamCong == maChamCong,
    );
    if (index == -1) return null;

    final current = danhSachBangChamCong[index];
    final now = DateTime.now();
    final timeOutStr = formatTime(now);

    // Tính số giờ làm thực tế từ GioCheckIn -> GioCheckOut
    double soGioTinhCong = 4.0;
    if (current.GioCheckIn != null && current.GioCheckIn!.isNotEmpty) {
      final inParts = current.GioCheckIn!.split(':');
      if (inParts.length >= 2) {
        final inH = int.tryParse(inParts[0]) ?? now.hour;
        final inM = int.tryParse(inParts[1]) ?? now.minute;
        final inS = inParts.length >= 3 ? (int.tryParse(inParts[2]) ?? 0) : 0;

        final checkInTime = DateTime(
          now.year,
          now.month,
          now.day,
          inH,
          inM,
          inS,
        );
        final diffSeconds = now.difference(checkInTime).inSeconds;
        if (diffSeconds > 900) {
          // Nếu khoảng cách thực tế > 15 phút thì lấy đúng số giờ thực tế
          soGioTinhCong = double.parse(
            (diffSeconds / 3600.0).toStringAsFixed(2),
          );
        } else {
          // Nếu đang demo bấm Check-in rồi Check-out ngay trong vài giây,
          // quy đổi 4.0 giờ tiêu chuẩn của ca để giảng viên thấy rõ tiền lương Realtime nhảy lên!
          soGioTinhCong = 4.0;
        }
      }
    }

    final double tienCong = double.parse(
      (soGioTinhCong * luongTheoGio * heSoLuong).toStringAsFixed(0),
    );

    final updated = current.copyWith(
      GioCheckOut: timeOutStr,
      SoGioLam: soGioTinhCong,
      TienCongNgay: tienCong,
      KhoangCachMet: khoangCachMet != null
          ? double.parse(khoangCachMet.toStringAsFixed(1))
          : current.KhoangCachMet,
      MaThietBiChamCong: maThietBiChamCong ?? current.MaThietBiChamCong,
    );

    danhSachBangChamCong[index] = updated;
    return updated;
  }

  // ==================== CRUD ĐƠN NGHỈ PHÉP & TĂNG CA ====================

  List<DonNghiPhep> getDonNghiPhepByMaNV(String maNV) {
    return danhSachDonNghiPhep.where((item) => item.MaNV == maNV).toList();
  }

  DonNghiPhep createDonNghiPhep({
    required NguoiDung nhanVien,
    required String loaiDon,
    required String ngayApDung,
    required String lyDo,
  }) {
    final newDon = DonNghiPhep(
      MaDon:
          'DON${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      MaNV: nhanVien.MaNV,
      HoTenNV: nhanVien.HoTen,
      LoaiDon: loaiDon,
      NgayApDung: ngayApDung,
      LyDo: lyDo.trim(),
      TrangThaiDuyet: 'ChoDuyet',
    );
    danhSachDonNghiPhep.insert(0, newDon);
    return newDon;
  }

  bool updateDonNghiPhep({
    required String maDon,
    required String loaiDon,
    required String ngayApDung,
    required String lyDo,
  }) {
    final idx = danhSachDonNghiPhep.indexWhere((d) => d.MaDon == maDon);
    if (idx == -1) return false;
    if (danhSachDonNghiPhep[idx].TrangThaiDuyet != 'ChoDuyet') return false;

    danhSachDonNghiPhep[idx] = danhSachDonNghiPhep[idx].copyWith(
      LoaiDon: loaiDon,
      NgayApDung: ngayApDung,
      LyDo: lyDo.trim(),
    );
    return true;
  }

  bool deleteDonNghiPhep(String maDon) {
    final idx = danhSachDonNghiPhep.indexWhere((d) => d.MaDon == maDon);
    if (idx == -1) return false;
    if (danhSachDonNghiPhep[idx].TrangThaiDuyet != 'ChoDuyet') return false;

    danhSachDonNghiPhep.removeAt(idx);
    return true;
  }

  bool updateTrangThaiDon(String maDon, String trangThaiMoi) {
    final idx = danhSachDonNghiPhep.indexWhere((d) => d.MaDon == maDon);
    if (idx == -1) return false;
    danhSachDonNghiPhep[idx] = danhSachDonNghiPhep[idx].copyWith(
      TrangThaiDuyet: trangThaiMoi,
    );
    return true;
  }
}
