using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class TransactionBanking
{
    public Guid Id { get; set; }

    public Guid? FromAccountId { get; set; }

    public Guid? ToAccountId { get; set; }

    public decimal? Amount { get; set; }

    public string? Message { get; set; }

    public DateTime? Timestamp { get; set; }

    public string? Status { get; set; }

    public virtual Account? FromAccount { get; set; }

    public virtual Account? ToAccount { get; set; }
}
