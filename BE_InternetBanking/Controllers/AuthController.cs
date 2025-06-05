using AutoMapper;
using Azure.Core;
using BE_InternetBanking.Feature.UserProfile;
using BE_InternetBanking.Features.Auth;
using BE_InternetBanking.Models.DTO;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using static BE_InternetBanking.Models.DTO.ResponseServies;

namespace BE_InternetBanking.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        //private readonly IConfiguration _config;
        private readonly IMediator _mediator;
        private readonly IMapper _mapper;

        public AuthController(IMediator mediator, IMapper mapper)
        {
            _mediator = mediator;
            _mapper = mapper;
        }
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _mediator.Send(_mapper.Map<RegisterCommand>(request));

            return result.Flag
                ? Ok(new { success = true, message = result.Message })
                : BadRequest(new { success = false, message = result.Message });
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var result = await _mediator.Send(_mapper.Map<LoginCommand>(request));
            return result.Flag
                ? Ok(new { success = true, email = result.Email, message = result.Message })
                : BadRequest(new { success = false, message = result.Message });
        }

        [HttpPost("otpVerified")]
        public async Task<IActionResult> OtpVerified(OtpVerifiedRequest request)
        {

            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var result = await _mediator.Send(_mapper.Map<OtpVerifiedCommand>(request));
            return result.Flag
                ? Ok(new { success = true, message = result.Message, token = result.Token, roles = result.Roles })
                : BadRequest(new { success = false, message = result.Message });
        }
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Lougout()
        {
            var userGuid = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var jti = User.FindFirstValue(JwtRegisteredClaimNames.Jti);

            var result = await _mediator.Send(new LogoutCommand(userGuid, jti!));
            return result.Flag
                 ? Ok(new { success = true, message = result.message })
                 : BadRequest(new { success = false, message = result.message });
        }

    }
}
