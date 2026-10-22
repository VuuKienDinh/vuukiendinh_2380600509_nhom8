using VuuKienDinh_Nhom8.Contracts;
using VuuKienDinh_Nhom8.Data;
using VuuKienDinh_Nhom8.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController, Authorize, Route("api/profile")]
public sealed class ProfileController(ApplicationDbContext db) : ControllerBase
{
    [HttpPut]
    public async Task<IActionResult> Update(UpdateUserRequest request, CancellationToken ct)
    {
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var id)) return Unauthorized();
        var user = await db.Users.FindAsync([id], ct);
        if (user is null) return NotFound();
        if (!string.IsNullOrWhiteSpace(request.FullName)) user.FullName = request.FullName.Trim();
        if (request.AvatarUrl is not null) user.AvatarUrl = request.AvatarUrl;
        await db.SaveChangesAsync(ct);
        return Ok(user.ToResponse());
    }
}
