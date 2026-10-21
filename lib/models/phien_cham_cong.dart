class PhienChamCong {
  final String MaPhien;
  final String MaCa;
  final String NgayChamCong; // Format: YYYY-MM-DD
  final String MaQRDong; // Chuỗi token/uuid của mã QR động
  final String ThoiGianHetHanQR; // ISO 8601 String
  final bool TrangThaiMo; // true: đang cho phép quét, false: đã đóng

  PhienChamCong({
    required this.MaPhien,
    required this.MaCa,
    required this.NgayChamCong,
    required this.MaQRDong,
    required this.ThoiGianHetHanQR,
    required this.TrangThaiMo,
  });

  factory PhienChamCong.fromJson(Map<String, dynamic> json) {
    return PhienChamCong(
      MaPhien: json['MaPhien']?.toString() ?? '',
      MaCa: json['MaCa']?.toString() ?? '',
      NgayChamCong: json['NgayChamCong']?.toString() ?? '',
      MaQRDong: json['MaQRDong']?.toString() ?? '',
      ThoiGianHetHanQR: json['ThoiGianHetHanQR']?.toString() ?? '',
      TrangThaiMo: json['TrangThaiMo'] is bool
          ? json['TrangThaiMo'] as bool
          : (json['TrangThaiMo']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MaPhien': MaPhien,
      'MaCa': MaCa,
      'NgayChamCong': NgayChamCong,
      'MaQRDong': MaQRDong,
      'ThoiGianHetHanQR': ThoiGianHetHanQR,
      'TrangThaiMo': TrangThaiMo,
    };
  }

  PhienChamCong copyWith({
    String? MaPhien,
    String? MaCa,
    String? NgayChamCong,
    String? MaQRDong,
    String? ThoiGianHetHanQR,
    bool? TrangThaiMo,
  }) {
    return PhienChamCong(
      MaPhien: MaPhien ?? this.MaPhien,
      MaCa: MaCa ?? this.MaCa,
      NgayChamCong: NgayChamCong ?? this.NgayChamCong,
      MaQRDong: MaQRDong ?? this.MaQRDong,
      ThoiGianHetHanQR: ThoiGianHetHanQR ?? this.ThoiGianHetHanQR,
      TrangThaiMo: TrangThaiMo ?? this.TrangThaiMo,
    );
  }
}
