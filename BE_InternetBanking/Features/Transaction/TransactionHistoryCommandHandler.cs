using BE_InternetBanking.Models.DTO;
using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Transaction
{
    public class TransactionHistoryCommandHandler : IRequestHandler<TransactionHistoryCommand, TransactionHistoryResponse>
    {
        private readonly BankingContext _context;

        public TransactionHistoryCommandHandler(BankingContext context)
        {
            _context = context;
        }
        public async Task<TransactionHistoryResponse> Handle(TransactionHistoryCommand request, CancellationToken cancellationToken)
        {
            var reslt = await _context.TransactionBankings
                .Where(m=>m.FromAccountId == request.FromAccountId)
                .Select(x => new TransactionHistory
                {
                    Amount = x.Amount,
                    Message = x.Message,
                    Timestamp = x.Timestamp,
                    Status = x.Status,
                }).ToListAsync();
            return new TransactionHistoryResponse(true, "Thành công!", reslt);
        }
    }
}
