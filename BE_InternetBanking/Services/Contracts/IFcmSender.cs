namespace BE_InternetBanking.Services.Contracts
{
    public interface IFcmSender
    {
        Task SendNotificationAsync(string fcmToken, string title, string body);
    }
}
