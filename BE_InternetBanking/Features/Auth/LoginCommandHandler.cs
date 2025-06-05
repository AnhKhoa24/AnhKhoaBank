using Azure.Core;
using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Services.Contracts;
using BE_InternetBanking.Services.Helper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class LoginCommandHandler : IRequestHandler<LoginCommand, LoginResponse>
    {
        private readonly BankingContext _context;
        private readonly IMailService _mailService;
        private readonly IUser _isuer;
        private readonly IOtp _iOtp;

        public LoginCommandHandler(BankingContext context, IMailService mailService, IUser isuer, IOtp iOtp)
        {
            _context = context;
            _mailService = mailService;
            _isuer = isuer;
            _iOtp = iOtp;
        }
        public async Task<LoginResponse> Handle(LoginCommand request, CancellationToken cancel)
        {
            var user = await _isuer.GetUserByAccountAsync(request.Account, request.Account, cancel);
            if (user == null)
                return new LoginResponse(false, null!, "Account doesn't exist!");

            bool isPwValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
            if (!isPwValid)
                return new LoginResponse(false,null!, "Password is incorrect!");

            string otp = await _iOtp.GenerateAndSaveOtpAsync(user.Id, "Otplogin");

            _ = Task.Run(() => _mailService.SendOtpEmailAsync(user.Email!, otp));

            return new LoginResponse(true, user.Email!, $"OTP will be sent to email: {user.Email!}");
        }
    }
}
