using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Transaction
{
    public class CheckAccountCommand : IRequest<CheckAccountResponse>
    {
        public string? AccountNumber { get; set; }
    }
}
