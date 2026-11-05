using CustomersApi.Customers;
using CustomersApi.Data;
using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;

// ============================================================================
// CustomersApi - samma Customer-CRUD som TelemetryApi, men mot Azure SQL och
// UTAN lösenord i connection stringen:
//
//   Lokalt:  inloggad via "az login"  (Authentication=Active Directory Default)
//   Azure:   webbappens Managed Identity (samma connection string!)
//
//   Webbapp --Managed Identity--> Entra ID --token--> Azure SQL (contained user)
//
// Connection stringen kommer från konfigurationen:
//   ConnectionStrings__CustomersDb  (miljövariabel / App Setting)
// ============================================================================

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("CustomersDb")
    ?? throw new InvalidOperationException("ConnectionStrings:CustomersDb saknas (miljövariabel ConnectionStrings__CustomersDb).");

// EnableRetryOnFailure: en serverless-databas som pausat sig behöver en stund för att
// vakna - EF Core försöker då igen vid tillfälliga fel i stället för att ge upp direkt.
builder.Services.AddDbContext<CustomersDbContext>(o => o.UseSqlServer(connectionString, sql =>
    sql.EnableRetryOnFailure(maxRetryCount: 5, maxRetryDelay: TimeSpan.FromSeconds(15), errorNumbersToAdd: null)));

builder.Services.AddOpenApi();
builder.Services.AddProblemDetails();

var app = builder.Build();

// OBS: ingen EnsureCreated/Migrate här. Schemat skapas av en utvecklare med
// "dotnet ef database update" - appen får bara läsa och skriva data (minsta behörighet).

app.UseExceptionHandler();

if (app.Environment.IsDevelopment() || app.Configuration.GetValue<bool>("OpenApi:Enabled"))
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.MapGet("/healthz", () => TypedResults.Ok("ok")).ExcludeFromDescription();

// Vem är appen inloggad som i databasen? Lokalt: din Entra-användare.
// I Azure: webbappens Managed Identity (databasanvändaren heter som webbappen).
app.MapGet("/db/whoami", async (CustomersDbContext db, CancellationToken ct) =>
{
    var user = (await db.Database.SqlQueryRaw<string>("SELECT USER_NAME() AS [Value]").ToListAsync(ct)).First();
    var database = (await db.Database.SqlQueryRaw<string>("SELECT DB_NAME() AS [Value]").ToListAsync(ct)).First();
    return TypedResults.Ok(new { database, user });
}).ExcludeFromDescription();

// Löstes Key Vault-referensen? Om inte lämnar App Service kvar själva referenstexten som värde.
// Vi visar aldrig hemligheten - bara om den är upplöst.
app.MapGet("/config", (IConfiguration config) =>
{
    var value = config["Demo:ExternalApiKey"];
    var state = value is null ? "saknas"
        : value.StartsWith("@Microsoft.KeyVault", StringComparison.OrdinalIgnoreCase) ? "ej upplöst (referensen är kvar som text)"
        : "upplöst";
    return TypedResults.Ok(new { externalApiKey = state, length = value?.Length ?? 0 });
}).ExcludeFromDescription();

app.MapCustomers();

app.Run();
