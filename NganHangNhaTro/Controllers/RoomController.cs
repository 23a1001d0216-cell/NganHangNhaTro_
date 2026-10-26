using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NganHangNhaTro.Data;

namespace NganHangNhaTro.Controllers;

public class RoomController : Controller
{
    private readonly NhaTroDbContext _context;

    public RoomController(NhaTroDbContext context) => _context = context;

    public async Task<IActionResult> Index(
        string? keyword,
        int? locationCategoryId,
        int? roomTypeCategoryId,
        decimal? minPrice,
        decimal? maxPrice,
        decimal? minArea,
        decimal? maxArea)
    {
        var rooms = await FilterQuery(keyword, locationCategoryId, roomTypeCategoryId,
                minPrice, maxPrice, minArea, maxArea)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        ViewBag.Locations = await _context.Categories.AsNoTracking()
            .Where(c => c.Type == "Location" && c.IsActive)
            .OrderBy(c => c.CategoryName).ToListAsync();

        ViewBag.RoomTypes = await _context.Categories.AsNoTracking()
            .Where(c => c.Type == "RoomType" && c.IsActive)
            .OrderBy(c => c.CategoryName).ToListAsync();

        return View(rooms);
    }

    [HttpGet]
    public async Task<IActionResult> FilterRoomsAjax(
        string? keyword,
        int? locationCategoryId,
        int? roomTypeCategoryId,
        decimal? minPrice,
        decimal? maxPrice,
        decimal? minArea,
        decimal? maxArea)
    {
        if (minPrice < 0 || maxPrice < 0 || minArea < 0 || maxArea < 0)
            return BadRequest("Gia va dien tich khong duoc am.");

        if (minPrice.HasValue && maxPrice.HasValue && minPrice > maxPrice)
            return BadRequest("Gia thap nhat khong duoc lon hon gia cao nhat.");

        if (minArea.HasValue && maxArea.HasValue && minArea > maxArea)
            return BadRequest("Dien tich toi thieu khong duoc lon hon toi da.");

        var rooms = await FilterQuery(keyword, locationCategoryId, roomTypeCategoryId,
                minPrice, maxPrice, minArea, maxArea)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return PartialView("_RoomCardsPartial", rooms);
    }

    public async Task<IActionResult> Details(int id)
    {
        var room = await _context.Rooms.AsNoTracking()
            .Include(r => r.LocationCategory)
            .Include(r => r.RoomTypeCategory)
            .FirstOrDefaultAsync(r => r.RoomId == id &&
                r.ModerationStatus == "Approved");

        if (room == null) return NotFound();

        return View(room);
    }

    private IQueryable<Models.Room> FilterQuery(
        string? keyword,
        int? locationCategoryId,
        int? roomTypeCategoryId,
        decimal? minPrice,
        decimal? maxPrice,
        decimal? minArea,
        decimal? maxArea)
    {
        var query = _context.Rooms.AsNoTracking()
            .Include(r => r.LocationCategory)
            .Include(r => r.RoomTypeCategory)
            .Where(r => r.ModerationStatus == "Approved" &&
                        r.RentalStatus == "Available");

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var term = keyword.Trim();
            query = query.Where(r => r.Title.Contains(term) || r.Address.Contains(term));
        }

        if (locationCategoryId.HasValue)
            query = query.Where(r => r.LocationCategoryId == locationCategoryId.Value);

        if (roomTypeCategoryId.HasValue)
            query = query.Where(r => r.RoomTypeCategoryId == roomTypeCategoryId.Value);

        if (minPrice.HasValue)
            query = query.Where(r => r.Price >= minPrice.Value);

        if (maxPrice.HasValue)
            query = query.Where(r => r.Price <= maxPrice.Value);

        if (minArea.HasValue)
            query = query.Where(r => r.Area >= minArea.Value);

        if (maxArea.HasValue)
            query = query.Where(r => r.Area <= maxArea.Value);

        return query;
    }
}
