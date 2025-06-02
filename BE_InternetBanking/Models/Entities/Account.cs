using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class Account
{
    public Guid Id { get; set; }

    public Guid? UserId { get; set; }

    public string? AccountNumber { get; set; }

    public decimal? Balance { get; set; }

    public string? Status { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();

    public virtual ICollection<TransactionBanking> TransactionBankingFromAccounts { get; set; } = new List<TransactionBanking>();

    public virtual ICollection<TransactionBanking> TransactionBankingToAccounts { get; set; } = new List<TransactionBanking>();

    public virtual User? User { get; set; }
}
