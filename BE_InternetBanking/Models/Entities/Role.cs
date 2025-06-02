using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class Role
{
    public Guid Id { get; set; }

    public string? Name { get; set; }

    public string? Description { get; set; }

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
