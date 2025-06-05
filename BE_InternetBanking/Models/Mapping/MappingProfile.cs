using AutoMapper;
using BE_InternetBanking.Features.Auth;
using BE_InternetBanking.Features.Transaction;
using BE_InternetBanking.Models.DTO;
using BE_InternetBanking.Models.Entities;

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

            CreateMap<RegisterCommand, User>()
           .ForMember(dest => dest.Id,
                      opt => opt.MapFrom(_ => Guid.NewGuid()))
           .ForMember(dest => dest.PasswordHash,
                      opt => opt.MapFrom(src => BCrypt.Net.BCrypt.HashPassword(src.Password)))
           .ForMember(dest => dest.IsEmailVerified,
                      opt => opt.MapFrom(_ => false))
           .ForMember(dest => dest.CreatedAt,
                      opt => opt.MapFrom(_ => DateTime.UtcNow));

        }
    }
}
