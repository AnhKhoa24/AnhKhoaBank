using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Models.DTO;
namespace BE_InternetBanking.Services.Contracts
{
    public interface IUser
    {
        public Task<User> GetUserByAccountAsync(string email, string phonenumb, CancellationToken cancel);
        public Task<User?> GetUserByEmail(string email, CancellationToken cancel);
        //public Task<bool> UpdateSessionUser();
    }
}
