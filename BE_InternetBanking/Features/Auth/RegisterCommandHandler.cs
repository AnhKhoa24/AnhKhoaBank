using AutoMapper;
using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Services.Contracts;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class RegisterCommandHandler : IRequestHandler<RegisterCommand, RegisterResponse>
    {
        private readonly BankingContext _context;
        private readonly IMapper _mapper;
        private readonly IUser _iuser;

        public RegisterCommandHandler(BankingContext context, IMapper mapper, IUser iuser)
        {
            _context = context;
            _mapper = mapper;
            _iuser = iuser;
        }
        public async Task<RegisterResponse> Handle(RegisterCommand request, CancellationToken cancel)
        {
            var checkuser = await _iuser.GetUserByAccountAsync(request.Email, request.PhoneNumber, cancel);
            if (checkuser != null) return new RegisterResponse(false, "Email/phone number already exists!");

            var user = _mapper.Map<User>(request);

            var role = await GetDefaultRoleAsync(request.RoleName, cancel);
            if (role == null) return new RegisterResponse(false, $"Role '{request.RoleName}' doesn't exist!");

            var userRole = CreateUserRole(user.Id, role.Id);
            await AddUserAsync(user, userRole, cancel);
            return new RegisterResponse(true, "Registered successfully!");
        }
        private async Task<Role?> GetDefaultRoleAsync(string RoleName, CancellationToken cancel)
        {
            return await _context.Roles
                .FirstOrDefaultAsync(r => r.Name == RoleName, cancel);
        }
        private UserRole CreateUserRole(Guid userId, Guid roleId)
        {
            return new UserRole
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                RoleId = roleId,
                AssignedAt = DateTime.UtcNow
            };
        }
        private async Task AddUserAsync(User user, UserRole userRole, CancellationToken cancel)
        {
            _context.Users.Add(user);
            _context.UserRoles.Add(userRole);
            await _context.SaveChangesAsync(cancel);
        }
    }
}
