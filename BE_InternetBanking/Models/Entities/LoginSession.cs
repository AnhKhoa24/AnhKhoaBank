using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class LoginSession
{
    public Guid Id { get; set; }

    public Guid? UserId { get; set; }

    public string? JtiToken { get; set; }

    public string? DeviceInfo { get; set; }

    public string? FcmToken { get; set; }

    public DateTime? LoginAt { get; set; }

    public DateTime? LogoutAt { get; set; }

    public bool? IsActive { get; set; }

    public virtual User? User { get; set; }
}
