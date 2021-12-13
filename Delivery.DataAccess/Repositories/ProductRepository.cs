using System.Collections.Generic;
using System.Reflection.Metadata;
using System.Threading.Tasks;
using Dapper;
using Delivery.DataAccess.Entities;

namespace Delivery.DataAccess.Repositories
{
    public class ProductRepository
    {
        private readonly SqlConnectionProvider _provider;

        public ProductRepository(SqlConnectionProvider provider)
        {
            _provider = provider;
        }

        public async Task<IEnumerable<Product>> GetAllProducts()
        {
            using var connection = _provider.Connection;
            const string query = "SELECT * FROM product";

            var products = await connection.QueryAsync<Product>(query);
            return products;
        }
    }
}