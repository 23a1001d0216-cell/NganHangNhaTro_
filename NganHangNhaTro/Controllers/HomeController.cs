using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NganHangNhaTro.Data;

namespace NganHangNhaTro.Controllers;

public class HomeController : Controller
{
    private readonly NhaTroDbContext _context;

    public HomeController(NhaTroDbContext context) => _context = context;

    public async Task<IActionResult> Index()
    {
        var rooms = await _context.Rooms
            .AsNoTracking()
            .Include(r => r.LocationCategory)
            .Include(r => r.RoomTypeCategory)
            .Where(r => r.ModerationStatus == "Approved" &&
                        r.RentalStatus == "Available")
            .OrderByDescending(r => r.CreatedAt)
            .Take(6)
            .ToListAsync();

        return View(rooms);
    }
}
