using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class Message
{
    public Guid Id { get; set; }

    public Guid AccountId { get; set; }

    public string Content { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual Account Account { get; set; } = null!;
}
