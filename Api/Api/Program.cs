using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Site addresses allowed to call this API (separate several with ;)

var origins = (builder.Configuration["AllowedOrigin"] ?? "http://localhost:5500")
    .Split(new[] { ';', ',' }, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

// Only GET is allowed, so the API can read data but never change it

builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.WithOrigins(origins).WithMethods("GET").AllowAnyHeader()));

var app = builder.Build();
app.UseCors();

var connStr = app.Configuration.GetConnectionString("Default")!;

// Only these tables can be browsed (Branches, Customer, Suppliers, Categories, Employees, Products, Sales and Sale_Items)

string[] tables = { "Branches", "Customer", "Suppliers", "Categories",
                    "Employees", "Products", "Sales", "Sale_Items" };


// Reports IS the .sql files in the file /Reports. The first comment lines hold the title and description.
var reports = new Dictionary<string, Report>();
var reportsDir = Path.Combine(AppContext.BaseDirectory, "Reports");
if (Directory.Exists(reportsDir))
{
    foreach (var file in Directory.GetFiles(reportsDir, "*.sql").OrderBy(f => f))
    {
        var sql = File.ReadAllText(file);

        // Reads the text after "-- Title:" or "-- Description:"
        string Meta(string key) => sql.Split('\n')
            .FirstOrDefault(l => l.StartsWith($"-- {key}:"))?.Substring(key.Length + 4).Trim() ?? "";
        reports[Path.GetFileNameWithoutExtension(file)] = new Report(Meta("Title"), Meta("Description"), sql.Trim());
    }
}

// Lists every report with its SQL text

app.MapGet("/api/reports", () => reports.Select(r => new
{ id = r.Key, title = r.Value.Title, description = r.Value.Description, sql = r.Value.Sql }));

// Runs one report and returns its rows
app.MapGet("/api/reports/{id}", async (string id) =>
{
    // Only SQL files shipped with the app can run; nothing from the request becomes SQL.

    if (!reports.TryGetValue(id, out var report)) return Results.NotFound();
    await using var conn = new SqlConnection(connStr);
    await conn.OpenAsync();
    await using var cmd = new SqlCommand(report.Sql, conn) { CommandTimeout = 60 };
    await using var r = await cmd.ExecuteReaderAsync();
    var (columns, rows) = await ReadAll(r);
    return Results.Ok(new { columns, rows });
});


// Table names for the dropdown

app.MapGet("/api/tables", () => tables);

// One page of a table, with optional search

app.MapGet("/api/tables/{name}", async (string name, int page = 1, int pageSize = 50, string? search = null) =>
{
    if (!tables.Contains(name)) return Results.NotFound();
    page = Math.Max(page, 1);
    pageSize = Math.Clamp(pageSize, 1, 200);

    await using var conn = new SqlConnection(connStr);
    await conn.OpenAsync();

    // Column names come from the database, not from the request

    var cols = new List<string>();
    await using (var cmd = new SqlCommand(

        "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @t ORDER BY ORDINAL_POSITION", conn))
    {
        cmd.Parameters.AddWithValue("@t", name);
        await using var r = await cmd.ExecuteReaderAsync();
        while (await r.ReadAsync()) cols.Add(r.GetString(0));
    }


    // Search checks every column: WHERE col1 LIKE @q OR col2 LIKE @q ...

    var hasSearch = !string.IsNullOrWhiteSpace(search);
    var where = hasSearch
        ? "WHERE " + string.Join(" OR ", cols.Select(c => $"CONVERT(NVARCHAR(200), [{c}]) LIKE @q"))
        : "";

    // Total matching rows, for "page 1 of 200"
    long total;
    await using (var cmd = new SqlCommand($"SELECT COUNT(*) FROM [{name}] {where}", conn))
    {
        if (hasSearch) cmd.Parameters.AddWithValue("@q", $"%{search}%");
        total = Convert.ToInt64(await cmd.ExecuteScalarAsync());
    }

    // OFFSET skips the earlier pages, FETCH NEXT takes one page

    await using var rowsCmd = new SqlCommand(
        $"SELECT * FROM [{name}] {where} ORDER BY [{cols[0]}] OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY", conn);
    if (hasSearch) rowsCmd.Parameters.AddWithValue("@q", $"%{search}%");
    rowsCmd.Parameters.AddWithValue("@skip", (page - 1) * pageSize);
    rowsCmd.Parameters.AddWithValue("@take", pageSize);
    await using var reader = await rowsCmd.ExecuteReaderAsync();
    var (columns, rows) = await ReadAll(reader);

    return Results.Ok(new { columns, total, page, pageSize, rows });
});


app.Run();

// Turns a SQL result into column names and rows that can be sent as JSON
static async Task<(List<string>, List<object?[]>)> ReadAll(SqlDataReader r)
{

    var columns = Enumerable.Range(0, r.FieldCount).Select(i => r.GetName(i)).ToList();
    var rows = new List<object?[]>();
    while (await r.ReadAsync())
    {

        var row = new object?[r.FieldCount];
        for (var i = 0; i < row.Length; i++)
        {
            if (r.IsDBNull(i)) continue;
            var v = r.GetValue(i);

            // Dates become yyyy-MM-dd text

            row[i] = v is DateTime d ? d.ToString("yyyy-MM-dd") : v;
        }

        rows.Add(row);
    }
    //return the coloumns and the rows 

    return (columns, rows);
}

record Report(string Title, string Description, string Sql);