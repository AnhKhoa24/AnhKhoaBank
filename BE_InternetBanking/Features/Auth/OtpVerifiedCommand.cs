using MediatR;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Features.Auth
{
    public class OtpVerifiedCommand : IRequest<OTPResponse>
    {
        public string Email { get; set; } = null!;
        public string Otp { get; set; } = null!;
        public string DeviceInfo { get; set; } = null!;
        public string FcmToken { get; set; } = null!;
    }
}
