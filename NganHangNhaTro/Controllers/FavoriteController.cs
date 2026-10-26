using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NganHangNhaTro.Data;
using NganHangNhaTro.Models;

namespace NganHangNhaTro.Controllers;

[Authorize]
public class FavoriteController : Controller
{
    private readonly NhaTroDbContext _context;

    public FavoriteController(NhaTroDbContext context) => _context = context;

    public async Task<IActionResult> Index()
    {
        var tenantId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(tenantId)) return Challenge();

        var rooms = await _context.Favorites.AsNoTracking()
            .Where(f => f.TenantId == tenantId &&
                        f.Room != null &&
                        f.Room.ModerationStatus == "Approved" &&
                        f.Room.RentalStatus == "Available")
            .Include(f => f.Room)
                .ThenInclude(r => r!.LocationCategory)
            .Include(f => f.Room)
                .ThenInclude(r => r!.RoomTypeCategory)
            .Select(f => f.Room!)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return View(rooms);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Toggle(int roomId, string? returnUrl)
    {
        var tenantId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(tenantId)) return Challenge();

        var roomExists = await _context.Rooms.AnyAsync(r =>
            r.ModerationStatus == "Approved" &&
            r.RoomId == roomId &&
            r.RentalStatus == "Available");

        if (!roomExists) return NotFound();

        var favorite = await _context.Favorites.FirstOrDefaultAsync(f =>
            f.TenantId == tenantId && f.RoomId == roomId);

        if (favorite == null)
        {
            _context.Favorites.Add(new Favorite
            {
                TenantId = tenantId,
                RoomId = roomId,
                CreatedAt = DateTime.UtcNow
            });
        }
        else
        {
            _context.Favorites.Remove(favorite);
        }

        await _context.SaveChangesAsync();

        if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
            return LocalRedirect(returnUrl);

        return RedirectToAction(nameof(Index));
    }
}
