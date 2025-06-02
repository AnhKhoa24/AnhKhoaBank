using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class RegisterCommandHandler : IRequestHandler<RegisterCommand, RegisterResponse>
    {
        private readonly BankingContext _context;

        public RegisterCommandHandler(BankingContext context)
        {
            _context = context;
        }
        public async Task<RegisterResponse> Handle(RegisterCommand request, CancellationToken cancellationToken)
        {
            if (await _context.Users.AnyAsync(u => u.Email == request.Email, cancellationToken))
                return new RegisterResponse(false, "Email đã được đăng ký!");

            var user = new User
            {
                Id = Guid.NewGuid(),
                FullName = request.FullName,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                IsEmailVerified = false,
                CreatedAt = DateTime.UtcNow
            };

            var role = await _context.Roles.FirstOrDefaultAsync(x => x.Name == "USER", cancellationToken);
            if (role == null)
                return new RegisterResponse(false, "Vai trò mặc định 'USER' chưa được tạo trong DB!");

            var userRole = new UserRole
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                RoleId = role.Id,
                AssignedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            _context.UserRoles.Add(userRole);

            await _context.SaveChangesAsync(cancellationToken);

            return new RegisterResponse(true, "Đăng ký thành công");
        }

    }
}
