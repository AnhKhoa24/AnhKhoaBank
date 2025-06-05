namespace BE_InternetBanking.Services.Contracts
{
    public interface IQRCodeService
    {
        byte[] GenerateQRCodeByte(string inputText);
        Task<byte[]> GenerateZip(List<string> inputText);
    }
}
