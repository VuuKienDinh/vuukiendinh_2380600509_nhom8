namespace VuuKienDinh_Nhom8.Models;

public class NguoiDung
{
    public string MaNV { get; set; } = string.Empty;
    public string TenDangNhap { get; set; } = string.Empty;
    public string MatKhau { get; set; } = string.Empty;
    public string HoTen { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string VaiTro { get; set; } = "NHANVIEN";
    public string MaPhongBan { get; set; } = string.Empty;
    public string TenPhongBan { get; set; } = string.Empty;
    public double LuongTheoGio { get; set; } = 60000.0;
    public string MaThietBi { get; set; } = string.Empty;
}

public class CaLamViec
{
    public string MaCa { get; set; } = string.Empty;
    public string TenCa { get; set; } = string.Empty;
    public string GioBatDau { get; set; } = "08:00";
    public string GioKetThuc { get; set; } = "12:00";
    public double HeSoLuong { get; set; } = 1.0;
    public double ViDoCongTy { get; set; } = 10.801618;
    public double KinhDoCongTy { get; set; } = 106.714546;
    public double BanKinhChoPhep { get; set; } = 50.0;
}

public class PhienChamCong
{
    public string MaPhien { get; set; } = string.Empty;
    public string MaCa { get; set; } = string.Empty;
    public string NgayChamCong { get; set; } = string.Empty;
    public string MaQRDong { get; set; } = string.Empty;
    public string ThoiGianHetHanQR { get; set; } = string.Empty;
    public bool TrangThaiMo { get; set; } = true;
}

public class BangChamCong
{
    public string MaChamCong { get; set; } = string.Empty;
    public string MaNV { get; set; } = string.Empty;
    public string HoTenNV { get; set; } = string.Empty;
    public string MaCa { get; set; } = string.Empty;
    public string TenCa { get; set; } = string.Empty;
    public string NgayLam { get; set; } = string.Empty;
    public string? GioCheckIn { get; set; }
    public string? GioCheckOut { get; set; }
    public double SoGioLam { get; set; } = 0.0;
    public string TrangThai { get; set; } = "DungGio";
    public double KhoangCachMet { get; set; } = 0.0;
    public double TienCongNgay { get; set; } = 0.0;
    public string MaThietBiChamCong { get; set; } = string.Empty;
}

public class DonNghiPhep
{
    public string MaDon { get; set; } = string.Empty;
    public string MaNV { get; set; } = string.Empty;
    public string HoTenNV { get; set; } = string.Empty;
    public string LoaiDon { get; set; } = "NghiPhep";
    public string NgayApDung { get; set; } = string.Empty;
    public string LyDo { get; set; } = string.Empty;
    public string TrangThaiDuyet { get; set; } = "ChoDuyet";
}

public class FlutterLoginRequest
{
    public string? TenDangNhap { get; set; }
    public string? MatKhau { get; set; }
    public string? Email { get; set; }
    public string? Password { get; set; }
}

public class FlutterVerifyOtpRequest
{
    public string Email { get; set; } = string.Empty;
    public string MaOTP { get; set; } = string.Empty;
}

public class FaceAuthRequest
{
    public string MaNV { get; set; } = "2380600509";
    public double LeftEyeOpenProbability { get; set; } = 0.92;
    public double RightEyeOpenProbability { get; set; } = 0.94;
    public string? MaThietBi { get; set; }
}

public class CheckInQrRequest
{
    public string MaNV { get; set; } = "2380600509";
    public string MaCa { get; set; } = "CA01";
    public string MaQRDong { get; set; } = string.Empty;
    public double? ViDoNhanVien { get; set; }
    public double? KinhDoNhanVien { get; set; }
    public double? KhoangCachMet { get; set; }
    public string MaThietBiChamCong { get; set; } = string.Empty;
    public bool DaXacThucVanTay { get; set; } = true;
}

public class CheckOutQrRequest
{
    public string MaChamCong { get; set; } = string.Empty;
    public string? MaNV { get; set; }
    public string? MaQRDong { get; set; }
    public double? KhoangCachMet { get; set; }
    public string? MaThietBiChamCong { get; set; }
}

public class ChamCongBuRequest
{
    public string MaNV { get; set; } = string.Empty;
    public string MaCa { get; set; } = string.Empty;
    public string NgayLam { get; set; } = string.Empty;
    public string? GioCheckIn { get; set; }
    public string? GioCheckOut { get; set; }
    public string TrangThai { get; set; } = "DungGio";
    public double SoGioLam { get; set; } = 4.0;
}

public class UpdateTrangThaiDonRequest
{
    public string TrangThaiDuyet { get; set; } = "DaDuyet";
}

public class UpdateGpsVanPhongRequest
{
    public double ViDoCongTy { get; set; }
    public double KinhDoCongTy { get; set; }
    public double BanKinhChoPhep { get; set; } = 50.0;
    public string? MaCa { get; set; }
}

public class ValidateQrRequest
{
    public string MaQRDong { get; set; } = string.Empty;
}
