using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class OtpRequest
{
    public Guid Id { get; set; }

    public Guid? UserId { get; set; }

    public string? OtpCode { get; set; }

    public DateTime? ExpiredAt { get; set; }

    public bool? IsUsed { get; set; }

    public string? SentVia { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual User? User { get; set; }
}
