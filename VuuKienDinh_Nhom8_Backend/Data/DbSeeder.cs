using BCrypt.Net;
using VuuKienDinh_Nhom8.Models;
using Microsoft.EntityFrameworkCore;

namespace VuuKienDinh_Nhom8.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(ApplicationDbContext db, IConfiguration configuration)
    {
        await db.Database.EnsureCreatedAsync();
        if (!await db.Users.AnyAsync())
        {
            var email = configuration["SeedAdmin:Email"] ?? "admin@example.com";
            var password = configuration["SeedAdmin:Password"] ?? "Admin@12345";
            db.Users.AddRange(
                new AppUser
                {
                    FullName = "System Administrator",
                    Email = email.ToLowerInvariant(),
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
                    Role = UserRole.Admin,
                    IsEmailVerified = true
                },
                new AppUser
                {
                    FullName = "Trần Thị Mai Phương (Quản lý HR)",
                    Email = "ql01.hr@enterprise.vn",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123"),
                    Role = UserRole.Manager,
                    IsEmailVerified = true
                },
                new AppUser
                {
                    FullName = "2380600509 - Vưu Kiên Định",
                    Email = "vuukiendinh.2380600509@hutech.edu.vn",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("123"),
                    Role = UserRole.Employee,
                    IsEmailVerified = true
                }
            );
        }

        if (!await db.WorkShifts.AnyAsync())
        {
            db.WorkShifts.AddRange(
                new WorkShift { Name = "Ca Sáng (CA01)", StartTime = new TimeSpan(8, 0, 0), EndTime = new TimeSpan(12, 0, 0) },
                new WorkShift { Name = "Ca Chiều (CA02)", StartTime = new TimeSpan(13, 0, 0), EndTime = new TimeSpan(17, 0, 0) },
                new WorkShift { Name = "Ca Hành Chính (CA03)", StartTime = new TimeSpan(8, 0, 0), EndTime = new TimeSpan(17, 0, 0) }
            );
        }

        await db.SaveChangesAsync();
    }
}
