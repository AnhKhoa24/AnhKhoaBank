using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class LoginCommand : IRequest<LoginResponse>
    {
        public string Account = null!;
        public string Password = null!; 
    }
}
