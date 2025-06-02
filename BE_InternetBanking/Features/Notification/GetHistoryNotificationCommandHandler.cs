using BE_InternetBanking.Feature.UserProfile;
using BE_InternetBanking.Models.DTO;
using BE_InternetBanking.Models.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Notification
{
    public class GetHistoryNotificationCommandHandler : IRequestHandler<GetHistoryNotificationCommand, GetHistoryNotificationResponse>
    {
        private readonly BankingContext _context;

        public GetHistoryNotificationCommandHandler(BankingContext context)
        {
            _context = context;
        }
        public async Task<GetHistoryNotificationResponse> Handle(GetHistoryNotificationCommand request, CancellationToken cancellationToken)
        {
            var listNotif = await _context.Messages
                .Where(m => m.AccountId == request.AccountId)
                .Select(s => new MessageDTO
                {
                    Content = s.Content,
                    CreatedAt = s.CreatedAt
                })
                .ToListAsync();
            return new GetHistoryNotificationResponse(true, "Thành công!", listNotif);
        }
    }
}
