using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NganHangNhaTro.Models;

public class Room
{
    [Key]
    public int RoomId { get; set; }

    [Required, StringLength(250)]
    public string Title { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal Area { get; set; }

    [Required, StringLength(300)]
    public string Address { get; set; } = string.Empty;

    public string? Description { get; set; }

    [StringLength(500)]
    public string? ImageUrl { get; set; }

    public int LocationCategoryId { get; set; }
    public int RoomTypeCategoryId { get; set; }

    [Required, StringLength(450)]
    public string LandlordId { get; set; } = string.Empty;

    [Required, StringLength(30)]
    public string ModerationStatus { get; set; } = "Pending";

    [Required, StringLength(30)]
    public string RentalStatus { get; set; } = "Available";

    [StringLength(500)]
    public string? RejectionReason { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public Category? LocationCategory { get; set; }
    public Category? RoomTypeCategory { get; set; }
    public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
}
