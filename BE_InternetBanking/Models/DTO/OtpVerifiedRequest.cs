using System.ComponentModel.DataAnnotations;

namespace BE_InternetBanking.Models.DTO
{
    public class OtpVerifiedRequest
    {
        [Required, EmailAddress]
        public string Email { get; set; } = null!;
        [Required]
        public string Otp { get; set; } = null!;
        [Required]
        public string DeviceInfo { get; set; } = null!;
        [Required]
        public string FcmToken { get; set; } = null!;
    }
}
