using Microsoft.AspNetCore.Mvc;

namespace web.Controllers
{
    public class HealthController : Controller
    {

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok();
        } 
        
    }
}