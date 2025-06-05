using BE_InternetBanking.Feature.UserProfile;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace BE_InternetBanking.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HomeController : ControllerBase
    {
        private readonly IMediator _mediator;
        public HomeController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetProfile()
        {
            var idString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(idString, out var userGuid))
                return BadRequest();
            var response = await _mediator.Send(new GetProfileUserCommand(userGuid));
            var result = new
            {
                Id = User.FindFirstValue(ClaimTypes.NameIdentifier),
                Email = User.FindFirstValue(ClaimTypes.Email),
                FullName = User.FindFirstValue(ClaimTypes.Name),
                Role = User.FindFirstValue(ClaimTypes.Role),
                AccountNumber = response.account.AccountNumber!,
                Balance = response.account.Balance!,
                CreatedAt = response.account.CreatedAt!, 
            };

            return Ok(result);
        }
        [Authorize]
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

        [Authorize(Roles = "USER")]
        [HttpGet("dashboard")]
        public IActionResult UserDashboard()
        {
            var FullName = User.FindFirstValue(ClaimTypes.Name);
            return Ok("Chào USER!");
        }
    }
}
