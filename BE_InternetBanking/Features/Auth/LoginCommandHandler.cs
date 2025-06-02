using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Services.Contracts;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class LoginCommandHandler : IRequestHandler<LoginCommand, LoginResponse>
    {
        private readonly BankingContext _context;
        private readonly IMailService _mailService;
        public LoginCommandHandler(BankingContext context, IMailService mailService)
        {
            _context = context;
            _mailService = mailService;
        }
        public async Task<LoginResponse> Handle(LoginCommand request, CancellationToken cancellationToken)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Account || u.PhoneNumber == request.Account, cancellationToken);

            if (user == null)
                return new LoginResponse(false, null!, "Tài khoản không tồn tại!");

            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);

            if (!isPasswordValid)
                return new LoginResponse(false,null!, "Mật khẩu không đúng!");

            string otp = await GenerateAndSaveOtpAsync(user.Id, "otpLogin");

            _ = Task.Run(() => _mailService.SendOtpEmailAsync(user.Email!, otp));

            return new LoginResponse(true, user.Email! , "Đăng nhập thành công!");
        }
        private async Task<string> GenerateAndSaveOtpAsync(Guid userId, string sentVia, int expiryMinutes = 5)
        {
            var otp = new Random().Next(100000, 999999).ToString();

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

    }
}
