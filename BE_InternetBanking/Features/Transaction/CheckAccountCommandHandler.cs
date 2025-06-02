using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Transaction
{
    public class CheckAccountCommandHandler : IRequestHandler<CheckAccountCommand, CheckAccountResponse>
    {
        private readonly BankingContext _context;

        public CheckAccountCommandHandler(BankingContext context)
        {
            _context = context;
        }
        public async Task<CheckAccountResponse> Handle(CheckAccountCommand request, CancellationToken cancellationToken)
        {
            var UserAccount = await _context.Accounts.Include(a => a.User).FirstOrDefaultAsync(m => m.AccountNumber == request.AccountNumber);

            if(UserAccount == null)
            {
                return new CheckAccountResponse(false, "Tài khoản không tồn tại", null!);
            }

            return new CheckAccountResponse(true, "Thành công", UserAccount.User!.FullName!);
        }
    }
}
