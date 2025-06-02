using BE_InternetBanking.Models.Entities;

namespace BE_InternetBanking.Models.DTO
{
    public class TransactionHistory
    {
        public decimal? Amount { get; set; }

        public string? Message { get; set; }

        public DateTime? Timestamp { get; set; }

        public string? Status { get; set; }
    }
}
