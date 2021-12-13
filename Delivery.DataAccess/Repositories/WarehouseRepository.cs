using System.Collections.Generic;
using System.Threading.Tasks;
using Dapper;
using Delivery.DataAccess.Entities;

namespace Delivery.DataAccess.Repositories
{
    public class WarehouseRepository
    {
        private readonly SqlConnectionProvider _provider;

        public WarehouseRepository(SqlConnectionProvider provider)
        {
            _provider = provider;
        }

        public async Task<IEnumerable<Warehouse>> GetAllWarehouses()
        {
            using var connection = _provider.Connection;
            const string query = "SELECT * FROM warehouse";

            var warehouse = await connection.QueryAsync<Warehouse>(query);
            return warehouse;
        }
    }
}