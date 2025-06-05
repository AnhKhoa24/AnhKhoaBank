using BE_InternetBanking.Models.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BE_InternetBanking.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ThongKeController : ControllerBase
    {
        private readonly BankingContext _context;

        public ThongKeController(BankingContext context)
        {
            _context = context;
        }
        [HttpGet("weekly")]
        public async Task<IActionResult> GetWeeklyTransactionStats()
        {
            DateTime today = DateTime.Today;           
            DateTime weekStart = today.AddDays(-6);     

            var rawStats = await _context.TransactionBankings
                .Where(t => t.Timestamp.HasValue
                            && t.Timestamp.Value.Date >= weekStart
                            && t.Timestamp.Value.Date <= today)
                .GroupBy(t => t.Timestamp!.Value.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Count = g.Count()
                })
                .ToListAsync();

            var result = new List<object>();
            for (int i = 0; i < 7; i++)
            {
                DateTime dt = weekStart.AddDays(i);
                var entry = rawStats.FirstOrDefault(x => x.Date == dt);
                result.Add(new
                {
                    Date = dt,
                    Count = entry != null ? entry.Count : 0
                });
            }

            return Ok(result);
        }
        [HttpPost("datathongke")]
        public async Task<IActionResult> ThongKe()
        {
            var rawStats = await _context.TransactionBankings
                .Include(x => x.FromAccount)
                .Include(x => x.ToAccount)
                .Select(x => new
                {
                    x.Id,
                    x.Message,
                    x.Timestamp,
                    FromAccountNumber = x.FromAccount != null ? x.FromAccount.AccountNumber : null,
                    ToAccountNumber = x.ToAccount != null ? x.ToAccount.AccountNumber : null,
                    x.Amount,
                })
                .ToListAsync();

            return Ok(rawStats);
        }

    }
}
