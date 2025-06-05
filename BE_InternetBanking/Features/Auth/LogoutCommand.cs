using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class LogoutCommand : IRequest<LogoutResponse>
    {
        public Guid? UserId { get; set; }

        public string? JtiToken { get; set; }
        public LogoutCommand(Guid UserId, string JtiToken)
        {
            this.UserId = UserId;
            this.JtiToken = JtiToken;   
        }
    }
}
