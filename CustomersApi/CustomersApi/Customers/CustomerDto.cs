using CustomersApi.Data;

namespace CustomersApi.Customers;

public record CustomerDto(Guid Id, string Name, string? Email, string? Phone, string? City, DateTime CreatedAt, DateTime? UpdatedAt)
{
    public static CustomerDto From(Customer c) => new(c.Id, c.Name, c.Email, c.Phone, c.City, c.CreatedAt, c.UpdatedAt);
}
