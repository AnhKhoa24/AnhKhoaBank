using AutoMapper;
using Azure.Core;
using BE_InternetBanking.Features.Auth;
using BE_InternetBanking.Models.DTO;
using MediatR;
using Microsoft.AspNetCore.Mvc;
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
                ? Ok(new { success = true, message = result.Message, token = result.Token })
                : BadRequest(new { success = false, message = result.Message });
        }
    }
}
