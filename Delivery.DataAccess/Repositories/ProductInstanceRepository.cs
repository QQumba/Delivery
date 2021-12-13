using System.Collections.Generic;
using System.Threading.Tasks;
using Dapper;
using Delivery.DataAccess.Entities;

namespace Delivery.DataAccess.Repositories
{
    public class ProductInstanceRepository
    {
        private readonly SqlConnectionProvider _provider;

        public ProductInstanceRepository(SqlConnectionProvider provider)
        {
            _provider = provider;
        }

        public async Task<IEnumerable<ProductInstance>> GetAllProductInstances()
        {
            using var connection = _provider.Connection;
            const string query = "SELECT * FROM product_instance";

            var productInstances = await connection.QueryAsync<ProductInstance>(query);
            return productInstances;
        }
    }
}