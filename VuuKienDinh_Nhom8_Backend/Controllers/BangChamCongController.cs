using Microsoft.AspNetCore.Mvc;
using VuuKienDinh_Nhom8.Models;
using VuuKienDinh_Nhom8.Services;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BangChamCongController(ChamCongDataStore store) : ControllerBase
{
    [HttpGet]
    public IActionResult GetAll([FromQuery] string? trangThai = null, [FromQuery] string? tuKhoa = null)
    {
        var query = store.DanhSachBangChamCong.AsEnumerable();
        if (!string.IsNullOrWhiteSpace(trangThai) && !trangThai.Equals("TatCa", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(c => c.TrangThai.Equals(trangThai.Trim(), StringComparison.OrdinalIgnoreCase));
        }
        if (!string.IsNullOrWhiteSpace(tuKhoa))
        {
            var q = tuKhoa.Trim();
            query = query.Where(c =>
                c.HoTenNV.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                c.MaNV.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                c.TenCa.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                c.NgayLam.Contains(q, StringComparison.OrdinalIgnoreCase));
        }
        return Ok(query.ToList());
    }

    [HttpGet("NhanVien/{maNV}")]
    public IActionResult GetByNhanVien(string maNV)
    {
        var list = store.DanhSachBangChamCong
            .Where(c => c.MaNV.Equals(maNV, StringComparison.OrdinalIgnoreCase))
            .OrderByDescending(c => c.NgayLam)
            .ToList();
        return Ok(list);
    }

    [HttpPost("CheckInQr")]
    public IActionResult CheckInQr([FromBody] CheckInQrRequest request)
    {
        if (!request.DaXacThucVanTay)
        {
            return BadRequest(new { Success = false, Message = "Vui lòng xác thực Vân tay trước khi chấm công!" });
        }

        var nhanVien = store.DanhSachNguoiDung.FirstOrDefault(u =>
            u.MaNV.Equals(request.MaNV, StringComparison.OrdinalIgnoreCase));
        if (nhanVien is null) return NotFound(new { Success = false, Message = "Không tìm thấy nhân viên!" });

        var caLamViec = store.DanhSachCaLamViec.FirstOrDefault(c =>
            c.MaCa.Equals(request.MaCa, StringComparison.OrdinalIgnoreCase))
            ?? store.DanhSachCaLamViec.First();

        double distanceMeters = request.KhoangCachMet ?? 10.5;
        if (request.ViDoNhanVien.HasValue && request.KinhDoNhanVien.HasValue)
        {
            distanceMeters = ChamCongDataStore.CalculateDistanceMeters(
                request.ViDoNhanVien.Value,
                request.KinhDoNhanVien.Value,
                caLamViec.ViDoCongTy,
                caLamViec.KinhDoCongTy);
        }

        var maxRadius = caLamViec.BanKinhChoPhep > 0 ? caLamViec.BanKinhChoPhep : 50.0;
        if (distanceMeters > maxRadius)
        {
            return BadRequest(new
            {
                Success = false,
                Message = $"Bạn đang ở ngoài khu vực văn phòng công ty! ({distanceMeters}m > {maxRadius}m)"
            });
        }

        if (!store.ValidateDynamicQr(request.MaQRDong))
        {
            return BadRequest(new { Success = false, Message = "Mã QR không hợp lệ hoặc đã hết hạn 15 giây!" });
        }

        var deviceId = string.IsNullOrWhiteSpace(request.MaThietBiChamCong)
            ? nhanVien.MaThietBi
            : request.MaThietBiChamCong.Trim();

        var fraudRecord = store.CheckDeviceIdFraudToday(deviceId, nhanVien.MaNV);
        if (fraudRecord is not null)
        {
            return BadRequest(new
            {
                Success = false,
                Message = $"CẢNH BÁO GIAN LẬN: Thiết bị này đã được dùng để chấm công cho nhân viên {fraudRecord.HoTenNV} trong hôm nay!"
            });
        }

        var record = store.CheckIn(nhanVien, caLamViec, distanceMeters, deviceId);
        return Ok(record);
    }

    [HttpPost("CheckOutQr")]
    public IActionResult CheckOutQr([FromBody] CheckOutQrRequest request)
    {
        var updated = store.CheckOut(request.MaChamCong, request.KhoangCachMet, request.MaThietBiChamCong);
        return updated is null ? NotFound() : Ok(updated);
    }

    [HttpPost("ChamCongBu")]
    public IActionResult AddChamCongBu([FromBody] ChamCongBuRequest request)
    {
        var nhanVien = store.DanhSachNguoiDung.FirstOrDefault(u => u.MaNV.Equals(request.MaNV, StringComparison.OrdinalIgnoreCase));
        var caLamViec = store.DanhSachCaLamViec.FirstOrDefault(c => c.MaCa.Equals(request.MaCa, StringComparison.OrdinalIgnoreCase));
        if (nhanVien is null || caLamViec is null) return BadRequest();

        var isVangMat = request.TrangThai.Equals("VangMat", StringComparison.OrdinalIgnoreCase);
        var soGio = isVangMat ? 0.0 : request.SoGioLam;
        var tienCong = isVangMat ? 0.0 : Math.Round(soGio * nhanVien.LuongTheoGio * caLamViec.HeSoLuong, 0);

        var record = new BangChamCong
        {
            MaChamCong = $"CC_BU_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            MaNV = nhanVien.MaNV,
            HoTenNV = nhanVien.HoTen,
            MaCa = caLamViec.MaCa,
            TenCa = caLamViec.TenCa,
            NgayLam = request.NgayLam,
            GioCheckIn = isVangMat ? null : request.GioCheckIn,
            GioCheckOut = isVangMat ? null : request.GioCheckOut,
            SoGioLam = soGio,
            TrangThai = request.TrangThai,
            KhoangCachMet = 0.0,
            TienCongNgay = tienCong,
            MaThietBiChamCong = "HR_CHAM_CONG_BU"
        };
        store.DanhSachBangChamCong.Insert(0, record);
        return Ok(record);
    }

    [HttpPut("{maChamCong}")]
    public IActionResult Update(string maChamCong, [FromBody] BangChamCong updatedRecord)
    {
        var idx = store.DanhSachBangChamCong.FindIndex(c => c.MaChamCong.Equals(maChamCong, StringComparison.OrdinalIgnoreCase));
        if (idx == -1) return NotFound();
        updatedRecord.MaChamCong = maChamCong;
        store.DanhSachBangChamCong[idx] = updatedRecord;
        return Ok(updatedRecord);
    }

    [HttpDelete("{maChamCong}")]
    public IActionResult Delete(string maChamCong)
    {
        var record = store.DanhSachBangChamCong.FirstOrDefault(c => c.MaChamCong.Equals(maChamCong, StringComparison.OrdinalIgnoreCase));
        if (record is null) return NotFound();
        store.DanhSachBangChamCong.Remove(record);
        return Ok(new { Success = true });
    }
}
