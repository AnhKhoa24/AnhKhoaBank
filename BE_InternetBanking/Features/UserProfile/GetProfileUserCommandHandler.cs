using BE_InternetBanking.Feature.UserProfile;
using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.UserProfile
{
    public class GetProfileUserCommandHandler : IRequestHandler<GetProfileUserCommand, GetProfileUserRespone>
    {
        private readonly BankingContext _context;

        public GetProfileUserCommandHandler(BankingContext context)
        {
            _context = context;
        }
        public async Task<GetProfileUserRespone> Handle(GetProfileUserCommand request, CancellationToken cancellationToken)
        {
            var account = await _context.Accounts.FirstOrDefaultAsync(m => m.UserId == request.UserId);
            if (account == null)
            {
                return new GetProfileUserRespone(false, null!);
            }
            else
            {
                return new GetProfileUserRespone(true, account);
            }
        }
    }
}
