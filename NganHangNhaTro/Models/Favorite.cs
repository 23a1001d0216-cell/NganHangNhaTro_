using System.ComponentModel.DataAnnotations;

namespace NganHangNhaTro.Models;

public class Favorite
{
    [Key]
    public int FavoriteId { get; set; }

    [Required, StringLength(450)]
    public string TenantId { get; set; } = string.Empty;

    public int RoomId { get; set; }
    public DateTime CreatedAt { get; set; }

    public Room? Room { get; set; }
}
