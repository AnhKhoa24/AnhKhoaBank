using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class LogoutCommandHandler : IRequestHandler<LogoutCommand, LogoutResponse>
    {
        private readonly BankingContext _context;

        public LogoutCommandHandler(BankingContext context)
        {
            _context = context;
        }
        public async Task<LogoutResponse> Handle(LogoutCommand request, CancellationToken cancel)
        {
            var loginSession = await _context.LoginSessions
                               .FirstOrDefaultAsync(m => m.UserId == request.UserId && m.JtiToken == request.JtiToken, cancel);

            if (loginSession == null) return new LogoutResponse(false, "Not found!");

            _context.LoginSessions.Remove(loginSession);
            await _context.SaveChangesAsync(cancel);

            return new LogoutResponse(true, "Signed out!");
        }
    }
}
