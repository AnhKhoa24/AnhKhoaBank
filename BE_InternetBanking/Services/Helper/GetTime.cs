using System;

namespace BE_InternetBanking.Services.Helper
{
    public static class GetTime
    {
        public static DateTime GetVietnamTime()
        {
            DateTime utcTime = DateTime.UtcNow;
            TimeZoneInfo vnZone;
            try
            {
                vnZone = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
            }
            catch (TimeZoneNotFoundException)
            {
                vnZone = TimeZoneInfo.FindSystemTimeZoneById("Asia/Ho_Chi_Minh");
            }

            return TimeZoneInfo.ConvertTimeFromUtc(utcTime, vnZone);
        }
    }
}
