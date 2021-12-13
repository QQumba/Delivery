using Delivery.DataAccess.Repositories;
using Microsoft.Extensions.DependencyInjection;

namespace Delivery.DataAccess
{
    public static class DependencyInjectionExtensions
    {
        public static IServiceCollection AddDataAccessLayer(this IServiceCollection services)
        {
            services.AddScoped<SqlConnectionProvider>();
            services.AddScoped<WarehouseRepository>();
            services.AddScoped<CargoRepository>();
            services.AddScoped<ProductRepository>();
            services.AddScoped<ProductInstanceRepository>();

            return services;
        }
    }
}