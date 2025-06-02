using System;
using System.Collections.Generic;

namespace BE_InternetBanking.Models.Entities;

public partial class DailyAccountSeq
{
    public DateOnly DateToday { get; set; }

    public int LastSeq { get; set; }
}
