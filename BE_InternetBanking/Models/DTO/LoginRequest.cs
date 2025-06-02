using System.ComponentModel.DataAnnotations;

namespace BE_InternetBanking.Models.DTO
{
    public class LoginRequest
    {
        [Required]
        public string Account { get; set; } = null!;
        [Required]
        public string Password { get; set; } = null!;
    }
}
