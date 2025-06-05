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
using BE_InternetBanking.Services.Contracts;

namespace BE_InternetBanking.Features.Auth
{
    public class OtpVerifiedCommandHandler : IRequestHandler<OtpVerifiedCommand, OTPResponse>
    {
        private readonly BankingContext _context;
        private readonly IConfiguration _config;
        private readonly IOtp _iotp;
        private readonly IUser _iuser;

        public OtpVerifiedCommandHandler(BankingContext context, IConfiguration config, IOtp iotp, IUser iuser)
        {
            _context = context;
            _config = config;
            _iotp = iotp;
            _iuser = iuser;
        }
        public async Task<OTPResponse> Handle(OtpVerifiedCommand request, CancellationToken cancel)
        {
            var user = await _iuser.GetUserByEmail(request.Email, cancel);
            if (user == null) return new OTPResponse(false, null! , "Account does'nt exist!", null!);

            if(!await _iotp.OtpVerified(user.Id, request.Otp)) 
                return new OTPResponse(true, null! , "Invalid OTP!", null!);

            if(user.IsEmailVerified == false)
            {
                var (isSuccess, accountNumber) = await CreateAccountAsync(user.Id, 0, "Active");
                if (isSuccess) user.IsEmailVerified = true;
            }

            var (accessToken, jti) = GenerateToken(user, DateTime.UtcNow.AddDays(2));

            var oldSessions = await _context.LoginSessions
                .Where(s => s.UserId == user.Id)
                .ToListAsync(cancel);
            _context.LoginSessions.RemoveRange(oldSessions);

            var LoginSessions = new LoginSession
            {
                UserId = user.Id,
                JtiToken = jti,
                DeviceInfo = request.DeviceInfo,
                FcmToken = request.FcmToken,
                LoginAt = GetTime.GetVietnamTime(),
                IsActive = true,
            };
            await _context.LoginSessions.AddAsync(LoginSessions);
            await _context.SaveChangesAsync();
            List<string> Roles = user.UserRoles.Select(m=>m.Role.Name!).ToList();
            return new OTPResponse(true, accessToken, "Login successfully!", Roles);
        }

        private (string Token, string Jti) GenerateToken(User user, DateTime expires)
        {
            string jti = Guid.NewGuid().ToString();
            var claims = new List<Claim>
                {
                    new Claim(JwtRegisteredClaimNames.Jti, jti),
                    new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                    new Claim(ClaimTypes.Email, user.Email!),
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Name, user.FullName!)
                };
            foreach(var role in user.UserRoles)
                claims.Add(new Claim(ClaimTypes.Role, role.Role.Name!));

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["JWT:Secret"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["JWT:ValidIssuer"],
                audience: _config["JWT:ValidAudience"],
                expires: expires,
                claims: claims,
                signingCredentials: creds
            );
            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);
            return (Token: tokenString, Jti: jti);
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
