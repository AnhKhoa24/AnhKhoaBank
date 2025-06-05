using BE_InternetBanking.Models.Entities;

namespace BE_InternetBanking.Models.DTO
{
    public class ResponseServies
    {
        public record class RegisterResponse(bool Flag, string Message);
        public record class LoginResponse(bool Flag, string Email ,string Message);
        public record class OTPResponse(bool Flag, string Token ,string Message, List<string>Roles);
        public record class CreateAccountRespone(bool Flag, string AccountNumber, string Message);
        public record class TranferRespone(bool Flag, string Id, string Status);
        public record class GetProfileUserRespone(bool Flag, Account account);
        public record class CheckAccountResponse(bool Flag, string message, string UserName);
        public record class GetHistoryNotificationResponse(bool Flag, string message, List<MessageDTO> msgs);
        public record class TransactionHistoryResponse(bool Flag, string message, List<TransactionHistory> trans);
        public record class LogoutResponse(bool Flag, string message);
    }
}
