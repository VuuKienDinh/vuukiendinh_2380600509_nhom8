class NguoiDung {
  final String MaNV;
  final String TenDangNhap;
  final String MatKhau;
  final String HoTen;
  final String Email;
  final String VaiTro; // "ADMIN", "QUANLY", "NHANVIEN"
  final String MaPhongBan;
  final String TenPhongBan;
  final double LuongTheoGio;
  final String MaThietBi;

  NguoiDung({
    required this.MaNV,
    required this.TenDangNhap,
    required this.MatKhau,
    required this.HoTen,
    required this.Email,
    required this.VaiTro,
    required this.MaPhongBan,
    required this.TenPhongBan,
    required this.LuongTheoGio,
    required this.MaThietBi,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      MaNV: json['MaNV']?.toString() ?? '',
      TenDangNhap: json['TenDangNhap']?.toString() ?? '',
      MatKhau: json['MatKhau']?.toString() ?? '',
      HoTen: json['HoTen']?.toString() ?? '',
      Email: json['Email']?.toString() ?? '',
      VaiTro: json['VaiTro']?.toString() ?? 'NHANVIEN',
      MaPhongBan: json['MaPhongBan']?.toString() ?? '',
      TenPhongBan: json['TenPhongBan']?.toString() ?? '',
      LuongTheoGio: (json['LuongTheoGio'] is num)
          ? (json['LuongTheoGio'] as num).toDouble()
          : double.tryParse(json['LuongTheoGio']?.toString() ?? '0') ?? 0.0,
      MaThietBi: json['MaThietBi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaNV': MaNV,
      'TenDangNhap': TenDangNhap,
      'MatKhau': MatKhau,
      'HoTen': HoTen,
      'Email': Email,
      'VaiTro': VaiTro,
      'MaPhongBan': MaPhongBan,
      'TenPhongBan': TenPhongBan,
      'LuongTheoGio': LuongTheoGio,
      'MaThietBi': MaThietBi,
    };
  }

  NguoiDung copyWith({
    String? MaNV,
    String? TenDangNhap,
    String? MatKhau,
    String? HoTen,
    String? Email,
    String? VaiTro,
    String? MaPhongBan,
    String? TenPhongBan,
    double? LuongTheoGio,
    String? MaThietBi,
  }) {
    return NguoiDung(
      MaNV: MaNV ?? this.MaNV,
      TenDangNhap: TenDangNhap ?? this.TenDangNhap,
      MatKhau: MatKhau ?? this.MatKhau,
      HoTen: HoTen ?? this.HoTen,
      Email: Email ?? this.Email,
      VaiTro: VaiTro ?? this.VaiTro,
      MaPhongBan: MaPhongBan ?? this.MaPhongBan,
      TenPhongBan: TenPhongBan ?? this.TenPhongBan,
      LuongTheoGio: LuongTheoGio ?? this.LuongTheoGio,
      MaThietBi: MaThietBi ?? this.MaThietBi,
    );
  }
}
