using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class User
{
    public Guid Id { get; set; }

    public string? FullName { get; set; }

    public string? Email { get; set; }

    public string? PhoneNumber { get; set; }

    public string? PasswordHash { get; set; }

    public bool? IsEmailVerified { get; set; }

    public bool? IsPhoneVerified { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<Account> Accounts { get; set; } = new List<Account>();

    public virtual ICollection<LoginSession> LoginSessions { get; set; } = new List<LoginSession>();

    public virtual ICollection<OtpRequest> OtpRequests { get; set; } = new List<OtpRequest>();

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
