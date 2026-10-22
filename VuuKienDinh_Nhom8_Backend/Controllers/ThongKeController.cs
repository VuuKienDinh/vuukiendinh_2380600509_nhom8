using Microsoft.AspNetCore.Mvc;
using VuuKienDinh_Nhom8.Services;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ThongKeController(ChamCongDataStore store) : ControllerBase
{
    [HttpGet("TongQuan")]
    public IActionResult GetOverview()
    {
        var todayStr = ChamCongDataStore.FormatDate(DateTime.Now);
        var mainStudent = store.DanhSachNguoiDung.FirstOrDefault(u => u.MaNV == "2380600509");
        var studentRecords = store.DanhSachBangChamCong.Where(c => c.MaNV == "2380600509").ToList();

        return Ok(new
        {
            SinhVienThucHien = "2380600509 - Vưu Kiên Định",
            DeTai = "Nhóm 8 - Đề số 2: Ứng dụng chấm công cho nhân viên",
            NgayHienTai = todayStr,
            TongSoNhanVien = store.DanhSachNguoiDung.Count,
            TongSoCaLamViec = store.DanhSachCaLamViec.Count,
            TyLeDungGioHomNay = store.GetTyLeDungGioHomNay(),
            SoDonChoDuyet = store.DanhSachDonNghiPhep.Count(d => d.TrangThaiDuyet == "ChoDuyet"),
            ThongTinSinhVienChinh = new
            {
                MaNV = mainStudent?.MaNV ?? "2380600509",
                HoTen = mainStudent?.HoTen ?? "Vưu Kiên Định",
                TenPhongBan = mainStudent?.TenPhongBan ?? "Phòng Phát Triển Phần Mềm",
                TongNgayCongThang = studentRecords.Count(c => c.TrangThai != "VangMat"),
                TongLuongTamTinhVND = studentRecords.Sum(c => c.TienCongNgay)
            }
        });
    }
}
