using Microsoft.EntityFrameworkCore;
using NganHangNhaTro.Models;

namespace NganHangNhaTro.Data;

public class NhaTroDbContext : DbContext
{
    public NhaTroDbContext(DbContextOptions<NhaTroDbContext> options)
        : base(options) { }

    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Favorite> Favorites => Set<Favorite>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Room>(entity =>
        {
            entity.ToTable("Rooms");
            entity.HasKey(r => r.RoomId);

            entity.HasOne(r => r.LocationCategory)
                .WithMany(c => c.LocationRooms)
                .HasForeignKey(r => r.LocationCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(r => r.RoomTypeCategory)
                .WithMany(c => c.RoomTypeRooms)
                .HasForeignKey(r => r.RoomTypeCategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Category>().ToTable("Categories");

        modelBuilder.Entity<Favorite>(entity =>
        {
            entity.ToTable("Favorites");
            entity.HasKey(f => f.FavoriteId);
            entity.HasOne(f => f.Room)
                .WithMany(r => r.Favorites)
                .HasForeignKey(f => f.RoomId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(f => new { f.TenantId, f.RoomId }).IsUnique();
        });
    }
}
