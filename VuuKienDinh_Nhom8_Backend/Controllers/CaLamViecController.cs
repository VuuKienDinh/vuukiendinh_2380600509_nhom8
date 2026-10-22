using Microsoft.AspNetCore.Mvc;
using VuuKienDinh_Nhom8.Models;
using VuuKienDinh_Nhom8.Services;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CaLamViecController(ChamCongDataStore store) : ControllerBase
{
    [HttpGet]
    public IActionResult GetAll([FromQuery] string? tenCa = null)
    {
        var query = store.DanhSachCaLamViec.AsEnumerable();
        if (!string.IsNullOrWhiteSpace(tenCa))
        {
            var q = tenCa.Trim();
            query = query.Where(c =>
                c.TenCa.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                c.MaCa.Contains(q, StringComparison.OrdinalIgnoreCase));
        }
        return Ok(query.ToList());
    }

    [HttpGet("{maCa}")]
    public IActionResult GetById(string maCa)
    {
        var ca = store.DanhSachCaLamViec.FirstOrDefault(c => c.MaCa.Equals(maCa, StringComparison.OrdinalIgnoreCase));
        return ca is null ? NotFound() : Ok(ca);
    }

    [HttpPost]
    public IActionResult Create([FromBody] CaLamViec caMoi)
    {
        if (store.DanhSachCaLamViec.Any(c => c.MaCa.Equals(caMoi.MaCa, StringComparison.OrdinalIgnoreCase)))
            return Conflict(new { Message = $"Mã ca {caMoi.MaCa} đã tồn tại!" });
        store.DanhSachCaLamViec.Add(caMoi);
        return Ok(caMoi);
    }

    [HttpPut("{maCa}")]
    public IActionResult Update(string maCa, [FromBody] CaLamViec caCapNhat)
    {
        var idx = store.DanhSachCaLamViec.FindIndex(c => c.MaCa.Equals(maCa, StringComparison.OrdinalIgnoreCase));
        if (idx == -1) return NotFound();
        caCapNhat.MaCa = maCa;
        store.DanhSachCaLamViec[idx] = caCapNhat;
        return Ok(caCapNhat);
    }

    [HttpPut("CapNhatGpsVanPhong")]
    public IActionResult UpdateOfficeGps([FromBody] UpdateGpsVanPhongRequest request)
    {
        foreach (var ca in store.DanhSachCaLamViec)
        {
            if (string.IsNullOrWhiteSpace(request.MaCa) || ca.MaCa.Equals(request.MaCa, StringComparison.OrdinalIgnoreCase))
            {
                ca.ViDoCongTy = request.ViDoCongTy;
                ca.KinhDoCongTy = request.KinhDoCongTy;
                ca.BanKinhChoPhep = request.BanKinhChoPhep > 0 ? request.BanKinhChoPhep : 50.0;
            }
        }
        return Ok(new { Success = true, Message = "Đã cập nhật tọa độ GPS văn phòng!" });
    }

    [HttpDelete("{maCa}")]
    public IActionResult Delete(string maCa)
    {
        var ca = store.DanhSachCaLamViec.FirstOrDefault(c => c.MaCa.Equals(maCa, StringComparison.OrdinalIgnoreCase));
        if (ca is null) return NotFound();
        store.DanhSachCaLamViec.Remove(ca);
        return Ok(new { Success = true });
    }
}
