using AutoMapper;
using BE_InternetBanking.Features.Auth;
using BE_InternetBanking.Features.Transaction;
using BE_InternetBanking.Models.DTO;

namespace BE_InternetBanking.Models.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<RegisterRequest, RegisterCommand>();
            CreateMap<LoginRequest, LoginCommand>();
            CreateMap<OtpVerifiedRequest, OtpVerifiedCommand>();
            CreateMap<TranferRequest, TranferCommand>();
        }
    }
}
