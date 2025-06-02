using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Notification
{
    public class GetHistoryNotificationCommand : IRequest<GetHistoryNotificationResponse>
    {
        public Guid AccountId { get; set; }

        public GetHistoryNotificationCommand(Guid AccountId)
        {
            this.AccountId = AccountId;
        }
    }
}
