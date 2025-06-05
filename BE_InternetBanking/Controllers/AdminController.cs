using BE_InternetBanking.Feature.UserProfile;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BE_InternetBanking.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "ADMIN")]
    public class AdminController : ControllerBase
    {
        private readonly IMediator _mediator;
        public AdminController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfileV2()
        {
            var idString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(idString, out var userGuid))
                return BadRequest();

            var response = await _mediator.Send(new GetProfileUserCommand(userGuid));
            var roles = User
                .FindAll(ClaimTypes.Role)
                .Select(c => c.Value)
                .ToList();

            var result = new
            {
                Id = idString,
                Email = User.FindFirstValue(ClaimTypes.Email),
                FullName = User.FindFirstValue(ClaimTypes.Name),
                Roles = roles,
                AccountNumber = response.account.AccountNumber!,
                Balance = response.account.Balance!,
                CreatedAt = response.account.CreatedAt!
            };

            return Ok(result);
        }
    }
}
