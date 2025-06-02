using BE_InternetBanking.Services.Contracts;
using Google.Apis.Auth.OAuth2;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;


namespace BE_InternetBanking.Services.Repositories
{
    public class FcmHttpV1Sender: IFcmSender
    {
        private readonly string _projectId;
        private readonly GoogleCredential _credential;

        public FcmHttpV1Sender(string jsonPath, string projectId)
        {
            _projectId = projectId;
            _credential = GoogleCredential
                .FromFile(jsonPath)
                .CreateScoped("https://www.googleapis.com/auth/firebase.messaging");
        }
        public async Task SendNotificationAsync(string fcmToken, string title, string body)
        {
            var accessToken = await _credential.UnderlyingCredential.GetAccessTokenForRequestAsync();
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            var message = new
            {
                message = new
                {
                    token = fcmToken,
                    notification = new
                    {
                        title,
                        body
                    }
                }
            };
            var json = JsonSerializer.Serialize(message);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await client.PostAsync(
                $"https://fcm.googleapis.com/v1/projects/{_projectId}/messages:send",
                content);
            var result = await response.Content.ReadAsStringAsync();
            Console.WriteLine($"FCM Response: {result}");
        }
    }
}
