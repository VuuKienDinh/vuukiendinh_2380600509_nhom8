class CaLamViec {
  final String MaCa;
  final String TenCa;
  final String GioBatDau; // ví dụ "08:00"
  final String GioKetThuc; // ví dụ "12:00"
  final double HeSoLuong; // ví dụ 1.0 hoặc 1.5
  final double ViDoCongTy; // Vĩ độ văn phòng
  final double KinhDoCongTy; // Kinh độ văn phòng
  final double BanKinhChoPhep; // Bán kính tính bằng mét (ví dụ 150m)

  CaLamViec({
    required this.MaCa,
    required this.TenCa,
    required this.GioBatDau,
    required this.GioKetThuc,
    required this.HeSoLuong,
    required this.ViDoCongTy,
    required this.KinhDoCongTy,
    required this.BanKinhChoPhep,
  });

  factory CaLamViec.fromJson(Map<String, dynamic> json) {
    return CaLamViec(
      MaCa: json['MaCa']?.toString() ?? '',
      TenCa: json['TenCa']?.toString() ?? '',
      GioBatDau: json['GioBatDau']?.toString() ?? '',
      GioKetThuc: json['GioKetThuc']?.toString() ?? '',
      HeSoLuong: (json['HeSoLuong'] is num)
          ? (json['HeSoLuong'] as num).toDouble()
          : double.tryParse(json['HeSoLuong']?.toString() ?? '1.0') ?? 1.0,
      ViDoCongTy: (json['ViDoCongTy'] is num)
          ? (json['ViDoCongTy'] as num).toDouble()
          : double.tryParse(json['ViDoCongTy']?.toString() ?? '0.0') ?? 0.0,
      KinhDoCongTy: (json['KinhDoCongTy'] is num)
          ? (json['KinhDoCongTy'] as num).toDouble()
          : double.tryParse(json['KinhDoCongTy']?.toString() ?? '0.0') ?? 0.0,
      BanKinhChoPhep: (json['BanKinhChoPhep'] is num)
          ? (json['BanKinhChoPhep'] as num).toDouble()
          : double.tryParse(json['BanKinhChoPhep']?.toString() ?? '150.0') ?? 150.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaCa': MaCa,
      'TenCa': TenCa,
      'GioBatDau': GioBatDau,
      'GioKetThuc': GioKetThuc,
      'HeSoLuong': HeSoLuong,
      'ViDoCongTy': ViDoCongTy,
      'KinhDoCongTy': KinhDoCongTy,
      'BanKinhChoPhep': BanKinhChoPhep,
    };
  }

  CaLamViec copyWith({
    String? MaCa,
    String? TenCa,
    String? GioBatDau,
    String? GioKetThuc,
    double? HeSoLuong,
    double? ViDoCongTy,
    double? KinhDoCongTy,
    double? BanKinhChoPhep,
  }) {
    return CaLamViec(
      MaCa: MaCa ?? this.MaCa,
      TenCa: TenCa ?? this.TenCa,
      GioBatDau: GioBatDau ?? this.GioBatDau,
      GioKetThuc: GioKetThuc ?? this.GioKetThuc,
      HeSoLuong: HeSoLuong ?? this.HeSoLuong,
      ViDoCongTy: ViDoCongTy ?? this.ViDoCongTy,
      KinhDoCongTy: KinhDoCongTy ?? this.KinhDoCongTy,
      BanKinhChoPhep: BanKinhChoPhep ?? this.BanKinhChoPhep,
    );
  }
}
