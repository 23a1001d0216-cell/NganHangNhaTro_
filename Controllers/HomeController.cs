using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NganHangNhaTro.Data;

namespace NganHangNhaTro.Controllers;

public class HomeController : Controller
{
    private readonly AppDbContext _context;

    public HomeController(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IActionResult> Index(
        string? q,
        int? locationCategoryId,
        int? roomTypeCategoryId,
        decimal? minPrice,
        decimal? maxPrice,
        double? minArea,
        double? maxArea,
        string? amenity,
        string? sort,
        bool? ajax)
    {
        // 1. Lấy danh sách danh mục
        ViewBag.LocationCategories = await _context.Categories.ToListAsync();
        ViewBag.RoomTypeCategories = await _context.Categories.ToListAsync();

        ViewBag.Query = q;
        ViewBag.LocationCategoryId = locationCategoryId;
        ViewBag.RoomTypeCategoryId = roomTypeCategoryId;
        ViewBag.MinPrice = minPrice;
        ViewBag.MaxPrice = maxPrice;
        ViewBag.MinArea = minArea;
        ViewBag.MaxArea = maxArea;
        ViewBag.Amenity = amenity;
        ViewBag.Sort = sort;

        // 2. Truy vấn danh sách phòng
        var roomsQuery = _context.Rooms.AsQueryable();

        if (!string.IsNullOrEmpty(q))
        {
            roomsQuery = roomsQuery.Where(r => r.Title.Contains(q) || r.Address.Contains(q) || r.Description.Contains(q));
        }

        if (locationCategoryId.HasValue)
        {
            roomsQuery = roomsQuery.Where(r => r.LocationCategoryId == locationCategoryId.Value);
        }

        if (roomTypeCategoryId.HasValue)
        {
            roomsQuery = roomsQuery.Where(r => r.RoomTypeCategoryId == roomTypeCategoryId.Value);
        }

        if (minPrice.HasValue)
        {
            roomsQuery = roomsQuery.Where(r => r.Price >= minPrice.Value);
        }
        if (maxPrice.HasValue)
        {
            roomsQuery = roomsQuery.Where(r => r.Price <= maxPrice.Value);
        }

        if (minArea.HasValue)
        {
            roomsQuery = roomsQuery.Where(r => r.Area >= minArea.Value);
        }
        if (maxArea.HasValue)
        {
            roomsQuery = roomsQuery.Where(r => r.Area <= maxArea.Value);
        }

        if (!string.IsNullOrEmpty(amenity))
        {
            roomsQuery = roomsQuery.Where(r => r.Amenities != null && r.Amenities.Contains(amenity));
        }

        // 3. Sắp xếp
        switch (sort)
        {
            case "price_asc":
                roomsQuery = roomsQuery.OrderBy(r => r.Price);
                break;
            case "price_desc":
                roomsQuery = roomsQuery.OrderByDescending(r => r.Price);
                break;
            case "area_desc":
                roomsQuery = roomsQuery.OrderByDescending(r => r.Area);
                break;
            default:
                roomsQuery = roomsQuery.OrderByDescending(r => r.RoomId); // Đã sửa thành RoomId (hoặc tên khóa chính thực tế của bảng Room)
                break;
        }

        var rooms = await roomsQuery.ToListAsync();

        if (ajax == true || Request.Headers["X-Requested-With"] == "XMLHttpRequest")
        {
            return PartialView("_RoomCards", rooms);
        }

        return View(rooms);
    }

    public IActionResult Error() => View("Error");
}