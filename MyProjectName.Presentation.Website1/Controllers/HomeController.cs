using Microsoft.AspNetCore.Mvc;

namespace MyProjectName.Presentation.Website1.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index() => View();
    }
}