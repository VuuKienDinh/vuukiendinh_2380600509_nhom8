class DonNghiPhep {
  final String MaDon;
  final String MaNV;
  final String HoTenNV;
  final String LoaiDon; // "NghiPhep", "DiMuon", "TangCa"
  final String NgayApDung; // Format: YYYY-MM-DD
  final String LyDo;
  final String TrangThaiDuyet; // "ChoDuyet", "DaDuyet", "TuChoi"

  DonNghiPhep({
    required this.MaDon,
    required this.MaNV,
    required this.HoTenNV,
    required this.LoaiDon,
    required this.NgayApDung,
    required this.LyDo,
    required this.TrangThaiDuyet,
  });

  factory DonNghiPhep.fromJson(Map<String, dynamic> json) {
    return DonNghiPhep(
      MaDon: json['MaDon']?.toString() ?? '',
      MaNV: json['MaNV']?.toString() ?? '',
      HoTenNV: json['HoTenNV']?.toString() ?? '',
      LoaiDon: json['LoaiDon']?.toString() ?? 'NghiPhep',
      NgayApDung: json['NgayApDung']?.toString() ?? '',
      LyDo: json['LyDo']?.toString() ?? '',
      TrangThaiDuyet: json['TrangThaiDuyet']?.toString() ?? 'ChoDuyet',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaDon': MaDon,
      'MaNV': MaNV,
      'HoTenNV': HoTenNV,
      'LoaiDon': LoaiDon,
      'NgayApDung': NgayApDung,
      'LyDo': LyDo,
      'TrangThaiDuyet': TrangThaiDuyet,
    };
  }

  DonNghiPhep copyWith({
    String? MaDon,
    String? MaNV,
    String? HoTenNV,
    String? LoaiDon,
    String? NgayApDung,
    String? LyDo,
    String? TrangThaiDuyet,
  }) {
    return DonNghiPhep(
      MaDon: MaDon ?? this.MaDon,
      MaNV: MaNV ?? this.MaNV,
      HoTenNV: HoTenNV ?? this.HoTenNV,
      LoaiDon: LoaiDon ?? this.LoaiDon,
      NgayApDung: NgayApDung ?? this.NgayApDung,
      LyDo: LyDo ?? this.LyDo,
      TrangThaiDuyet: TrangThaiDuyet ?? this.TrangThaiDuyet,
    );
  }
}
