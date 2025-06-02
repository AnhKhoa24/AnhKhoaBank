using BE_InternetBanking.Models.Entities;
using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Transaction
{
    public class TranferCommand : IRequest<TranferRespone>
    {
        public string FromAccountNumber { get; set; } = null!;

        public string ToAccountNumber { get; set; } = null!;

        public decimal Amount { get; set; }

        public string? Message { get; set; }
    }
}
