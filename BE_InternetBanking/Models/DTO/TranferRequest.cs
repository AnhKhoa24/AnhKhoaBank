using System.ComponentModel.DataAnnotations;

namespace BE_InternetBanking.Models.DTO
{
    public class TranferRequest
    {
        [Required]
        public string ToAccountNumber { get; set; } = null!;
        [Required]

        public decimal Amount { get; set; }
        [Required]

        public string? Message { get; set; }
    }
}
