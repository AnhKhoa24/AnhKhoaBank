using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Transaction
{
    public class TransactionHistoryCommand : IRequest<TransactionHistoryResponse>
    {
        public Guid? FromAccountId { get; set; }
        public TransactionHistoryCommand(Guid? FromAccountId)
        {
            this.FromAccountId = FromAccountId; 
        }
    }
}
