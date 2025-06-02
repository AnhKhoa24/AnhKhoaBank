using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Feature.UserProfile
{
    public class GetProfileUserCommand : IRequest<GetProfileUserRespone>
    {
        public Guid? UserId { get; set; }
        public GetProfileUserCommand(Guid? userId)
        {
            UserId = userId;
        }
    }
}
