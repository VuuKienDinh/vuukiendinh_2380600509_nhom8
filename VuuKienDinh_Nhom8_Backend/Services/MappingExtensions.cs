using VuuKienDinh_Nhom8.Contracts;
using VuuKienDinh_Nhom8.Models;

namespace VuuKienDinh_Nhom8.Services;

public static class MappingExtensions
{
    public static UserResponse ToResponse(this AppUser user) => new(user.Id, user.FullName, user.Email, user.Role, user.IsEmailVerified, user.IsActive, user.AvatarUrl, user.CreatedAtUtc);
}
