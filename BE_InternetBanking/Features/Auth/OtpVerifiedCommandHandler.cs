using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using static BE_InternetBanking.Models.DTO.ResponseServies;
using BE_InternetBanking.Services.Helper;

namespace BE_InternetBanking.Features.Auth
{
    public class OtpVerifiedCommandHandler : IRequestHandler<OtpVerifiedCommand, OTPResponse>
    {
        private readonly BankingContext _context;
        private readonly IConfiguration _config;
        public OtpVerifiedCommandHandler(BankingContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }
        public async Task<OTPResponse> Handle(OtpVerifiedCommand request, CancellationToken cancellationToken)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

            if (user == null)
                return new OTPResponse(false, null! ,"Tài khoản không tồn tại!");

            var otp = await _context.OtpRequests
                .Where(o => o.UserId == user.Id
                 && o.OtpCode == request.Otp
                 && o.IsUsed == false
                 && o.ExpiredAt > DateTime.UtcNow)
                .OrderByDescending(o => o.CreatedAt)
                .FirstOrDefaultAsync();
            if (otp == null)
                return new OTPResponse(false, null!, "Mã OTP không hợp lệ hoặc đã hết hạn");

            otp.IsUsed = true;
            if(user.IsEmailVerified == false)
            {
                var (isSuccess, accountNumber) = await CreateAccountAsync(user.Id, 0, "Active");
                if (isSuccess) user.IsEmailVerified = true;
            }    
            
            string token = GenerateToken(user);

            var oldSessions = await _context.LoginSessions
                .Where(s => s.UserId == user.Id)
                .ToListAsync(cancellationToken);
            _context.LoginSessions.RemoveRange(oldSessions);

            var LoginSessions = new LoginSession
            {
                UserId = user.Id,
                JwtToken = token,
                DeviceInfo = request.DeviceInfo,
                FcmToken = request.FcmToken,
                LoginAt = GetTime.GetVietnamTime(),
                IsActive = true,
            };
            await _context.LoginSessions.AddAsync(LoginSessions);
            await _context.SaveChangesAsync();
            return new OTPResponse(true, token, "Đăng nhập thành công!");
        }
        private string GenerateToken(User user)
        {
            var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Email, user.Email!),
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Role, "USER"),
                    new Claim(ClaimTypes.Name, user.FullName!)
                };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["JWT:Secret"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["JWT:ValidIssuer"],
                audience: _config["JWT:ValidAudience"],
                expires: DateTime.UtcNow.AddDays(2),
                claims: claims,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        private async Task<(bool isSuccess, string? accountNumber)> CreateAccountAsync(Guid userId, decimal balance, string status)
        {
            var accountNumberParam = new SqlParameter
            {
                ParameterName = "@AccountNumber",
                SqlDbType = System.Data.SqlDbType.VarChar,
                Size = 20,
                Direction = System.Data.ParameterDirection.Output
            };

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC CreateAccount @UserId = {0}, @Balance = {1}, @Status = {2}, @AccountNumber = @AccountNumber OUTPUT",
                userId, balance, status, accountNumberParam
            );

            string? accNumber = accountNumberParam.Value?.ToString();
            return (!string.IsNullOrEmpty(accNumber), accNumber);
        }
    }
}
