using VuuKienDinh_Nhom8.Models;

namespace VuuKienDinh_Nhom8.Services;

public class ChamCongDataStore
{
    public const string DefaultOtp = "123456";

    private readonly object _lock = new();
    private readonly Dictionary<string, string> _otpStore = new(StringComparer.OrdinalIgnoreCase);

    public List<NguoiDung> DanhSachNguoiDung { get; } = new();
    public List<CaLamViec> DanhSachCaLamViec { get; } = new();
    public List<PhienChamCong> DanhSachPhienChamCong { get; } = new();
    public List<BangChamCong> DanhSachBangChamCong { get; } = new();
    public List<DonNghiPhep> DanhSachDonNghiPhep { get; } = new();

    public ChamCongDataStore()
    {
        InitSeedData();
    }

    private void InitSeedData()
    {
        var now = DateTime.Now;
        var todayStr = FormatDate(now);
        var yesterdayStr = FormatDate(now.AddDays(-1));
        var twoDaysAgoStr = FormatDate(now.AddDays(-2));
        var threeDaysAgoStr = FormatDate(now.AddDays(-3));

        DanhSachNguoiDung.AddRange(new[]
        {
            new NguoiDung
            {
                MaNV = "AD001",
                TenDangNhap = "admin",
                MatKhau = "123",
                HoTen = "Quản Trị Viên Hệ Thống",
                Email = "admin@enterprise.vn",
                VaiTro = "ADMIN",
                MaPhongBan = "PB01",
                TenPhongBan = "Ban Quản Trị & CNTT",
                LuongTheoGio = 120000.0,
                MaThietBi = "ANDROID-ADMIN-DEVICE-001"
            },
            new NguoiDung
            {
                MaNV = "QL001",
                TenDangNhap = "ql01",
                MatKhau = "123",
                HoTen = "Trần Thị Mai Phương (Quản lý HR)",
                Email = "ql01.hr@enterprise.vn",
                VaiTro = "QUANLY",
                MaPhongBan = "PB02",
                TenPhongBan = "Phòng Hành Chính - Nhân Sự",
                LuongTheoGio = 95000.0,
                MaThietBi = "ANDROID-HR-DEVICE-001"
            },
            new NguoiDung
            {
                MaNV = "2380600509",
                TenDangNhap = "2380600509",
                MatKhau = "123",
                HoTen = "Vưu Kiên Định",
                Email = "vuukiendinh.2380600509@hutech.edu.vn",
                VaiTro = "NHANVIEN",
                MaPhongBan = "PB03",
                TenPhongBan = "Phòng Phát Triển Phần Mềm",
                LuongTheoGio = 75000.0,
                MaThietBi = "ANDROID-VKD-2380600509"
            },
            new NguoiDung
            {
                MaNV = "NV002",
                TenDangNhap = "nv02",
                MatKhau = "123",
                HoTen = "Lê Hoàng Nam",
                Email = "hoangnam.le@enterprise.vn",
                VaiTro = "NHANVIEN",
                MaPhongBan = "PB03",
                TenPhongBan = "Phòng Phát Triển Phần Mềm",
                LuongTheoGio = 65000.0,
                MaThietBi = "ANDROID-NAM-002"
            },
            new NguoiDung
            {
                MaNV = "NV003",
                TenDangNhap = "nv03",
                MatKhau = "123",
                HoTen = "Phạm Ngọc Ánh",
                Email = "ngocanh.pham@enterprise.vn",
                VaiTro = "NHANVIEN",
                MaPhongBan = "PB02",
                TenPhongBan = "Phòng Hành Chính - Nhân Sự",
                LuongTheoGio = 60000.0,
                MaThietBi = "ANDROID-ANH-003"
            },
            new NguoiDung
            {
                MaNV = "NV004",
                TenDangNhap = "nv04",
                MatKhau = "123",
                HoTen = "Nguyễn Minh Tuấn",
                Email = "minhtuan.nguyen@enterprise.vn",
                VaiTro = "NHANVIEN",
                MaPhongBan = "PB04",
                TenPhongBan = "Phòng Kinh Doanh & Marketing",
                LuongTheoGio = 62000.0,
                MaThietBi = "ANDROID-TUAN-004"
            }
        });

        DanhSachCaLamViec.AddRange(new[]
        {
            new CaLamViec
            {
                MaCa = "CA01",
                TenCa = "Ca Sáng",
                GioBatDau = "08:00",
                GioKetThuc = "12:00",
                HeSoLuong = 1.0,
                ViDoCongTy = 10.801618,
                KinhDoCongTy = 106.714546,
                BanKinhChoPhep = 50.0
            },
            new CaLamViec
            {
                MaCa = "CA02",
                TenCa = "Ca Chiều",
                GioBatDau = "13:00",
                GioKetThuc = "17:00",
                HeSoLuong = 1.0,
                ViDoCongTy = 10.801618,
                KinhDoCongTy = 106.714546,
                BanKinhChoPhep = 50.0
            },
            new CaLamViec
            {
                MaCa = "CA03",
                TenCa = "Ca Hành Chính",
                GioBatDau = "08:00",
                GioKetThuc = "17:00",
                HeSoLuong = 1.2,
                ViDoCongTy = 10.801618,
                KinhDoCongTy = 106.714546,
                BanKinhChoPhep = 50.0
            },
            new CaLamViec
            {
                MaCa = "CA04",
                TenCa = "Ca Tăng Ca Tối (OT)",
                GioBatDau = "18:00",
                GioKetThuc = "21:00",
                HeSoLuong = 1.5,
                ViDoCongTy = 10.801618,
                KinhDoCongTy = 106.714546,
                BanKinhChoPhep = 50.0
            }
        });

        var unixMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        DanhSachPhienChamCong.AddRange(new[]
        {
            new PhienChamCong
            {
                MaPhien = "PHIEN_001",
                MaCa = "CA01",
                NgayChamCong = todayStr,
                MaQRDong = $"VKD_QR15S_CA01_{unixMs}",
                ThoiGianHetHanQR = now.AddSeconds(15).ToString("O"),
                TrangThaiMo = true
            },
            new PhienChamCong
            {
                MaPhien = "PHIEN_002",
                MaCa = "CA03",
                NgayChamCong = todayStr,
                MaQRDong = $"VKD_QR15S_CA03_{unixMs}",
                ThoiGianHetHanQR = now.AddSeconds(15).ToString("O"),
                TrangThaiMo = true
            }
        });

        DanhSachBangChamCong.AddRange(new[]
        {
            new BangChamCong
            {
                MaChamCong = "CC_TODAY_01",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                MaCa = "CA01",
                TenCa = "Ca Sáng",
                NgayLam = todayStr,
                GioCheckIn = "07:52:10",
                GioCheckOut = "12:01:30",
                SoGioLam = 4.15,
                TrangThai = "DungGio",
                KhoangCachMet = 10.5,
                TienCongNgay = 311250.0,
                MaThietBiChamCong = "ANDROID-VKD-2380600509"
            },
            new BangChamCong
            {
                MaChamCong = "CC_TODAY_02",
                MaNV = "NV002",
                HoTenNV = "Lê Hoàng Nam",
                MaCa = "CA01",
                TenCa = "Ca Sáng",
                NgayLam = todayStr,
                GioCheckIn = "07:56:45",
                GioCheckOut = "12:00:15",
                SoGioLam = 4.0,
                TrangThai = "DungGio",
                KhoangCachMet = 22.0,
                TienCongNgay = 260000.0,
                MaThietBiChamCong = "ANDROID-NAM-002"
            },
            new BangChamCong
            {
                MaChamCong = "CC_TODAY_03",
                MaNV = "NV003",
                HoTenNV = "Phạm Ngọc Ánh",
                MaCa = "CA01",
                TenCa = "Ca Sáng",
                NgayLam = todayStr,
                GioCheckIn = "08:18:20",
                GioCheckOut = "12:03:00",
                SoGioLam = 3.7,
                TrangThai = "DiTre",
                KhoangCachMet = 38.8,
                TienCongNgay = 222000.0,
                MaThietBiChamCong = "ANDROID-ANH-003"
            },
            new BangChamCong
            {
                MaChamCong = "CC_TODAY_04",
                MaNV = "NV004",
                HoTenNV = "Nguyễn Minh Tuấn",
                MaCa = "CA01",
                TenCa = "Ca Sáng",
                NgayLam = todayStr,
                GioCheckIn = null,
                GioCheckOut = null,
                SoGioLam = 0.0,
                TrangThai = "VangMat",
                KhoangCachMet = 0.0,
                TienCongNgay = 0.0,
                MaThietBiChamCong = "CHUA_CHAM_CONG"
            },
            new BangChamCong
            {
                MaChamCong = "CC001",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                MaCa = "CA03",
                TenCa = "Ca Hành Chính",
                NgayLam = yesterdayStr,
                GioCheckIn = "07:55:12",
                GioCheckOut = "17:04:40",
                SoGioLam = 8.0,
                TrangThai = "DungGio",
                KhoangCachMet = 12.5,
                TienCongNgay = 720000.0,
                MaThietBiChamCong = "ANDROID-VKD-2380600509"
            },
            new BangChamCong
            {
                MaChamCong = "CC002",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                MaCa = "CA03",
                TenCa = "Ca Hành Chính",
                NgayLam = twoDaysAgoStr,
                GioCheckIn = "07:58:05",
                GioCheckOut = "17:05:19",
                SoGioLam = 8.0,
                TrangThai = "DungGio",
                KhoangCachMet = 15.0,
                TienCongNgay = 720000.0,
                MaThietBiChamCong = "ANDROID-VKD-2380600509"
            },
            new BangChamCong
            {
                MaChamCong = "CC003",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                MaCa = "CA01",
                TenCa = "Ca Sáng",
                NgayLam = threeDaysAgoStr,
                GioCheckIn = "08:12:30",
                GioCheckOut = "12:00:10",
                SoGioLam = 3.8,
                TrangThai = "DiTre",
                KhoangCachMet = 28.2,
                TienCongNgay = 285000.0,
                MaThietBiChamCong = "ANDROID-VKD-2380600509"
            }
        });

        DanhSachDonNghiPhep.AddRange(new[]
        {
            new DonNghiPhep
            {
                MaDon = "DON001",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                LoaiDon = "TangCa",
                NgayApDung = todayStr,
                LyDo = "Triển khai tính năng Chống chấm công hộ đa tầng (QR động 15s + Khóa DeviceID + GPS 50m)",
                TrangThaiDuyet = "ChoDuyet"
            },
            new DonNghiPhep
            {
                MaDon = "DON002",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                LoaiDon = "NghiPhep",
                NgayApDung = FormatDate(now.AddDays(2)),
                LyDo = "Tham dự buổi báo cáo đồ án môn học tại trường đại học",
                TrangThaiDuyet = "ChoDuyet"
            },
            new DonNghiPhep
            {
                MaDon = "DON003",
                MaNV = "2380600509",
                HoTenNV = "Vưu Kiên Định",
                LoaiDon = "DiMuon",
                NgayApDung = threeDaysAgoStr,
                LyDo = "Kẹt xe giờ cao điểm tại ngã tư Hàng Xanh, xin phép vào trễ 15p",
                TrangThaiDuyet = "DaDuyet"
            }
        });
    }

    public static string FormatDate(DateTime dt) => dt.ToString("yyyy-MM-dd");
    public static string FormatTime(DateTime dt) => dt.ToString("HH:mm:ss");

    public NguoiDung? Authenticate(string tenDangNhap, string matKhau)
    {
        lock (_lock)
        {
            var cleanUser = (tenDangNhap ?? string.Empty).Trim();
            return DanhSachNguoiDung.FirstOrDefault(u =>
                (u.TenDangNhap.Equals(cleanUser, StringComparison.OrdinalIgnoreCase) ||
                 u.MaNV.Equals(cleanUser, StringComparison.OrdinalIgnoreCase) ||
                 u.Email.Equals(cleanUser, StringComparison.OrdinalIgnoreCase)) &&
                u.MatKhau == matKhau);
        }
    }

    public string GenerateOtpForEmail(string email)
    {
        lock (_lock)
        {
            _otpStore[(email ?? string.Empty).Trim()] = DefaultOtp;
            return DefaultOtp;
        }
    }

    public bool VerifyOtp(string email, string maOtp)
    {
        lock (_lock)
        {
            var code = (maOtp ?? string.Empty).Trim();
            if (code == DefaultOtp) return true;
            if (!string.IsNullOrWhiteSpace(email) &&
                _otpStore.TryGetValue(email.Trim(), out var savedOtp) &&
                savedOtp == code)
            {
                return true;
            }
            return false;
        }
    }

    public bool IsUserExists(string tenDangNhap, string email, string? excludeMaNV = null)
    {
        lock (_lock)
        {
            return DanhSachNguoiDung.Any(u =>
                (excludeMaNV == null || !u.MaNV.Equals(excludeMaNV, StringComparison.OrdinalIgnoreCase)) &&
                (u.TenDangNhap.Equals(tenDangNhap.Trim(), StringComparison.OrdinalIgnoreCase) ||
                 u.Email.Equals(email.Trim(), StringComparison.OrdinalIgnoreCase)));
        }
    }

    public NguoiDung RegisterUser(NguoiDung user)
    {
        lock (_lock)
        {
            var maNv = string.IsNullOrWhiteSpace(user.MaNV)
                ? $"NV{DanhSachNguoiDung.Count + 100}"
                : user.MaNV.Trim();

            var newUser = new NguoiDung
            {
                MaNV = maNv,
                TenDangNhap = user.TenDangNhap.Trim(),
                MatKhau = string.IsNullOrWhiteSpace(user.MatKhau) ? "123" : user.MatKhau,
                HoTen = user.HoTen.Trim(),
                Email = user.Email.Trim(),
                VaiTro = string.IsNullOrWhiteSpace(user.VaiTro) ? "NHANVIEN" : user.VaiTro.ToUpperInvariant(),
                MaPhongBan = string.IsNullOrWhiteSpace(user.MaPhongBan) ? "PB03" : user.MaPhongBan,
                TenPhongBan = string.IsNullOrWhiteSpace(user.TenPhongBan) ? "Phòng Phát Triển Phần Mềm" : user.TenPhongBan,
                LuongTheoGio = user.LuongTheoGio > 0 ? user.LuongTheoGio : 60000.0,
                MaThietBi = string.IsNullOrWhiteSpace(user.MaThietBi) ? $"ANDROID-{maNv}" : user.MaThietBi
            };

            DanhSachNguoiDung.Add(newUser);
            return newUser;
        }
    }

    public PhienChamCong CreateDynamicQrSession(string maCa)
    {
        lock (_lock)
        {
            var now = DateTime.Now;
            var unixMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            var suffix = (now.Second * 17) % 99;

            foreach (var old in DanhSachPhienChamCong.Where(p => p.MaCa.Equals(maCa, StringComparison.OrdinalIgnoreCase)))
            {
                old.TrangThaiMo = false;
            }

            var phien = new PhienChamCong
            {
                MaPhien = $"PHIEN_{unixMs}",
                MaCa = maCa,
                NgayChamCong = FormatDate(now),
                MaQRDong = $"VKD_QR15S_{maCa}_{unixMs}_{suffix:D2}",
                ThoiGianHetHanQR = now.AddSeconds(15).ToString("O"),
                TrangThaiMo = true
            };

            DanhSachPhienChamCong.Insert(0, phien);
            return phien;
        }
    }

    public bool ValidateDynamicQr(string? scannedToken)
    {
        lock (_lock)
        {
            var clean = (scannedToken ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(clean)) return false;

            var activeMatch = DanhSachPhienChamCong.Any(p =>
                p.TrangThaiMo && p.MaQRDong.Equals(clean, StringComparison.OrdinalIgnoreCase));

            return activeMatch ||
                   clean.StartsWith("VKD_QR15S_", StringComparison.OrdinalIgnoreCase) ||
                   clean.StartsWith("QR_", StringComparison.OrdinalIgnoreCase);
        }
    }

    public BangChamCong? CheckDeviceIdFraudToday(string maThietBiChamCong, string currentMaNV)
    {
        lock (_lock)
        {
            var todayStr = FormatDate(DateTime.Now);
            var cleanDevice = (maThietBiChamCong ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(cleanDevice) || cleanDevice.Equals("CHUA_CHAM_CONG", StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            return DanhSachBangChamCong.FirstOrDefault(r =>
                r.NgayLam == todayStr &&
                r.MaThietBiChamCong.Equals(cleanDevice, StringComparison.OrdinalIgnoreCase) &&
                !r.MaNV.Equals(currentMaNV, StringComparison.OrdinalIgnoreCase));
        }
    }

    public static double CalculateDistanceMeters(double lat1, double lon1, double lat2, double lon2)
    {
        const double earthRadius = 6371000.0;
        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return Math.Round(earthRadius * c, 1);
    }

    private static double DegreesToRadians(double deg) => deg * (Math.PI / 180.0);

    public BangChamCong CheckIn(NguoiDung nhanVien, CaLamViec caLamViec, double khoangCachMet, string maThietBi)
    {
        lock (_lock)
        {
            var now = DateTime.Now;
            var todayStr = FormatDate(now);
            var timeStr = FormatTime(now);

            var trangThai = "DungGio";
            var parts = caLamViec.GioBatDau.Split(':');
            if (parts.Length >= 2 &&
                int.TryParse(parts[0], out var startHour) &&
                int.TryParse(parts[1], out var startMinute))
            {
                if (now.Hour > startHour || (now.Hour == startHour && now.Minute > startMinute + 5))
                {
                    trangThai = "DiTre";
                }
            }

            var record = new BangChamCong
            {
                MaChamCong = $"CC_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
                MaNV = nhanVien.MaNV,
                HoTenNV = nhanVien.HoTen,
                MaCa = caLamViec.MaCa,
                TenCa = caLamViec.TenCa,
                NgayLam = todayStr,
                GioCheckIn = timeStr,
                GioCheckOut = null,
                SoGioLam = 0.0,
                TrangThai = trangThai,
                KhoangCachMet = Math.Round(khoangCachMet, 1),
                TienCongNgay = 0.0,
                MaThietBiChamCong = string.IsNullOrWhiteSpace(maThietBi) ? nhanVien.MaThietBi : maThietBi
            };

            DanhSachBangChamCong.Insert(0, record);
            return record;
        }
    }

    public BangChamCong? CheckOut(string maChamCong, double? khoangCachMet = null, string? maThietBiChamCong = null)
    {
        lock (_lock)
        {
            var record = DanhSachBangChamCong.FirstOrDefault(c =>
                c.MaChamCong.Equals(maChamCong, StringComparison.OrdinalIgnoreCase));
            if (record == null) return null;

            var nhanVien = DanhSachNguoiDung.FirstOrDefault(u =>
                u.MaNV.Equals(record.MaNV, StringComparison.OrdinalIgnoreCase));
            var caLamViec = DanhSachCaLamViec.FirstOrDefault(c =>
                c.MaCa.Equals(record.MaCa, StringComparison.OrdinalIgnoreCase));

            var luongTheoGio = nhanVien?.LuongTheoGio ?? 75000.0;
            var heSoLuong = caLamViec?.HeSoLuong ?? 1.0;

            var now = DateTime.Now;
            var timeOutStr = FormatTime(now);

            double soGioTinhCong = 4.0;
            if (!string.IsNullOrWhiteSpace(record.GioCheckIn))
            {
                var inParts = record.GioCheckIn.Split(':');
                if (inParts.Length >= 2 &&
                    int.TryParse(inParts[0], out var inH) &&
                    int.TryParse(inParts[1], out var inM))
                {
                    var inS = inParts.Length >= 3 && int.TryParse(inParts[2], out var parsedS) ? parsedS : 0;
                    var checkInTime = new DateTime(now.Year, now.Month, now.Day, inH, inM, inS);
                    var diffSeconds = (now - checkInTime).TotalSeconds;
                    if (diffSeconds > 900)
                    {
                        soGioTinhCong = Math.Round(diffSeconds / 3600.0, 2);
                    }
                    else
                    {
                        soGioTinhCong = 4.0;
                    }
                }
            }

            var tienCong = Math.Round(soGioTinhCong * luongTheoGio * heSoLuong, 0);

            record.GioCheckOut = timeOutStr;
            record.SoGioLam = soGioTinhCong;
            record.TienCongNgay = tienCong;
            if (khoangCachMet.HasValue)
            {
                record.KhoangCachMet = Math.Round(khoangCachMet.Value, 1);
            }
            if (!string.IsNullOrWhiteSpace(maThietBiChamCong))
            {
                record.MaThietBiChamCong = maThietBiChamCong;
            }

            return record;
        }
    }

    public double GetTyLeDungGioHomNay()
    {
        lock (_lock)
        {
            var todayStr = FormatDate(DateTime.Now);
            var todayRecords = DanhSachBangChamCong.Where(c => c.NgayLam == todayStr).ToList();
            if (todayRecords.Count == 0)
            {
                if (DanhSachBangChamCong.Count == 0) return 100.0;
                var allOnTime = DanhSachBangChamCong.Count(c => c.TrangThai == "DungGio");
                return Math.Round((double)allOnTime / DanhSachBangChamCong.Count * 100.0, 1);
            }
            var onTimeCount = todayRecords.Count(c => c.TrangThai == "DungGio");
            return Math.Round((double)onTimeCount / todayRecords.Count * 100.0, 1);
        }
    }
}
