using Microsoft.EntityFrameworkCore;
using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Services.Contracts;
using BE_InternetBanking.Services.Helper;
using static BE_InternetBanking.Models.DTO.ResponseServies;


namespace BE_InternetBanking.Services.Repositories
{
    public class OtpRepositories : IOtp
    {
        private readonly BankingContext _context;

        public OtpRepositories(BankingContext context)
        {
            _context = context;
        }
        public async Task<string> GenerateAndSaveOtpAsync(Guid userId, string sentVia, int expiryMinutes = 5)
        {
            var otp = OtpGenerator.GenerateNumericOtp(6);
            var otpRequest = new OtpRequest
            {
                UserId = userId,
                OtpCode = otp,
                CreatedAt = DateTime.UtcNow,
                ExpiredAt = DateTime.UtcNow.AddMinutes(expiryMinutes),
                IsUsed = false,
                SentVia = sentVia
            };
            _context.OtpRequests.Add(otpRequest);
            await _context.SaveChangesAsync();
            return otp;
        }

        public async Task<bool> OtpVerified(Guid userId, string Otp)
        {
            var otp = await _context.OtpRequests
                .Where(o => o.UserId == userId
                 && o.OtpCode == Otp
                 && o.IsUsed == false
                 && o.ExpiredAt > DateTime.UtcNow)
                .OrderByDescending(o => o.CreatedAt)
                .FirstOrDefaultAsync();

            if (otp == null) return false;
            otp.IsUsed = true;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
