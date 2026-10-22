using Microsoft.AspNetCore.Mvc;
using VuuKienDinh_Nhom8.Models;
using VuuKienDinh_Nhom8.Services;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NguoiDungController(ChamCongDataStore store) : ControllerBase
{
    [HttpGet]
    public IActionResult GetAll([FromQuery] string? vaiTro = null, [FromQuery] string? tuKhoa = null)
    {
        var query = store.DanhSachNguoiDung.AsEnumerable();
        if (!string.IsNullOrWhiteSpace(vaiTro) && !vaiTro.Equals("TATCA", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(u => u.VaiTro.Equals(vaiTro.Trim(), StringComparison.OrdinalIgnoreCase));
        }
        if (!string.IsNullOrWhiteSpace(tuKhoa))
        {
            var q = tuKhoa.Trim();
            query = query.Where(u =>
                u.HoTen.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                u.MaNV.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                u.TenDangNhap.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                u.TenPhongBan.Contains(q, StringComparison.OrdinalIgnoreCase));
        }
        return Ok(query.ToList());
    }

    [HttpGet("{maNV}")]
    public IActionResult GetById(string maNV)
    {
        var user = store.DanhSachNguoiDung.FirstOrDefault(u => u.MaNV.Equals(maNV, StringComparison.OrdinalIgnoreCase));
        return user is null ? NotFound(new { Message = $"Không tìm thấy nhân viên {maNV}" }) : Ok(user);
    }

    [HttpPost]
    public IActionResult Create([FromBody] NguoiDung newUser)
    {
        if (store.DanhSachNguoiDung.Any(u => u.MaNV.Equals(newUser.MaNV, StringComparison.OrdinalIgnoreCase)))
            return Conflict(new { Message = $"Mã nhân viên {newUser.MaNV} đã tồn tại!" });
        store.DanhSachNguoiDung.Add(newUser);
        return Ok(newUser);
    }

    [HttpPut("{maNV}")]
    public IActionResult Update(string maNV, [FromBody] NguoiDung updatedUser)
    {
        var idx = store.DanhSachNguoiDung.FindIndex(u => u.MaNV.Equals(maNV, StringComparison.OrdinalIgnoreCase));
        if (idx == -1) return NotFound();
        updatedUser.MaNV = maNV;
        store.DanhSachNguoiDung[idx] = updatedUser;
        return Ok(updatedUser);
    }

    [HttpDelete("{maNV}")]
    public IActionResult Delete(string maNV)
    {
        var user = store.DanhSachNguoiDung.FirstOrDefault(u => u.MaNV.Equals(maNV, StringComparison.OrdinalIgnoreCase));
        if (user is null) return NotFound();
        store.DanhSachNguoiDung.Remove(user);
        return Ok(new { Success = true, Message = $"Đã xóa nhân viên {user.HoTen}" });
    }
}
