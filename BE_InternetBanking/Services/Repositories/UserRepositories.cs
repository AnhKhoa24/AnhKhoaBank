using Azure.Core;
using BE_InternetBanking.Models.DTO;
using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Services.Contracts;
using Microsoft.EntityFrameworkCore;
using System.Threading;

namespace BE_InternetBanking.Services.Repositories
{
    public class UserRepositories : IUser
    {
        private readonly BankingContext _context;

        public UserRepositories(BankingContext context) 
        {
            _context = context;
        }
        public async Task<User> GetUserByAccountAsync(string email, string phonenumb, CancellationToken cancel)
        {
            var user = await _context.Users
                .Include(x=>x.UserRoles)
                .FirstOrDefaultAsync(
                    u => u.Email == email || u.PhoneNumber == phonenumb,
                    cancel);
            if (user == null) return null!;
            return user;
        }

        public async Task<User?> GetUserByEmail(string email, CancellationToken cancel)
        {
            return await _context.Users
                .Include(u => u.UserRoles)                     
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Email == email, cancel);
        }
    }
}
