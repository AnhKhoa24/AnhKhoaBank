namespace BE_InternetBanking.Services.Contracts
{
    public interface IMailService
    {
        Task SendOtpEmailAsync(string toEmail, string otp);
    }

}
