using BE_InternetBanking.Models.Entities;
using BE_InternetBanking.Services.Contracts;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using static BE_InternetBanking.Models.DTO.ResponseServies;
using BE_InternetBanking.Services.Helper;

namespace BE_InternetBanking.Features.Transaction
{
    public class TranferCommandHandler : IRequestHandler<TranferCommand, TranferRespone>
    {
        private readonly BankingContext _context;
        private readonly IFcmSender _fcmSender;

        public TranferCommandHandler(BankingContext context, IFcmSender fcmSender)
        {
            _context = context;
            _fcmSender = fcmSender;
        }
        public async Task<TranferRespone> Handle(TranferCommand request, CancellationToken cancellationToken)
        {
            var FromUserId = await _context.Accounts.Include(a => a.User).FirstOrDefaultAsync(m => m.AccountNumber == request.FromAccountNumber);
            var ToUserId = await _context.Accounts.FirstOrDefaultAsync(m => m.AccountNumber == request.ToAccountNumber);
            if(FromUserId == null || ToUserId == null)
                return new TranferRespone(false, null!,"Tài khoản không tồn tại");

            if(FromUserId.Balance < request.Amount)
                return new TranferRespone(false, null!, "Số dư tài khoản không đủ");

            FromUserId.Balance -= request.Amount;
            ToUserId.Balance += request.Amount;
            var transactionBanking = new TransactionBanking
            {
                FromAccountId = FromUserId.Id,
                ToAccountId = ToUserId.Id,
                Amount = request.Amount,   
                Message = request.Message,
                Timestamp = GetTime.GetVietnamTime(),
                Status = "Thành công"
            };

            await _context.TransactionBankings.AddAsync(transactionBanking);
            await _context.SaveChangesAsync(cancellationToken);

            var formattedAmount = request.Amount.ToString("N0", CultureInfo.InvariantCulture);
            var balanceValue = ToUserId.Balance.GetValueOrDefault();
            var formattedBalance = balanceValue.ToString("N0", CultureInfo.InvariantCulture);

            string message =
              $"Số dư TK AKB {request.ToAccountNumber} +{formattedAmount} VND lúc " +
              $"{transactionBanking.Timestamp:yyyy-MM-dd HH:mm:ss}. " +
              $"Số dư {formattedBalance} VND. Ref {transactionBanking.Id}. IBFT {FromUserId.User!.FullName} {request.Message}";

            var mes = new Message
            {
                AccountId = ToUserId.Id,
                Content = message,
                CreatedAt = GetTime.GetVietnamTime(),
            };
            ////Phát triển thêm
            
            await _context.AddAsync(mes);
            await _context.SaveChangesAsync();

            //Console.WriteLine(message);

            var UserToken = await _context.LoginSessions
            .Where(ls => ls.UserId == ToUserId.UserId && ls.IsActive == true)
            .OrderByDescending(ls => ls.LoginAt)
            .FirstOrDefaultAsync(cancellationToken);
            if(UserToken != null)
            {
                await _fcmSender.SendNotificationAsync(UserToken!.FcmToken!, "Thông báo tài khoản", message);
            }

            return new TranferRespone(true, "hi", "Giao dịch thành công!");
        }
    }
}
