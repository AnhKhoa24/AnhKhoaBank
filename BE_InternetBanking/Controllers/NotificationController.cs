using BE_InternetBanking.Feature.UserProfile;
using BE_InternetBanking.Features.Notification;
using BE_InternetBanking.Services.Contracts;
using BE_InternetBanking.Services.Helper;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BE_InternetBanking.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationController : ControllerBase
    {
        private readonly IFcmSender _fcmSender;
        private readonly IMediator _mediator;

        public NotificationController(IFcmSender fcmSender, IMediator mediator)
        {
            _fcmSender = fcmSender;
            _mediator = mediator;
        }

        [HttpPost("send")]
        public async Task<IActionResult> Send([FromQuery] string token)
        {
            await _fcmSender.SendNotificationAsync(token, "hihi", "Số dư TK AKB 12033939393 +10,000,000 VND lúc 08-05-2025 11:21:46. Số dư 10,030,333, VND. Ref 77877888. IBFT HUYNH ANH KHOA chuyen Tien");
            return Ok("Đã gửi!");
        }
        [Authorize]
        [HttpGet("getHistoryNotification")]
        public async Task<IActionResult> GetHistoryNotification()
        {
            var idString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(idString, out var userGuid))
                return BadRequest();
            var response = await _mediator.Send(new GetProfileUserCommand(userGuid));

            var getHisNof = await _mediator.Send(new GetHistoryNotificationCommand(response.account.Id));

            return Ok(getHisNof);
        }
    }
}
