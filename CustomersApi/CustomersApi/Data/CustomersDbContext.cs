using Microsoft.EntityFrameworkCore;

namespace CustomersApi.Data;

public class CustomersDbContext(DbContextOptions<CustomersDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers => Set<Customer>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Customer>(e =>
        {
            e.ToTable("Customers");
            e.HasKey(c => c.Id);

            // Id sätts i koden (Guid.NewGuid) - databasen genererar det inte.
            e.Property(c => c.Id).ValueGeneratedNever();

            e.Property(c => c.Name).HasMaxLength(200).IsRequired();
            e.Property(c => c.Email).HasMaxLength(200);
            e.Property(c => c.Phone).HasMaxLength(50);
            e.Property(c => c.City).HasMaxLength(100);
            e.HasIndex(c => c.Name);
        });
    }
}
