using Microsoft.AspNetCore.Mvc;
using VuuKienDinh_Nhom8.Models;
using VuuKienDinh_Nhom8.Services;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DonNghiPhepController(ChamCongDataStore store) : ControllerBase
{
    [HttpGet]
    public IActionResult GetAll([FromQuery] string? trangThaiDuyet = null)
    {
        var query = store.DanhSachDonNghiPhep.AsEnumerable();
        if (!string.IsNullOrWhiteSpace(trangThaiDuyet) && !trangThaiDuyet.Equals("TatCa", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(d => d.TrangThaiDuyet.Equals(trangThaiDuyet.Trim(), StringComparison.OrdinalIgnoreCase));
        }
        return Ok(query.ToList());
    }

    [HttpGet("NhanVien/{maNV}")]
    public IActionResult GetByNhanVien(string maNV)
    {
        var list = store.DanhSachDonNghiPhep
            .Where(d => d.MaNV.Equals(maNV, StringComparison.OrdinalIgnoreCase))
            .ToList();
        return Ok(list);
    }

    [HttpPost]
    public IActionResult Create([FromBody] DonNghiPhep newDon)
    {
        if (string.IsNullOrWhiteSpace(newDon.MaDon))
        {
            var suffix = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString();
            newDon.MaDon = $"DON{suffix[^6..]}";
        }
        newDon.TrangThaiDuyet = "ChoDuyet";
        store.DanhSachDonNghiPhep.Insert(0, newDon);
        return Ok(newDon);
    }

    [HttpPut("{maDon}")]
    public IActionResult Update(string maDon, [FromBody] DonNghiPhep updatedDon)
    {
        var existing = store.DanhSachDonNghiPhep.FirstOrDefault(d => d.MaDon.Equals(maDon, StringComparison.OrdinalIgnoreCase));
        if (existing is null) return NotFound();
        if (!existing.TrangThaiDuyet.Equals("ChoDuyet", StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { Message = "Chỉ sửa được đơn ở trạng thái ChoDuyet!" });

        existing.LoaiDon = updatedDon.LoaiDon;
        existing.NgayApDung = updatedDon.NgayApDung;
        existing.LyDo = updatedDon.LyDo;
        return Ok(existing);
    }

    [HttpPut("{maDon}/Duyet")]
    public IActionResult ApproveOrReject(string maDon, [FromBody] UpdateTrangThaiDonRequest request)
    {
        var existing = store.DanhSachDonNghiPhep.FirstOrDefault(d => d.MaDon.Equals(maDon, StringComparison.OrdinalIgnoreCase));
        if (existing is null) return NotFound();
        existing.TrangThaiDuyet = request.TrangThaiDuyet;
        return Ok(existing);
    }

    [HttpDelete("{maDon}")]
    public IActionResult Delete(string maDon)
    {
        var existing = store.DanhSachDonNghiPhep.FirstOrDefault(d => d.MaDon.Equals(maDon, StringComparison.OrdinalIgnoreCase));
        if (existing is null) return NotFound();
        store.DanhSachDonNghiPhep.Remove(existing);
        return Ok(new { Success = true });
    }
}
