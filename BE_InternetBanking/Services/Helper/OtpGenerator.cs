using System.Security.Cryptography;

namespace BE_InternetBanking.Services.Helper
{
    public static class OtpGenerator
    {
        public static string GenerateNumericOtp(int length)
        {
            if (length <= 0)
                throw new ArgumentException("Length must be > 0", nameof(length));
            int maxExclusive = (int)Math.Pow(10, length);
            int otpInt = RandomNumberGenerator.GetInt32(0, maxExclusive);
            return otpInt.ToString().PadLeft(length, '0');
        }
    }
}
