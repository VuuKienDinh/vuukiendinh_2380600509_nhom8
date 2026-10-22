using Microsoft.AspNetCore.Mvc;
using VuuKienDinh_Nhom8.Models;
using VuuKienDinh_Nhom8.Services;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PhienChamCongController(ChamCongDataStore store) : ControllerBase
{
    [HttpGet]
    public IActionResult GetAll() => Ok(store.DanhSachPhienChamCong);

    [HttpGet("HienTai/{maCa}")]
    public IActionResult GetCurrentByShift(string maCa)
    {
        var phien = store.DanhSachPhienChamCong.FirstOrDefault(p =>
            p.MaCa.Equals(maCa, StringComparison.OrdinalIgnoreCase) && p.TrangThaiMo)
            ?? store.CreateDynamicQrSession(maCa);
        return Ok(phien);
    }

    [HttpPost("PhatMaQrDong/{maCa}")]
    public IActionResult GenerateDynamicQr(string maCa)
    {
        var phien = store.CreateDynamicQrSession(maCa);
        return Ok(phien);
    }

    [HttpPost("KiemTraQr")]
    public IActionResult ValidateQr([FromBody] ValidateQrRequest request)
    {
        var valid = store.ValidateDynamicQr(request.MaQRDong);
        return Ok(new { Valid = valid, MaQRDong = request.MaQRDong });
    }
}
