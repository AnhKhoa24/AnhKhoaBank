namespace BE_InternetBanking.Services.Contracts
{
    public interface IOtp
    {
        public Task<string> GenerateAndSaveOtpAsync(Guid userId, string sentVia, int expiryMinutes = 5);
        public Task<bool> OtpVerified(Guid userId, string Otp);
    }
}

