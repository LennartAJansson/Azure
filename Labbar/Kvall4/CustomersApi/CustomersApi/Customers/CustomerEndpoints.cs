using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using CustomersApi.Data;

namespace CustomersApi.Customers;

// Vanlig CRUD för Customer - samma form som i TelemetryApi, utan telemetrin.
public static class CustomerEndpoints
{
    public static IEndpointRouteBuilder MapCustomers(this IEndpointRouteBuilder app)
    {
        var customers = app.MapGroup("/customers").WithTags("Customers");

        customers.MapGet("/", GetAll).WithName("GetCustomers");
        customers.MapGet("/{id:guid}", GetById).WithName("GetCustomer");
        customers.MapPost("/", Create).WithName("CreateCustomer");
        customers.MapPut("/{id:guid}", Update).WithName("UpdateCustomer");
        customers.MapDelete("/{id:guid}", Delete).WithName("DeleteCustomer");

        return app;
    }

    private static async Task<Ok<List<CustomerDto>>> GetAll(string? search, CustomersDbContext db, CancellationToken ct)
    {
        var query = db.Customers.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(c => c.Name.Contains(term) || (c.City != null && c.City.Contains(term)));
        }

        var result = await query.OrderBy(c => c.Name).Select(c => CustomerDto.From(c)).ToListAsync(ct);
        return TypedResults.Ok(result);
    }

    private static async Task<Results<Ok<CustomerDto>, NotFound>> GetById(Guid id, CustomersDbContext db, CancellationToken ct)
    {
        var customer = await db.Customers.AsNoTracking().FirstOrDefaultAsync(c => c.Id == id, ct);
        return customer is null ? TypedResults.NotFound() : TypedResults.Ok(CustomerDto.From(customer));
    }

    private static async Task<Results<Created<CustomerDto>, ValidationProblem>> Create(CustomerRequest request, CustomersDbContext db, CancellationToken ct)
    {
        if (Validate(request) is { } errors)
            return TypedResults.ValidationProblem(errors);

        var customer = new Customer { Id = Guid.NewGuid(), CreatedAt = DateTime.UtcNow };
        request.ApplyTo(customer);
        db.Customers.Add(customer);
        await db.SaveChangesAsync(ct);

        return TypedResults.Created($"/customers/{customer.Id}", CustomerDto.From(customer));
    }

    private static async Task<Results<Ok<CustomerDto>, NotFound, ValidationProblem>> Update(Guid id, CustomerRequest request, CustomersDbContext db, CancellationToken ct)
    {
        if (Validate(request) is { } errors)
            return TypedResults.ValidationProblem(errors);

        var customer = await db.Customers.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (customer is null)
            return TypedResults.NotFound();

        request.ApplyTo(customer);
        customer.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);

        return TypedResults.Ok(CustomerDto.From(customer));
    }

    private static async Task<Results<NoContent, NotFound>> Delete(Guid id, CustomersDbContext db, CancellationToken ct)
    {
        var customer = await db.Customers.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (customer is null)
            return TypedResults.NotFound();

        db.Customers.Remove(customer);
        await db.SaveChangesAsync(ct);
        return TypedResults.NoContent();
    }

    private static Dictionary<string, string[]>? Validate(CustomerRequest request)
    {
        var errors = new Dictionary<string, string[]>();
        if (string.IsNullOrWhiteSpace(request.Name))
            errors["name"] = ["Namn måste anges."];
        else if (request.Name.Length > 200)
            errors["name"] = ["Namn får vara högst 200 tecken."];
        return errors.Count == 0 ? null : errors;
    }
}

public record CustomerRequest(string Name, string? Email, string? Phone, string? City)
{
    public void ApplyTo(Customer customer)
    {
        customer.Name = Name.Trim();
        customer.Email = Email?.Trim();
        customer.Phone = Phone?.Trim();
        customer.City = City?.Trim();
    }
}
