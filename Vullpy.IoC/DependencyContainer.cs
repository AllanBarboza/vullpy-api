using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

using Vullpy.Application.Interfaces.Persistence;
using Vullpy.Infrastructure.Data;
namespace Vullpy.IoC;

public static class DependencyContainer
{
    public static IServiceCollection AddInfrastructureServices(
          this IServiceCollection services,
          string connectionString,
          bool isDevelopment = false)
    {
        services.AddDbContext<ApplicationDbContext>((serviceProvider, options) =>
        {
            options.UseNpgsql(
                connectionString,
                npgsqlOptions =>
                {
                    npgsqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 5,
                        maxRetryDelay: TimeSpan.FromSeconds(30),
                        errorCodesToAdd: null);

                    npgsqlOptions.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
                });

            if (isDevelopment)
            {
                options
                    .EnableSensitiveDataLogging()
                    .EnableDetailedErrors()
                    .LogTo(Console.WriteLine, LogLevel.Information);
            }
        });

        services.AddScoped<IUnitOfWork, UnitOfWork>();

        return services;
    }
}