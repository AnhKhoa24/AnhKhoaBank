using AutoMapper;
using BE_InternetBanking.Feature.UserProfile;
using BE_InternetBanking.Features.Auth;
using BE_InternetBanking.Features.Transaction;
using BE_InternetBanking.Models.DTO;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BE_InternetBanking.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BankingController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly IMapper _mapper;

        public BankingController(IMediator mediator, IMapper mapper)
        {
            _mediator = mediator;
            _mapper = mapper;
        }

        [Authorize]
        [HttpPost("tranfer")]
        public async Task<IActionResult> Tranfer(TranferRequest request)
        {
            var idString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(idString, out var userGuid))
                return BadRequest();
            
            var toAccount = await _mediator.Send(new GetProfileUserCommand(userGuid));

            var tranfercm = _mapper.Map<TranferCommand>(request);
            tranfercm.FromAccountNumber = toAccount.account.AccountNumber!;

            var result = await _mediator.Send(tranfercm);

            return result.Flag
                ? Ok(new { success = true, message = result.Status })
                : BadRequest(new { success = false, message = result.Status });
        }

        [Authorize]
        [HttpPost("checkAccount")]
        public async Task<IActionResult> CheckAccount(CheckAccountCommand request)
        {
            var idString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(idString, out var userGuid))
                return BadRequest();

            var toAccount = await _mediator.Send(new GetProfileUserCommand(userGuid));

            if (toAccount.account.AccountNumber == request.AccountNumber)
            {
                return BadRequest(new { success = false, message = "Tài khoản nhận không được trùng với tài khoản gửi" });
            }

            var checkAccountCM = await _mediator.Send(request);

            return checkAccountCM.Flag
                ? Ok(new { success = true, message = checkAccountCM.message, fullname = checkAccountCM.UserName })
                : BadRequest(new { success = false, message = checkAccountCM.message });
        }

        [Authorize]
        [HttpPost("getHistory")]
        public async Task<IActionResult> GetHistory()
        {
            var idString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(idString, out var userGuid))
                return BadRequest();

            var toAccount = await _mediator.Send(new GetProfileUserCommand(userGuid));
            var tranhis = await _mediator.Send(new TransactionHistoryCommand(toAccount.account.Id));
            return Ok(tranhis);
        }

    }
}
