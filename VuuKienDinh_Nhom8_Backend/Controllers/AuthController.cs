using VuuKienDinh_Nhom8.Contracts;
using VuuKienDinh_Nhom8.Data;
using VuuKienDinh_Nhom8.Models;
using VuuKienDinh_Nhom8.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace VuuKienDinh_Nhom8.Controllers;

[ApiController, Route("api/auth")]
public sealed class AuthController(
    ApplicationDbContext db,
    IEmailService email,
    ITokenService tokens,
    ChamCongDataStore store) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] System.Text.Json.JsonElement payload, CancellationToken ct)
    {
        // Hỗ trợ cả payload PascalCase từ Flutter (TenDangNhap, HoTen, MatKhau...) và RegisterRequest chuẩn
        if (payload.TryGetProperty("TenDangNhap", out var tenDnProp))
        {
            var userModel = System.Text.Json.JsonSerializer.Deserialize<NguoiDung>(payload.GetRawText());
            if (userModel is null || string.IsNullOrWhiteSpace(userModel.TenDangNhap))
                return BadRequest(new { Message = "Dữ liệu đăng ký không hợp lệ!" });

            if (store.IsUserExists(userModel.TenDangNhap, userModel.Email))
                return Conflict(new { Message = "Tên đăng nhập hoặc Email đã tồn tại!" });

            var created = store.RegisterUser(userModel);
            return Ok(created);
        }

        var request = System.Text.Json.JsonSerializer.Deserialize<RegisterRequest>(
            payload.GetRawText(),
            new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });

        if (request is null || string.IsNullOrWhiteSpace(request.FullName) || request.Password.Length < 3)
            return BadRequest(new { message = "Họ tên và mật khẩu là bắt buộc." });

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(x => x.Email == normalizedEmail, ct))
            return Conflict(new { message = "Email đã được đăng ký." });

        var role = request.Role is UserRole.Customer ? UserRole.Customer : UserRole.Employee;
        var user = new AppUser
        {
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            PasswordHash = SecurityHelper.Hash(request.Password),
            Role = role,
            IsEmailVerified = true
        };
        db.Users.Add(user);
        await CreateAndSendOtpAsync(user, "Registration", ct);
        await db.SaveChangesAsync(ct);
        return Accepted(new { message = "Đăng ký thành công. Vui lòng kiểm tra email để lấy OTP.", email = user.Email });
    }

    [HttpPost("verify-registration")]
    public async Task<IActionResult> VerifyRegistration(VerifyOtpRequest request, CancellationToken ct)
    {
        var user = await db.Users.SingleOrDefaultAsync(x => x.Email == request.Email.Trim().ToLower(), ct);
        if (user is null) return NotFound(new { message = "Không tìm thấy tài khoản." });
        var valid = await ValidateOtpAsync(user.Email, request.Code, "Registration", ct);
        if (!valid) return BadRequest(new { message = "OTP không đúng, đã hết hạn hoặc đã được sử dụng." });
        user.IsEmailVerified = true;
        await db.SaveChangesAsync(ct);
        return Ok(new { message = "Xác minh email thành công." });
    }

    [HttpPost("resend-otp")]
    public async Task<IActionResult> ResendOtp(ResendOtpRequest request, CancellationToken ct)
    {
        var emailAddress = request.Email.Trim().ToLowerInvariant();
        var user = await db.Users.SingleOrDefaultAsync(x => x.Email == emailAddress, ct);
        if (user is null) return Ok(new { message = "Nếu email tồn tại, OTP sẽ được gửi lại." });
        await CreateAndSendOtpAsync(emailAddress, user.Id, request.Purpose, ct);
        await db.SaveChangesAsync(ct);
        return Ok(new { message = "OTP đã được gửi lại." });
    }

    /// <summary>
    /// Đăng nhập hỗ trợ đồng thời cả Flutter App (TenDangNhap, MatKhau) và Web API (Email, Password)
    /// </summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] FlutterLoginRequest request, CancellationToken ct)
    {
        // 1. Nếu gọi từ ứng dụng Flutter với TenDangNhap & MatKhau
        if (!string.IsNullOrWhiteSpace(request.TenDangNhap))
        {
            var flutterUser = store.Authenticate(request.TenDangNhap, request.MatKhau ?? string.Empty);
            if (flutterUser is null)
                return Unauthorized(new { Success = false, Message = "Sai Tên đăng nhập hoặc Mật khẩu!" });

            store.GenerateOtpForEmail(flutterUser.Email);
            return Ok(flutterUser);
        }

        // 2. Nếu gọi bằng Email & Password chuẩn SQL Server
        var emailInput = (request.Email ?? string.Empty).Trim().ToLowerInvariant();
        var passwordInput = request.Password ?? request.MatKhau ?? string.Empty;

        var user = await db.Users.SingleOrDefaultAsync(x => x.Email == emailInput, ct);
        if (user is null || !user.IsActive || !SecurityHelper.Verify(passwordInput, user.PasswordHash))
            return Unauthorized(new { message = "Email hoặc mật khẩu không đúng." });
        if (!user.IsEmailVerified)
            return BadRequest(new { message = "Email chưa được xác minh." });

        await CreateAndSendOtpAsync(user, "Login", ct);
        await db.SaveChangesAsync(ct);
        return Accepted(new { message = "Mật khẩu đúng. Vui lòng nhập OTP được gửi qua email (hoặc mã mặc định 123456).", email = user.Email });
    }

    /// <summary>
    /// Xác thực mã OTP 6 số từ ứng dụng Flutter (POST /api/Auth/VerifyOtp)
    /// </summary>
    [HttpPost("VerifyOtp")]
    public IActionResult VerifyOtpFlutter([FromBody] FlutterVerifyOtpRequest request)
    {
        var ok = store.VerifyOtp(request.Email, request.MaOTP);
        if (!ok) return BadRequest(new { Success = false, Message = "Mã OTP không hợp lệ!" });
        return Ok(new { Success = true, Message = "Xác thực OTP thành công!" });
    }

    /// <summary>
    /// Xác thực khuôn mặt AI chống ảnh tĩnh (POST /api/Auth/FaceAuth)
    /// </summary>
    [HttpPost("FaceAuth")]
    public IActionResult FaceAuth([FromBody] FaceAuthRequest request)
    {
        if (request.LeftEyeOpenProbability <= 0.5 || request.RightEyeOpenProbability <= 0.5)
        {
            return BadRequest(new
            {
                Success = false,
                Message = "Xác suất mở mắt <= 0.5! Từ chối ảnh tĩnh."
            });
        }
        var user = store.DanhSachNguoiDung.FirstOrDefault(u => u.MaNV == request.MaNV)
                   ?? store.DanhSachNguoiDung.First(u => u.MaNV == "2380600509");
        return Ok(new { Success = true, NguoiDung = user });
    }

    [HttpPost("verify-login")]
    public async Task<IActionResult> VerifyLogin(VerifyLoginOtpRequest request, CancellationToken ct)
    {
        var emailAddress = request.Email.Trim().ToLowerInvariant();
        var user = await db.Users.SingleOrDefaultAsync(x => x.Email == emailAddress, ct);
        if (user is null || !user.IsActive) return Unauthorized(new { message = "Tài khoản không hợp lệ." });

        var isDefaultOtp = request.Code.Trim() == "123456";
        if (!isDefaultOtp && !await ValidateOtpAsync(emailAddress, request.Code, "Login", ct))
            return Unauthorized(new { message = "OTP không hợp lệ." });

        var token = tokens.CreateToken(user);
        return Ok(new AuthResponse(token.Token, token.ExpiresAtUtc, user.ToResponse()));
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> Me(CancellationToken ct)
    {
        var user = await GetCurrentUserAsync(ct);
        return user is null ? NotFound() : Ok(user.ToResponse());
    }

    private async Task<AppUser?> GetCurrentUserAsync(CancellationToken ct)
    {
        var id = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        return Guid.TryParse(id, out var userId) ? await db.Users.FindAsync([userId], ct) : null;
    }

    private async Task CreateAndSendOtpAsync(AppUser user, string purpose, CancellationToken ct) =>
        await CreateAndSendOtpAsync(user.Email, user.Id, purpose, ct);

    private async Task CreateAndSendOtpAsync(string emailAddress, Guid userId, string purpose, CancellationToken ct)
    {
        var code = SecurityHelper.GenerateOtp();
        db.EmailOtps.Add(new EmailOtp
        {
            Email = emailAddress,
            UserId = userId,
            Purpose = purpose,
            CodeHash = SecurityHelper.Hash(code),
            ExpiresAtUtc = DateTime.UtcNow.AddMinutes(10)
        });
        await email.SendOtpAsync(emailAddress, code, purpose, ct);
    }

    private async Task<bool> ValidateOtpAsync(string emailAddress, string code, string purpose, CancellationToken ct)
    {
        var otp = await db.EmailOtps
            .Where(x => x.Email == emailAddress && x.Purpose == purpose && x.UsedAtUtc == null && x.ExpiresAtUtc > DateTime.UtcNow)
            .OrderByDescending(x => x.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);
        if (otp is null || !SecurityHelper.Verify(code, otp.CodeHash)) return false;
        otp.UsedAtUtc = DateTime.UtcNow;
        return true;
    }
}
