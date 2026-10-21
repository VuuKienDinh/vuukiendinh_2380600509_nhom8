class BangChamCong {
  final String MaChamCong;
  final String MaNV;
  final String HoTenNV;
  final String MaCa;
  final String TenCa;
  final String NgayLam; // Format: YYYY-MM-DD
  final String? GioCheckIn; // Format: HH:mm:ss
  final String? GioCheckOut; // Format: HH:mm:ss
  final double SoGioLam;
  final String TrangThai; // "DungGio", "DiTre", "VeSom", "VangMat"
  final double KhoangCachMet;
  final double TienCongNgay;
  final String MaThietBiChamCong;

  BangChamCong({
    required this.MaChamCong,
    required this.MaNV,
    required this.HoTenNV,
    required this.MaCa,
    required this.TenCa,
    required this.NgayLam,
    this.GioCheckIn,
    this.GioCheckOut,
    required this.SoGioLam,
    required this.TrangThai,
    required this.KhoangCachMet,
    required this.TienCongNgay,
    required this.MaThietBiChamCong,
  });

  factory BangChamCong.fromJson(Map<String, dynamic> json) {
    return BangChamCong(
      MaChamCong: json['MaChamCong']?.toString() ?? '',
      MaNV: json['MaNV']?.toString() ?? '',
      HoTenNV: json['HoTenNV']?.toString() ?? '',
      MaCa: json['MaCa']?.toString() ?? '',
      TenCa: json['TenCa']?.toString() ?? '',
      NgayLam: json['NgayLam']?.toString() ?? '',
      GioCheckIn: json['GioCheckIn']?.toString(),
      GioCheckOut: json['GioCheckOut']?.toString(),
      SoGioLam: (json['SoGioLam'] is num)
          ? (json['SoGioLam'] as num).toDouble()
          : double.tryParse(json['SoGioLam']?.toString() ?? '0.0') ?? 0.0,
      TrangThai: json['TrangThai']?.toString() ?? 'VangMat',
      KhoangCachMet: (json['KhoangCachMet'] is num)
          ? (json['KhoangCachMet'] as num).toDouble()
          : double.tryParse(json['KhoangCachMet']?.toString() ?? '0.0') ?? 0.0,
      TienCongNgay: (json['TienCongNgay'] is num)
          ? (json['TienCongNgay'] as num).toDouble()
          : double.tryParse(json['TienCongNgay']?.toString() ?? '0.0') ?? 0.0,
      MaThietBiChamCong: json['MaThietBiChamCong']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaChamCong': MaChamCong,
      'MaNV': MaNV,
      'HoTenNV': HoTenNV,
      'MaCa': MaCa,
      'TenCa': TenCa,
      'NgayLam': NgayLam,
      'GioCheckIn': GioCheckIn,
      'GioCheckOut': GioCheckOut,
      'SoGioLam': SoGioLam,
      'TrangThai': TrangThai,
      'KhoangCachMet': KhoangCachMet,
      'TienCongNgay': TienCongNgay,
      'MaThietBiChamCong': MaThietBiChamCong,
    };
  }

  BangChamCong copyWith({
    String? MaChamCong,
    String? MaNV,
    String? HoTenNV,
    String? MaCa,
    String? TenCa,
    String? NgayLam,
    String? GioCheckIn,
    String? GioCheckOut,
    double? SoGioLam,
    String? TrangThai,
    double? KhoangCachMet,
    double? TienCongNgay,
    String? MaThietBiChamCong,
  }) {
    return BangChamCong(
      MaChamCong: MaChamCong ?? this.MaChamCong,
      MaNV: MaNV ?? this.MaNV,
      HoTenNV: HoTenNV ?? this.HoTenNV,
      MaCa: MaCa ?? this.MaCa,
      TenCa: TenCa ?? this.TenCa,
      NgayLam: NgayLam ?? this.NgayLam,
      GioCheckIn: GioCheckIn ?? this.GioCheckIn,
      GioCheckOut: GioCheckOut ?? this.GioCheckOut,
      SoGioLam: SoGioLam ?? this.SoGioLam,
      TrangThai: TrangThai ?? this.TrangThai,
      KhoangCachMet: KhoangCachMet ?? this.KhoangCachMet,
      TienCongNgay: TienCongNgay ?? this.TienCongNgay,
      MaThietBiChamCong: MaThietBiChamCong ?? this.MaThietBiChamCong,
    );
  }
}
