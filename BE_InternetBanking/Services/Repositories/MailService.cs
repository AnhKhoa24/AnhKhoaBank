using BE_InternetBanking.Services.Contracts;
using System.Net.Mail;
using System.Net;

namespace BE_InternetBanking.Services.Repositories
{
    public class MailService : IMailService
    {
        private readonly IConfiguration _config;

        public MailService(IConfiguration config)
        {
            _config = config;
        }
        public async Task SendOtpEmailAsync(string toEmail, string otp)
        {
            var smtpClient = new SmtpClient(_config["Mail:SmtpHost"])
            {
                Port = int.Parse(_config["Mail:Port"]!),
                Credentials = new NetworkCredential(_config["Mail:Username"], _config["Mail:Password"]),
                EnableSsl = true,
            };

            var mail = new MailMessage
            {
                From = new MailAddress(_config["Mail:From"]!),
                Subject = "Mã OTP Đăng Nhập",
                Body = $"Mã OTP của bạn là: {otp}",
                IsBodyHtml = false,
            };
            mail.To.Add(toEmail);

            await smtpClient.SendMailAsync(mail);
        }
    }
}
