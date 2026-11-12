namespace CustomersApi.Data;

/// <summary>Samma Customer som i TelemetryApi - nu mot Azure SQL i stället för MySQL.</summary>
public class Customer
{
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string? City { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
